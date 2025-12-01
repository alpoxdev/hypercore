# AI SDK - 프로바이더

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK 프로바이더는 다양한 AI 모델 서비스와의 연결을 표준화합니다.

---

## 설치

```bash
# 필요한 프로바이더만 설치
npm install @ai-sdk/openai      # OpenAI (GPT-4, GPT-4o)
npm install @ai-sdk/anthropic   # Anthropic (Claude)
npm install @ai-sdk/google      # Google (Gemini)
npm install @ai-sdk/mistral     # Mistral
npm install @ai-sdk/groq        # Groq
npm install @ai-sdk/cohere      # Cohere
```

---

## OpenAI

### 기본 사용

```typescript
import { openai } from '@ai-sdk/openai'
import { generateText } from 'ai'

const { text } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',
})
```

### 커스텀 설정

```typescript
import { createOpenAI } from '@ai-sdk/openai'

const openai = createOpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  baseURL: 'https://api.openai.com/v1', // 커스텀 엔드포인트
  organization: 'org-xxx', // 조직 ID
})

const { text } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',
})
```

### 사용 가능한 모델

| 모델 | 설명 |
|------|------|
| `gpt-4o` | 최신 GPT-4 Omni |
| `gpt-4o-mini` | 경량화된 GPT-4o |
| `gpt-4-turbo` | GPT-4 Turbo |
| `gpt-3.5-turbo` | GPT-3.5 |
| `o1` | 추론 최적화 모델 |
| `o1-mini` | 경량 추론 모델 |

### 환경 변수

```bash
OPENAI_API_KEY=sk-...
```

---

## Anthropic (Claude)

### 기본 사용

```typescript
import { anthropic } from '@ai-sdk/anthropic'
import { generateText } from 'ai'

const { text } = await generateText({
  model: anthropic('claude-3-5-sonnet-20241022'),
  prompt: 'Explain TypeScript.',
})
```

### 커스텀 설정

```typescript
import { createAnthropic } from '@ai-sdk/anthropic'

const anthropic = createAnthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
  baseURL: 'https://api.anthropic.com', // 커스텀 엔드포인트
})

const { text } = await generateText({
  model: anthropic('claude-3-5-sonnet-20241022'),
  prompt: 'Hello!',
})
```

### 사용 가능한 모델

| 모델 | 설명 |
|------|------|
| `claude-3-5-sonnet-20241022` | Claude 3.5 Sonnet (최신) |
| `claude-3-5-haiku-20241022` | Claude 3.5 Haiku (빠름) |
| `claude-3-opus-20240229` | Claude 3 Opus (강력) |
| `claude-3-sonnet-20240229` | Claude 3 Sonnet |
| `claude-3-haiku-20240307` | Claude 3 Haiku |

### 환경 변수

```bash
ANTHROPIC_API_KEY=sk-ant-...
```

---

## Google (Gemini)

### 기본 사용

```typescript
import { google } from '@ai-sdk/google'
import { generateText } from 'ai'

const { text } = await generateText({
  model: google('gemini-1.5-pro'),
  prompt: 'What is machine learning?',
})
```

### 커스텀 설정

```typescript
import { createGoogleGenerativeAI } from '@ai-sdk/google'

const google = createGoogleGenerativeAI({
  apiKey: process.env.GOOGLE_GENERATIVE_AI_API_KEY,
})

const { text } = await generateText({
  model: google('gemini-1.5-pro'),
  prompt: 'Hello!',
})
```

### 사용 가능한 모델

| 모델 | 설명 |
|------|------|
| `gemini-1.5-pro` | Gemini 1.5 Pro |
| `gemini-1.5-flash` | Gemini 1.5 Flash (빠름) |
| `gemini-2.0-flash-exp` | Gemini 2.0 Flash (실험) |

### 환경 변수

```bash
GOOGLE_GENERATIVE_AI_API_KEY=...
```

---

## Google Vertex AI

Vertex AI는 Google Cloud 환경에서 사용합니다.

### 설치

```bash
npm install @ai-sdk/google-vertex
```

### 기본 사용

```typescript
import { vertex } from '@ai-sdk/google-vertex'
import { generateText } from 'ai'

const { text } = await generateText({
  model: vertex('gemini-1.5-pro'),
  prompt: 'Hello!',
})
```

### Vertex AI + Anthropic

```typescript
import { vertexAnthropic } from '@ai-sdk/google-vertex/anthropic'
import { generateText } from 'ai'

const { text } = await generateText({
  model: vertexAnthropic('claude-3-5-sonnet@20240620'),
  prompt: 'Write a poem.',
})
```

