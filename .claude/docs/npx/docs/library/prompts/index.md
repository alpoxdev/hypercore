# prompts

> Interactive CLI prompts

<patterns>

```typescript
import prompts from 'prompts';

// Text
const { name } = await prompts({
  type: 'text',
  name: 'name',
  message: 'What is your name?',
  initial: 'Anonymous',
});

// Confirm
const { confirmed } = await prompts({
  type: 'confirm',
  name: 'confirmed',
  message: 'Continue?',
  initial: true,
});

// Select
const { template } = await prompts({
  type: 'select',
  name: 'template',
  message: 'Select a template:',
  choices: [
    { title: 'React', description: 'React framework', value: 'react' },
    { title: 'Vue', description: 'Vue framework', value: 'vue' },
  ],
  initial: 0,
});

// Multiselect
const { features } = await prompts({
  type: 'multiselect',
  name: 'features',
  message: 'Select features:',
  choices: [
    { title: 'TypeScript', value: 'typescript', selected: true },
    { title: 'ESLint', value: 'eslint' },
  ],
  min: 1,
  max: 5,
  hint: '- Space to select. Return to submit',
});

// Number
const { port } = await prompts({
  type: 'number',
  name: 'port',
  message: 'Port number?',
  initial: 3000,
  min: 1,
  max: 65535,
});

// Password
const { secret } = await prompts({
  type: 'password',
  name: 'secret',
  message: 'Enter password:',
});

// Handle cancellation
const { template } = await prompts({ /* ... */ });

if (!template) {
  console.log('Operation cancelled.');
  process.exit(0);
}

// Multiple questions
const response = await prompts([
  { type: 'text', name: 'name', message: 'Project name?' },
  { type: 'select', name: 'template', message: 'Template?', choices: [...] },
  { type: 'confirm', name: 'git', message: 'Initialize git?' },
]);

// Conditional questions
const response = await prompts([
  { type: 'confirm', name: 'useTypescript', message: 'Use TypeScript?' },
  { type: (prev) => prev ? 'confirm' : null, name: 'strict', message: 'Enable strict mode?' },
]);

// Autocomplete
const { package } = await prompts({
  type: 'autocomplete',
  name: 'package',
  message: 'Search package:',
  choices: [
    { title: 'react' },
    { title: 'vue' },
  ],
  suggest: (input, choices) => {
    return choices.filter((c) =>
      c.title.toLowerCase().includes(input.toLowerCase())
    );
  },
});
```

</patterns>
