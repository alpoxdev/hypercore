# AI SDK - React Hooks

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK는 React 애플리케이션을 위한 훅을 제공합니다:
- `useChat`: 채팅 인터페이스
- `useCompletion`: 텍스트 완성
- `useObject`: 구조화된 객체 생성 (실험적)

```bash
npm install @ai-sdk/react
```

---

## useChat

채팅 인터페이스를 쉽게 구현할 수 있는 훅입니다.

### 기본 사용

```tsx
'use client'

import { useChat } from '@ai-sdk/react'

export default function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: '/api/chat',
  })

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id}>
          <strong>{m.role}:</strong> {m.content}
        </div>
      ))}

      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Type a message..."
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Sending...' : 'Send'}
        </button>
      </form>
    </div>
  )
}
```

### 반환값

```typescript
const {
  // 메시지 관련
  messages,           // Message[] - 전체 메시지 목록
  setMessages,        // 메시지 직접 설정

  // 입력 관련
  input,              // string - 현재 입력값
  setInput,           // 입력값 직접 설정
  handleInputChange,  // 입력 변경 핸들러

  // 제출 관련
  handleSubmit,       // 폼 제출 핸들러
  append,             // 메시지 추가 및 전송
  reload,             // 마지막 응답 재생성

  // 상태 관련
  isLoading,          // 응답 대기 중
  error,              // 에러 객체
  stop,               // 스트리밍 중단
} = useChat()
```

### 메시지 타입

```typescript
interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  createdAt?: Date
  toolInvocations?: ToolInvocation[]
}
```

### API Route 설정

```typescript
// app/api/chat/route.ts
import { streamText, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
}
```

---

## useChat 고급 기능

### 초기 메시지

```tsx
const { messages } = useChat({
  api: '/api/chat',
  initialMessages: [
    { id: '1', role: 'assistant', content: 'Hello! How can I help you?' },
  ],
})
```

### 동적 요청 데이터

```tsx
const [temperature, setTemperature] = useState(0.7)

const { messages, handleSubmit } = useChat({
  api: '/api/chat',
  body: {
    temperature,
    userId: 'user-123',
  },
  headers: {
    Authorization: `Bearer ${token}`,
  },
})
```

서버에서 추가 데이터 접근:

```typescript
// app/api/chat/route.ts
export async function POST(req: Request) {
  const { messages, temperature, userId } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    temperature, // 동적 파라미터 사용
  })

  return result.toUIMessageStreamResponse()
}
```

### 콜백 함수

```tsx
const { messages } = useChat({
  api: '/api/chat',
  onResponse: (response) => {
    console.log('Received response:', response)
  },
  onFinish: (message) => {
    console.log('Finished:', message)
  },
  onError: (error) => {
    console.error('Error:', error)
    toast.error('Something went wrong')
  },
})
```

### 메시지 직접 추가

```tsx
const { append } = useChat()

// 사용자 메시지 추가 및 전송
const handleClick = async () => {
  await append({
    role: 'user',
    content: 'Tell me a joke',
  })
}
```

### 스트리밍 중단

```tsx
const { stop, isLoading } = useChat()

return (
  <button onClick={stop} disabled={!isLoading}>
    Stop generating
  </button>
)
```

### 마지막 응답 재생성

```tsx
const { reload, messages } = useChat()

return (
  <button onClick={reload} disabled={messages.length === 0}>
    Regenerate response
  </button>
)
```

### UI 업데이트 쓰로틀링

대량의 스트리밍 데이터가 있을 때 성능 최적화:

```tsx
const { messages } = useChat({
  api: '/api/chat',
  experimental_throttle: 50, // 50ms마다 UI 업데이트
})
```

---

## useCompletion

단순 텍스트 완성을 위한 훅입니다.

### 기본 사용