### 커스텀 설정

```typescript
import { createVertexAnthropic } from '@ai-sdk/google-vertex/anthropic'

const vertexAnthropic = createVertexAnthropic({
  project: 'my-project-id',
  location: 'us-central1',
})

// Edge 런타임용
import { createVertexAnthropic } from '@ai-sdk/google-vertex/anthropic/edge'
```

### 환경 변수

```bash
GOOGLE_VERTEX_PROJECT=my-project-id
GOOGLE_VERTEX_LOCATION=us-central1
```

---

## Groq

### 설치

```bash
npm install @ai-sdk/groq
```

### 기본 사용

```typescript
import { groq } from '@ai-sdk/groq'
import { generateText } from 'ai'

const { text } = await generateText({
  model: groq('llama-3.1-70b-versatile'),
  prompt: 'Hello!',
})
```

### 환경 변수

```bash
GROQ_API_KEY=gsk_...
```

---

## Mistral

### 설치

```bash
npm install @ai-sdk/mistral
```

### 기본 사용

```typescript
import { mistral } from '@ai-sdk/mistral'
import { generateText } from 'ai'

const { text } = await generateText({
  model: mistral('mistral-large-latest'),
  prompt: 'Hello!',
})
```

### 환경 변수

```bash
MISTRAL_API_KEY=...
```

---

## AI Gateway (통합 프로바이더)

AI Gateway는 여러 프로바이더를 하나의 인터페이스로 통합합니다.

```typescript
import { gateway } from 'ai'
import { generateText } from 'ai'

const { text } = await generateText({
  model: gateway('openai/gpt-4o'), // 프로바이더/모델 형식
  prompt: 'Hello!',
})

// 다른 프로바이더도 동일한 방식
const { text: text2 } = await generateText({
  model: gateway('anthropic/claude-3-5-sonnet'),
  prompt: 'Hello!',
})
```

---

## 프로바이더 비교

| 프로바이더 | 장점 | 단점 |
|-----------|------|------|
| **OpenAI** | 가장 다양한 모델, 안정적 | 비용이 높을 수 있음 |
| **Anthropic** | 긴 컨텍스트, 안전성 | 모델 종류 적음 |
| **Google** | 멀티모달 강점, 무료 티어 | API 제한 |
| **Groq** | 매우 빠른 추론 속도 | 모델 종류 제한 |
| **Mistral** | 유럽 데이터 레지던시, 오픈소스 | 상대적으로 새로운 서비스 |

---

## 모델 파라미터

모든 프로바이더에서 공통으로 사용 가능한 파라미터:

```typescript
const { text } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',

  // 공통 파라미터
  temperature: 0.7,        // 창의성 (0-2, 기본 1)
  maxTokens: 1000,         // 최대 토큰 수
  topP: 0.9,               // 핵 샘플링
  frequencyPenalty: 0.5,   // 반복 억제
  presencePenalty: 0.5,    // 새로운 주제 유도
  stopSequences: ['\n\n'], // 생성 중단 시퀀스
})
```

---

## OpenRouter (통합 게이트웨이)

하나의 API 키로 수백 개 모델에 접근할 수 있는 통합 게이트웨이입니다.

### 설치

```bash
npm install @openrouter/ai-sdk-provider
```

### 기본 사용

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { generateText } from 'ai'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

const { text } = await generateText({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  prompt: 'Hello!',
})
```

### 인기 모델

| 모델 ID | 설명 |
|---------|------|
| `anthropic/claude-3.5-sonnet` | Claude 3.5 Sonnet |
| `openai/gpt-4o` | GPT-4o |
| `google/gemini-pro-1.5` | Gemini Pro 1.5 |
| `meta-llama/llama-3.1-70b-instruct` | Llama 3.1 70B |

자세한 내용: [OpenRouter 가이드](./openrouter.md)

---

## 환경 변수 요약

```bash
# .env

# OpenAI
OPENAI_API_KEY=sk-...

# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# Google
GOOGLE_GENERATIVE_AI_API_KEY=...

# Google Vertex AI
GOOGLE_VERTEX_PROJECT=my-project
GOOGLE_VERTEX_LOCATION=us-central1

# Groq
GROQ_API_KEY=gsk_...

# Mistral
MISTRAL_API_KEY=...

# OpenRouter
OPENROUTER_API_KEY=sk-or-v1-...
```
