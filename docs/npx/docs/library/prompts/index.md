# prompts 가이드

> Interactive CLI prompts

---

## 기본 Import

```typescript
import prompts from 'prompts';
```

---

## Text Input

```typescript
const response = await prompts({
  type: 'text',
  name: 'name',
  message: 'What is your name?',
  initial: 'Anonymous',
});

console.log(response.name);
```

---

## Confirm (Yes/No)

```typescript
const response = await prompts({
  type: 'confirm',
  name: 'confirmed',
  message: 'Continue?',
  initial: true,
});

if (response.confirmed) {
  // Yes
}
```

---

## Select (단일 선택)

```typescript
const response = await prompts({
  type: 'select',
  name: 'template',
  message: 'Select a template:',
  choices: [
    { title: 'React', description: 'React framework', value: 'react' },
    { title: 'Vue', description: 'Vue framework', value: 'vue' },
    { title: 'Angular', description: 'Angular framework', value: 'angular' },
  ],
  initial: 0, // 첫 번째 선택
});

console.log(response.template); // 'react' | 'vue' | 'angular'
```

---

## Multiselect (다중 선택)

```typescript
const response = await prompts({
  type: 'multiselect',
  name: 'features',
  message: 'Select features:',
  choices: [
    { title: 'TypeScript', value: 'typescript', selected: true },
    { title: 'ESLint', value: 'eslint' },
    { title: 'Prettier', value: 'prettier' },
  ],
  min: 1,  // 최소 1개 선택
  max: 5,  // 최대 5개 선택
  hint: '- Space to select. Return to submit',
});

console.log(response.features); // ['typescript', 'eslint']
```

---

## Number Input

```typescript
const response = await prompts({
  type: 'number',
  name: 'port',
  message: 'Port number?',
  initial: 3000,
  min: 1,
  max: 65535,
});

console.log(response.port); // number
```

---

## Password Input

```typescript
const response = await prompts({
  type: 'password',
  name: 'secret',
  message: 'Enter password:',
});

console.log(response.secret);
```

---

## 취소 처리

```typescript
const response = await prompts({
  type: 'select',
  name: 'template',
  message: 'Select:',
  choices: [...],
});

// Ctrl+C 또는 ESC 시 undefined
if (!response.template) {
  console.log('Operation cancelled.');
  process.exit(0);
}
```

---

## 연속 질문

```typescript
const response = await prompts([
  {
    type: 'text',
    name: 'name',
    message: 'Project name?',
  },
  {
    type: 'select',
    name: 'template',
    message: 'Template?',
    choices: [...],
  },
  {
    type: 'confirm',
    name: 'git',
    message: 'Initialize git?',
  },
]);

console.log(response.name);
console.log(response.template);
console.log(response.git);
```

---

## 조건부 질문

```typescript
const response = await prompts([
  {
    type: 'confirm',
    name: 'useTypescript',
    message: 'Use TypeScript?',
  },
  {
    type: (prev) => prev ? 'confirm' : null, // 이전 답변이 true일 때만
    name: 'strict',
    message: 'Enable strict mode?',
  },
]);
```

---

## Autocomplete

```typescript
const response = await prompts({
  type: 'autocomplete',
  name: 'package',
  message: 'Search package:',
  choices: [
    { title: 'react' },
    { title: 'react-dom' },
    { title: 'react-router' },
    { title: 'vue' },
    { title: 'angular' },
  ],
  suggest: (input, choices) => {
    return choices.filter((c) =>
      c.title.toLowerCase().includes(input.toLowerCase())
    );
  },
});
```

---

## 전체 예시

```typescript
import prompts from 'prompts';

const run = async () => {
  // 템플릿 선택
  const { templates } = await prompts({
    type: 'multiselect',
    name: 'templates',
    message: 'Select templates (space to select):',
    choices: [
      { title: 'Hono', value: 'hono' },
      { title: 'TanStack Start', value: 'tanstack-start' },
    ],
    min: 1,
    hint: '- Space to select. Return to submit',
  });

  if (!templates || templates.length === 0) {
    console.log('Cancelled.');
    process.exit(0);
  }

  // 덮어쓰기 확인
  const { overwrite } = await prompts({
    type: 'confirm',
    name: 'overwrite',
    message: 'Files exist. Overwrite?',
    initial: false,
  });

  if (!overwrite) {
    console.log('Cancelled.');
    process.exit(0);
  }

  // 실행
  console.log('Selected:', templates);
};

run();
```
