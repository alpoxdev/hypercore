---
name: stitch:react
description: 디자인을 모듈형 React 컴포넌트로 변환
---

<purpose>
디자인 자산을 타입 안전하고 모듈화된 React 컴포넌트로 변환
</purpose>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| "React 컴포넌트 생성" | 즉시 실행 |
| "디자인을 컴포넌트로" | 즉시 실행 |
| "UI 컴포넌트 구현" | 즉시 실행 |

</trigger_conditions>

---

<workflow>

<step number="1">
<action>디자인 자산 분석</action>
<tools>Read</tools>
<details>
- 디자인 파일(Figma, Sketch, DESIGN.md) 읽기
- 색상, 타이포, 간격 정보 추출
- 컴포넌트 구조 파악
</details>
</step>

<step number="2">
<action>아키텍처 설계</action>
<tools>-</tools>
<details>
| 분류 | 위치 | 목적 |
|------|------|------|
| 컴포넌트 | `src/components/` | 재사용 가능 UI |
| 훅 | `src/hooks/` | 비즈니스 로직 분리 |
| 데이터 | `src/data/mockData.ts` | 정적 콘텐츠 |
| 타입 | `src/types/` | TypeScript 인터페이스 |
</details>
</step>

<step number="3">
<action>컴포넌트 구현</action>
<tools>Write</tools>
<details>
**원칙:**
- 하나의 파일 = 하나의 컴포넌트
- Props는 TypeScript 인터페이스로 정의
- Tailwind 클래스 사용 (하드코딩 금지)
- 접근성(a11y) 고려

**구조:**
```typescript
interface ButtonProps {
  readonly variant: 'primary' | 'secondary';
  readonly children: React.ReactNode;
  readonly onClick?: () => void;
}

export function Button({ variant, children, onClick }: ButtonProps) {
  return (
    <button
      className={variant === 'primary' ? 'bg-primary' : 'bg-secondary'}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```
</details>
</step>

<step number="4">
<action>Tailwind 설정 동기화</action>
<tools>Edit</tools>
<details>
DESIGN.md의 색상/타이포 → `tailwind.config.ts`
```typescript
export default {
  theme: {
    extend: {
      colors: {
        primary: '#3B82F6',
        secondary: '#64748B',
      },
    },
  },
}
```
</details>
</step>

<step number="5">
<action>검증</action>
<tools>Bash</tools>
<details>
```bash
# TypeScript 타입 체크
npx tsc --noEmit

# 린트
npx eslint src/

# 빌드 테스트
npm run build
```
</details>
</step>

</workflow>

---

<architecture_rules>

## 금지

| 패턴 | 이유 |
|------|------|
| 단일 파일에 모든 컴포넌트 | 유지보수 어려움 |
| 하드코딩된 색상 (`#3B82F6`) | 테마 변경 불가 |
| 인라인 스타일 | 일관성 저하 |
| any 타입 | 타입 안전성 상실 |

## 필수

| 패턴 | 이유 |
|------|------|
| 컴포넌트당 1파일 | 명확한 구조 |
| Tailwind 클래스 | 테마 통합 |
| TypeScript 인터페이스 | 타입 안전성 |
| Readonly Props | 불변성 보장 |

</architecture_rules>

---

<examples>

## Button 컴포넌트

**입력 (DESIGN.md):**
```markdown
### 버튼
- Primary: 파란색 배경, 흰색 텍스트
- Secondary: 회색 배경, 검은색 텍스트
- 모서리: 8px 라운드
- 패딩: 상하 12px, 좌우 24px
```

**출력:**
```typescript
// src/components/Button.tsx
interface ButtonProps {
  readonly variant: 'primary' | 'secondary';
  readonly children: React.ReactNode;
  readonly onClick?: () => void;
  readonly disabled?: boolean;
}

export function Button({
  variant,
  children,
  onClick,
  disabled
}: ButtonProps) {
  const baseClasses = 'rounded-lg px-6 py-3 font-medium transition-colors';
  const variantClasses = {
    primary: 'bg-primary text-white hover:bg-primary-dark',
    secondary: 'bg-secondary text-black hover:bg-secondary-dark',
  };

  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]}`}
      onClick={onClick}
      disabled={disabled}
      aria-disabled={disabled}
    >
      {children}
    </button>
  );
}
```

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#3B82F6',
          dark: '#2563EB',
        },
        secondary: {
          DEFAULT: '#64748B',
          dark: '#475569',
        },
      },
    },
  },
}
```

---

## Card 컴포넌트

**입력:**
```markdown
### 카드
- 배경: 흰색
- 테두리: 연한 회색 1px
- 그림자: 부드러운 그림자
- 패딩: 24px
```

**출력:**
```typescript
// src/components/Card.tsx
interface CardProps {
  readonly children: React.ReactNode;
  readonly className?: string;
}

export function Card({ children, className = '' }: CardProps) {
  return (
    <div className={`bg-white border border-gray-200 rounded-xl p-6 shadow-sm ${className}`}>
      {children}
    </div>
  );
}
```

</examples>

---

<custom_hook_pattern>

**비즈니스 로직 분리:**

```typescript
// src/hooks/useUserData.ts
import { useState, useEffect } from 'react';

interface User {
  readonly id: string;
  readonly name: string;
}

export function useUserData(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchUser() {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      setUser(data);
      setLoading(false);
    }
    fetchUser();
  }, [userId]);

  return { user, loading };
}
```

**컴포넌트에서 사용:**
```typescript
// src/components/UserProfile.tsx
import { useUserData } from '@/hooks/useUserData';

export function UserProfile({ userId }: { userId: string }) {
  const { user, loading } = useUserData(userId);

  if (loading) return <div>Loading...</div>;
  return <div>{user?.name}</div>;
}
```

</custom_hook_pattern>

---

<validation>

**체크리스트:**
- [ ] 컴포넌트당 1파일
- [ ] TypeScript 인터페이스 정의
- [ ] Props에 `readonly` 사용
- [ ] Tailwind 클래스만 사용 (하드코딩 금지)
- [ ] 접근성(aria-*) 속성 추가
- [ ] 비즈니스 로직은 Custom Hook으로 분리
- [ ] `tsc --noEmit` 통과
- [ ] `eslint` 통과

</validation>

---

<best_practices>

| 원칙 | 방법 |
|------|------|
| **모듈화** | 작은 단위로 분리 |
| **타입 안전성** | `any` 금지, 명시적 타입 |
| **불변성** | `readonly` Props |
| **테마 통합** | Tailwind 설정 활용 |
| **접근성** | ARIA 속성, 시맨틱 HTML |
| **로직 분리** | UI ≠ 비즈니스 로직 |

</best_practices>
