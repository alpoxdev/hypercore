# Zod - 기본 타입

## 문자열

```typescript
z.string()
z.string().min(1).max(100).length(5)
z.string().regex(/^\d+$/)
z.string().trim().toLowerCase().toUpperCase()
```

### v4 최상위 포맷 API

```typescript
z.email()    z.url()      z.uuid()     z.base64()
z.nanoid()   z.cuid()     z.cuid2()    z.ulid()
z.ipv4()     z.ipv6()     z.cidrv4()   z.cidrv6()

z.iso.date()      // 2024-01-15
z.iso.time()      // 14:30:00
z.iso.datetime()  // ISO 날짜시간
z.iso.duration()  // P1D, PT1H
```

### 템플릿 리터럴 (v4)

```typescript
const css = z.templateLiteral([z.number(), z.enum(["px", "em", "rem"])])
// `${number}px` | `${number}em` | `${number}rem`
```

## 숫자

```typescript
z.number()
z.number().min(0).max(100).int()
z.number().positive().negative().nonnegative().nonpositive()
z.number().finite().safe()
```

## 불리언

```typescript
z.boolean()

// v4 문자열 불리언 (환경변수용)
z.stringbool()  // "true"/"yes"/"1" → true, "false"/"no"/"0" → false
```

## 날짜/BigInt/리터럴

```typescript
z.date().min(new Date('2020-01-01')).max(new Date('2030-12-31'))
z.bigint().positive().negative()
z.literal('hello')  z.literal(42)  z.literal(true)
```

## 특수 타입

```typescript
z.null()       z.undefined()    z.void()
z.any()        z.unknown()      z.never()
```

## 수정자

```typescript
z.string().optional()   // string | undefined
z.string().nullable()   // string | null
z.string().nullish()    // string | null | undefined
z.string().default('Anonymous')

type T = z.infer<typeof schema>
```
