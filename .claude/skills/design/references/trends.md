# 2024-2026 Design Trends

<ai_integration>

## AI 통합 UI

```tsx
{/* AI 어시스턴트 입력 */}
<div className="flex gap-3 p-4 border rounded-2xl">
  <textarea
    className="flex-1 resize-none focus:outline-none"
    placeholder="Ask AI anything..."
  />
  <button className="w-10 h-10 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 text-white">
    <svg className="w-5 h-5" />
  </button>
</div>
```

</ai_integration>

---

<micro_interactions>

## 마이크로인터랙션

```tsx
<button className="group relative overflow-hidden">
  <span className="relative z-10">Hover me</span>
  <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
</button>
```

</micro_interactions>

---

<dark_mode>

## 다크모드

```tsx
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">
  <button className="bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700">
    Theme toggle
  </button>
</div>
```

</dark_mode>

---

<spatial_design>

## 3D & 공간 디자인

### Glassmorphism

```tsx
<div className="backdrop-blur-lg bg-white/10 border border-white/20 rounded-2xl p-6">
  <h3 className="font-semibold">Glass card</h3>
</div>
```

### Neumorphism

```tsx
<div className="bg-gray-100 rounded-2xl p-6 shadow-[8px_8px_16px_#bebebe,-8px_-8px_16px_#ffffff]">
  <h3 className="font-semibold">Neomorphic card</h3>
</div>
```

</spatial_design>