```tsx
'use client'

import { useCompletion } from '@ai-sdk/react'

export default function Completion() {
  const { completion, input, handleInputChange, handleSubmit, isLoading } = useCompletion({
    api: '/api/completion',
  })

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Enter a prompt..."
        />
        <button type="submit" disabled={isLoading}>
          Complete
        </button>
      </form>

      <div>{completion}</div>
    </div>
  )
}
```

### 반환값

```typescript
const {
  completion,         // string - 생성된 텍스트
  complete,           // 직접 완성 요청
  input,              // string - 현재 입력값
  setInput,           // 입력값 설정
  handleInputChange,  // 입력 변경 핸들러
  handleSubmit,       // 폼 제출 핸들러
  isLoading,          // 로딩 상태
  error,              // 에러 객체
  stop,               // 스트리밍 중단
  setCompletion,      // 완성 텍스트 직접 설정
} = useCompletion()
```

### API Route

```typescript
// app/api/completion/route.ts
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

export async function POST(req: Request) {
  const { prompt } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  return result.toUIMessageStreamResponse()
}
```

### 프로그래매틱 호출

```tsx
const { complete, completion } = useCompletion({
  api: '/api/completion',
})

const handleClick = async () => {
  await complete('Write a haiku about programming')
}
```

### 콜백

```tsx
const { completion } = useCompletion({
  onResponse: (response) => {
    console.log('Response received')
  },
  onFinish: (prompt, completion) => {
    console.log('Finished:', completion)
  },
  onError: (error) => {
    console.error('Error:', error)
  },
})
```

---

## useObject (실험적)

구조화된 객체를 스트리밍으로 생성합니다.

### 기본 사용

```tsx
'use client'

import { experimental_useObject as useObject } from '@ai-sdk/react'
import { z } from 'zod'

const schema = z.object({
  name: z.string(),
  age: z.number(),
  hobbies: z.array(z.string()),
})

export default function ObjectGenerator() {
  const { object, submit, isLoading, error } = useObject({
    api: '/api/generate-object',
    schema,
  })

  return (
    <div>
      <button onClick={() => submit('Generate a random person')} disabled={isLoading}>
        Generate
      </button>

      {object && (
        <pre>{JSON.stringify(object, null, 2)}</pre>
      )}
    </div>
  )
}
```

### API Route

```typescript
// app/api/generate-object/route.ts
import { streamObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const schema = z.object({
  name: z.string(),
  age: z.number(),
  hobbies: z.array(z.string()),
})

export async function POST(req: Request) {
  const { prompt } = await req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema,
    prompt,
  })

  return result.toTextStreamResponse()
}
```

---

## 도구 호출 표시

채팅에서 도구 호출을 표시하는 방법:

```tsx
'use client'

import { useChat } from '@ai-sdk/react'

export default function Chat() {
  const { messages } = useChat({
    api: '/api/chat',
  })

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id}>
          <strong>{m.role}:</strong>

          {/* 텍스트 콘텐츠 */}
          {m.content}

          {/* 도구 호출 표시 */}
          {m.toolInvocations?.map((tool, i) => (
            <div key={i} className="tool-call">
              <strong>Tool: {tool.toolName}</strong>
              <pre>Input: {JSON.stringify(tool.args, null, 2)}</pre>
              {tool.state === 'result' && (
                <pre>Result: {JSON.stringify(tool.result, null, 2)}</pre>
              )}
            </div>
          ))}
        </div>
      ))}
    </div>
  )
}
```

---

## 스트림 프로토콜

AI SDK v5에서는 기본 스트림 프로토콜이 변경되었습니다:

```tsx
// v5 기본값 (data protocol)
const { messages } = useChat()

// 레거시 텍스트 프로토콜 사용
const { messages } = useChat({
  streamProtocol: 'text',
})
```

---

## 타입 안전성

```typescript
import { useChat, Message } from '@ai-sdk/react'

// 메시지 타입 확장
interface CustomMessage extends Message {
  customField?: string
}

// 타입 지정
const { messages } = useChat<CustomMessage>()
```
