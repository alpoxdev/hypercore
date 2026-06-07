#!/usr/bin/env node
import fs from 'node:fs'
import path from 'node:path'

const root = path.resolve('skills/vite-architecture')
const required = [
  'SKILL.md',
  'SKILL.ko.md',
  'architecture-rules.md',
  'architecture-rules.ko.md',
  'rules/conventions.md',
  'rules/conventions.ko.md',
  'rules/routes.md',
  'rules/routes.ko.md',
  'rules/services.md',
  'rules/services.ko.md',
  'rules/hooks.md',
  'rules/hooks.ko.md',
  'rules/execution-model.md',
  'rules/execution-model.ko.md',
  'rules/platform.md',
  'rules/platform.ko.md',
  'rules/validation.md',
  'rules/validation.ko.md',
  'references/official/current-docs-2026-06-02.md',
  'references/official/current-docs-2026-06-02.ko.md',
]

const mustContain = {
  'SKILL.md': ['instruction_contract', 'activation_examples', 'routing_rule', 'rules/validation.md', 'current-docs-2026-06-02', 'src/lib', 'src/services'],
  'SKILL.ko.md': ['instruction_contract', 'activation_examples', 'routing_rule', 'rules/validation.ko.md', 'current-docs-2026-06-02', 'src/lib', 'src/services'],
  'architecture-rules.md': ['Shared Nested Folder Grouping', 'src/lib/<domain>', 'src/services/<domain-or-provider>', 'direct leaf', 'repo-local convention', 'not official Vite', 'routeTree.gen.ts'],
  'rules/services.md': ['services/<domain>', 'services/<domain-or-provider>', 'direct leaf', 'services/index.ts', 'VITE_API_URL'],
  'rules/platform.md': ['tanstackRouter', 'react()', 'routeTree.gen.ts', 'current-docs-2026-06-02', 'VITE_*'],
  'rules/validation.md': ['Skill Anatomy Validation', 'current-docs-2026-06-02', 'src/services', 'direct leaf', 'Deprecated feature-folder guidance is absent'],
  'references/official/current-docs-2026-06-02.md': ['checked_at: 2026-06-02', '/websites/vite_dev', '/tanstack/router', 'VITE_', 'loadEnv', 'tanstackRouter', 'routeTree.gen.ts', 'validateSearch', 'zodValidator', 'not official Vite'],
}

const errors = []
for (const rel of required) {
  if (!fs.existsSync(path.join(root, rel))) errors.push(`missing required file: ${rel}`)
}

for (const [rel, needles] of Object.entries(mustContain)) {
  const file = path.join(root, rel)
  if (!fs.existsSync(file)) continue
  const text = fs.readFileSync(file, 'utf8')
  for (const needle of needles) {
    if (!text.includes(needle)) errors.push(`${rel} missing required phrase: ${needle}`)
  }
}

const forbidden = [
  `src/${'features'}`,
  `${'features'}/`,
  `${'feature'} layer`,
  `${'features'}<`,
]
const mdFiles = []
function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) walk(full)
    else if (entry.isFile() && entry.name.endsWith('.md')) mdFiles.push(full)
  }
}
walk(root)
for (const file of mdFiles) {
  const rel = path.relative(root, file)
  const text = fs.readFileSync(file, 'utf8')
  if ((text.match(/```/g) || []).length % 2 !== 0) errors.push(`${rel} has unbalanced code fences`)
  for (const bad of forbidden) {
    if (text.includes(bad)) errors.push(`${rel} contains forbidden feature-folder guidance: ${bad}`)
  }
  if (!rel.endsWith('.ko.md')) {
    const koRel = rel.replace(/\.md$/, '.ko.md')
    if (!fs.existsSync(path.join(root, koRel))) errors.push(`${rel} missing Korean sibling ${koRel}`)
  }
}

const skill = fs.readFileSync(path.join(root, 'SKILL.md'), 'utf8')
const skillLines = skill.split('\n').length
if (skillLines > 330) errors.push(`SKILL.md too long: ${skillLines} lines > 330`)

const directLinks = [...skill.matchAll(/`([^`]+\.md)`/g)].map((m) => m[1])
for (const link of directLinks) {
  if (link.includes('../')) errors.push(`upward reference not allowed in SKILL.md: ${link}`)
  if (link.split('/').length > 3) errors.push(`reference chain too deep from SKILL.md: ${link}`)
}

if (errors.length) {
  console.error('vite-architecture skill validation failed:')
  for (const error of errors) console.error(`- ${error}`)
  process.exit(1)
}

console.log(JSON.stringify({
  ok: true,
  skillLines,
  checkedFiles: required.length,
  checkedMarkdownFiles: mdFiles.length,
  checks: ['required-files', 'current-docs', 'nested-shared-folders', 'no-feature-guidance', 'core-size', 'korean-siblings', 'reference-depth'],
}, null, 2))
