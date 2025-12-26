#!/usr/bin/env python3
"""
커맨드 초기화 스크립트 - 템플릿에서 새 슬래시 커맨드 생성

사용법:
    init_command.py <커맨드명> --path <경로>
    init_command.py <커맨드명> --project
    init_command.py <커맨드명> --personal

예시:
    init_command.py review-security --path .claude/commands
    init_command.py commit-fix --project
    init_command.py my-helper --personal
"""

import sys
import os
from pathlib import Path


COMMAND_TEMPLATE = """---
description: [TODO: 커맨드가 하는 일에 대한 간단한 설명]
allowed-tools: [TODO: 필요한 도구 목록, 예: Bash(git:*), Read, Write]
argument-hint: [TODO: 예상 인자, 예: <file> <type>]
---

# {command_title}

[TODO: 여기에 커맨드 지시사항 작성]

## 예시 패턴

### 인자 사용하기

모든 인자를 단일 문자열로:
```
다음을 처리하세요: $ARGUMENTS
```

위치 인자:
```
$1 파일을 $2 우선순위로 검토하세요
```

### 컨텍스트 포함하기

파일 내용:
```
@$1 의 코드를 검토하세요
```

셸 출력:
```
현재 상태: !`git status`
```

### 일반적인 지시사항

[TODO: 실제 커맨드 지시사항으로 대체. 예시:]

**코드 리뷰용:**
```
다음 코드를 검토하세요:
- 보안 취약점
- 성능 이슈
- 코드 스타일 위반

@$ARGUMENTS
```

**커밋 생성용:**
```
다음 형식으로 git 커밋 생성:
- 타입: $1
- 메시지: $2

컨벤셔널 커밋 형식을 따르세요.
```

**테스트 생성용:**
```
@$1 의 코드에 대한 유닛 테스트 생성

포함할 것:
- 엣지 케이스
- 에러 처리
- 해피 패스 시나리오
```

---

이 템플릿 내용을 삭제하고 위에 실제 커맨드 지시사항을 작성하세요.
"""

SIMPLE_TEMPLATE = """---
description: {description}
allowed-tools: {tools}
argument-hint: {hint}
---

{instructions}
"""


def title_case_command_name(command_name):
    """하이픈으로 구분된 커맨드명을 Title Case로 변환."""
    return ' '.join(word.capitalize() for word in command_name.split('-'))


def get_project_commands_path():
    """프로젝트 커맨드 디렉토리 경로 반환."""
    return Path.cwd() / '.claude' / 'commands'


def get_personal_commands_path():
    """개인 커맨드 디렉토리 경로 반환."""
    return Path.home() / '.claude' / 'commands'


def init_command(command_name, path):
    """
    템플릿으로 새 커맨드 파일 초기화.

    Args:
        command_name: 커맨드 이름 (.md 확장자 제외)
        path: 커맨드 파일이 생성될 경로

    Returns:
        생성된 커맨드 파일 경로, 오류 시 None
    """
    # 커맨드명 검증
    if not command_name:
        print("❌ 오류: 커맨드 이름이 필요합니다")
        return None

    # .md 확장자 제거
    if command_name.endswith('.md'):
        command_name = command_name[:-3]

    # 이름 규칙 검증
    import re
    if not re.match(r'^[a-z0-9-]+$', command_name):
        print(f"❌ 오류: 커맨드 이름 '{command_name}'은 하이픈-케이스여야 합니다")
        print("  (소문자, 숫자, 하이픈만 허용)")
        return None

    if command_name.startswith('-') or command_name.endswith('-') or '--' in command_name:
        print(f"❌ 오류: 커맨드 이름 '{command_name}'은 하이픈으로 시작/끝나거나")
        print("  연속된 하이픈을 포함할 수 없습니다")
        return None

    if len(command_name) > 40:
        print(f"❌ 오류: 커맨드 이름 '{command_name}'이 40자를 초과합니다")
        return None

    # 커맨드 파일 경로 결정
    command_dir = Path(path).resolve()
    command_file = command_dir / f'{command_name}.md'

    # 파일 존재 여부 확인
    if command_file.exists():
        print(f"❌ 오류: 커맨드 파일이 이미 존재합니다: {command_file}")
        return None

    # 필요시 디렉토리 생성
    try:
        command_dir.mkdir(parents=True, exist_ok=True)
    except Exception as e:
        print(f"❌ 오류: 디렉토리 생성 실패: {e}")
        return None

    # 템플릿에서 커맨드 파일 생성
    command_title = title_case_command_name(command_name)
    command_content = COMMAND_TEMPLATE.format(
        command_name=command_name,
        command_title=command_title
    )

    try:
        command_file.write_text(command_content)
        print(f"✅ 커맨드 파일 생성: {command_file}")
    except Exception as e:
        print(f"❌ 오류: 커맨드 파일 생성 실패: {e}")
        return None

    # 다음 단계 안내
    print(f"\n✅ 커맨드 '{command_name}' 초기화 완료!")
    print(f"\n사용법: /{command_name}")
    print("\n다음 단계:")
    print("1. 커맨드 파일을 편집하여 TODO 항목 완성")
    print("2. frontmatter의 description 업데이트")
    print("3. 템플릿 내용을 실제 지시사항으로 교체")
    print(f"4. 커맨드 테스트: /{command_name}")

    return command_file


def main():
    if len(sys.argv) < 3:
        print("사용법: init_command.py <커맨드명> --path <경로>")
        print("       init_command.py <커맨드명> --project")
        print("       init_command.py <커맨드명> --personal")
        print("\n커맨드명 요구사항:")
        print("  - 하이픈-케이스 식별자 (예: 'review-security')")
        print("  - 소문자, 숫자, 하이픈만 허용")
        print("  - 최대 40자")
        print("\n예시:")
        print("  init_command.py review-security --path .claude/commands")
        print("  init_command.py commit-fix --project")
        print("  init_command.py my-helper --personal")
        sys.exit(1)

    command_name = sys.argv[1]
    option = sys.argv[2]

    # 옵션에 따라 경로 결정
    if option == '--project':
        path = get_project_commands_path()
    elif option == '--personal':
        path = get_personal_commands_path()
    elif option == '--path':
        if len(sys.argv) < 4:
            print("❌ 오류: --path는 디렉토리 인자가 필요합니다")
            sys.exit(1)
        path = sys.argv[3]
    else:
        print(f"❌ 오류: 알 수 없는 옵션 '{option}'")
        print("--path <경로>, --project, --personal 중 하나를 사용하세요")
        sys.exit(1)

    print(f"🚀 커맨드 초기화: {command_name}")
    print(f"   위치: {path}")
    print()

    result = init_command(command_name, path)

    if result:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
