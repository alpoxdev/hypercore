# Serena MCP Server

> **Purpose**: 시맨틱 코드 이해, 프로젝트 메모리, 세션 지속성을 위한 MCP 서버

---

## 프로젝트 시작 전 필수 확인

프로젝트 작업을 시작하기 전에 **반드시** Serena가 활성화되어 있는지 확인해야 합니다.

### 1. 현재 설정 확인

```
mcp__serena__get_current_config
```

**확인 사항:**
- `Active project`: 현재 작업할 프로젝트명이 표시되는지 확인
- 프로젝트가 `Available projects` 목록에 있는지 확인

### 2. 프로젝트 활성화

프로젝트가 활성화되지 않은 경우:

```
mcp__serena__activate_project({ project: "프로젝트명" })
```

### 3. 온보딩 확인

새 프로젝트의 경우 온보딩이 필요할 수 있습니다:

```
mcp__serena__check_onboarding_performed
```

온보딩이 필요한 경우:

```
mcp__serena__onboarding
```

---

## 핵심 기능

### 심볼 탐색 (Symbol Navigation)

파일 내 심볼(클래스, 함수, 변수 등) 개요 확인:

```
mcp__serena__get_symbols_overview({ relative_path: "src/index.ts" })
```

특정 심볼 검색:

```
mcp__serena__find_symbol({
  name_path_pattern: "MyClass/myMethod",
  include_body: true,
  depth: 1
})
```

심볼 참조 찾기:

```
mcp__serena__find_referencing_symbols({
  name_path: "MyClass",
  relative_path: "src/my-class.ts"
})
```

### 코드 수정 (Code Modification)

심볼 본문 교체:

```
mcp__serena__replace_symbol_body({
  name_path: "MyClass/myMethod",
  relative_path: "src/my-class.ts",
  body: "새로운 코드 본문"
})
```

심볼 뒤에 코드 삽입:

```
mcp__serena__insert_after_symbol({
  name_path: "MyClass",
  relative_path: "src/my-class.ts",
  body: "\n\nexport const newFunction = () => {}"
})
```

심볼 앞에 코드 삽입:

```
mcp__serena__insert_before_symbol({
  name_path: "MyClass",
  relative_path: "src/my-class.ts",
  body: "import { Something } from './something'\n\n"
})
```

심볼 이름 변경 (전체 코드베이스):

```
mcp__serena__rename_symbol({
  name_path: "oldFunctionName",
  relative_path: "src/utils.ts",
  new_name: "newFunctionName"
})
```

### 파일 탐색 (File Navigation)

디렉토리 목록:

```
mcp__serena__list_dir({
  relative_path: "src",
  recursive: false
})
```

파일 검색:

```
mcp__serena__find_file({
  file_mask: "*.ts",
  relative_path: "src"
})
```

패턴 검색:

```
mcp__serena__search_for_pattern({
  substring_pattern: "createServerFn",
  relative_path: "src/services",
  context_lines_before: 2,
  context_lines_after: 2
})
```

### 메모리 관리 (Memory Management)

프로젝트 관련 정보를 메모리에 저장하여 세션 간 유지:

메모리 목록 확인:

```
mcp__serena__list_memories
```

메모리 읽기:

```
mcp__serena__read_memory({ memory_file_name: "architecture.md" })
```

메모리 작성:

```
mcp__serena__write_memory({
  memory_file_name: "decisions.md",
  content: "# 주요 결정 사항\n\n- API 설계: REST 대신 Server Functions 사용"
})
```

메모리 수정:

```
mcp__serena__edit_memory({
  memory_file_name: "decisions.md",
  needle: "REST 대신",
  repl: "REST API 대신",
  mode: "literal"
})
```

메모리 삭제:

```
mcp__serena__delete_memory({ memory_file_name: "outdated.md" })
```

### 사고 도구 (Thinking Tools)

수집된 정보 검토:

```
mcp__serena__think_about_collected_information
```

작업 목표 준수 확인:

```
mcp__serena__think_about_task_adherence
```

작업 완료 여부 확인:

```
mcp__serena__think_about_whether_you_are_done
```

---

## 사용 시나리오

### 시나리오 1: 새 프로젝트 시작

```
1. get_current_config → 현재 상태 확인
2. activate_project → 프로젝트 활성화
3. check_onboarding_performed → 온보딩 필요 여부 확인
4. onboarding → 필요시 온보딩 진행
5. list_memories → 기존 메모리 확인
```

### 시나리오 2: 기존 프로젝트 재개

```
1. get_current_config → 프로젝트 활성화 확인
2. list_memories → 이전 세션 컨텍스트 확인
3. read_memory → 필요한 메모리 읽기
4. 작업 진행
5. write_memory → 중요 결정/진행 상황 저장
```

### 시나리오 3: 대규모 리팩토링

```
1. get_symbols_overview → 파일 구조 파악
2. find_symbol → 수정할 심볼 찾기
3. find_referencing_symbols → 영향받는 코드 확인
4. replace_symbol_body → 심볼 수정
5. rename_symbol → 필요시 이름 변경
6. think_about_whether_you_are_done → 완료 확인
```

---

## Best Practices

### 1. 항상 프로젝트 활성화 확인

작업 시작 전 `get_current_config`로 올바른 프로젝트가 활성화되어 있는지 확인하세요.

### 2. 심볼 도구 우선 사용

전체 파일을 읽지 말고, `get_symbols_overview`와 `find_symbol`을 사용하여 필요한 부분만 확인하세요.

### 3. 메모리 적극 활용

중요한 결정, 아키텍처 정보, 작업 진행 상황을 메모리에 저장하여 세션 간 컨텍스트를 유지하세요.

### 4. 사고 도구 활용

복잡한 작업 중에는 `think_about_*` 도구를 사용하여 진행 상황을 검토하세요.

---

## 참고 자료

- [Serena GitHub](https://github.com/oraios/serena)
- [MCP Protocol](https://modelcontextprotocol.io)
