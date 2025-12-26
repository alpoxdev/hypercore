#!/usr/bin/env python3
"""
커맨드 검증 스크립트 - 최소 버전
"""

import sys
import re
from pathlib import Path


def validate_command(command_path):
    """
    커맨드 파일 기본 검증.

    Args:
        command_path: .md 커맨드 파일 경로

    Returns:
        (유효 여부, 메시지) 튜플
    """
    command_path = Path(command_path)

    # 파일 존재 확인
    if not command_path.exists():
        return False, f"커맨드 파일을 찾을 수 없음: {command_path}"

    # 파일 확장자 확인
    if command_path.suffix != '.md':
        return False, "커맨드 파일은 .md 확장자여야 합니다"

    # 파일명 규칙 확인
    name = command_path.stem
    if not re.match(r'^[a-z0-9-]+$', name):
        return False, f"커맨드 이름 '{name}'은 하이픈-케이스여야 합니다 (소문자, 숫자, 하이픈만 허용)"

    if name.startswith('-') or name.endswith('-') or '--' in name:
        return False, f"커맨드 이름 '{name}'은 하이픈으로 시작/끝나거나 연속된 하이픈을 포함할 수 없습니다"

    if len(name) > 40:
        return False, f"커맨드 이름 '{name}'이 40자를 초과합니다"

    # 내용 읽기
    try:
        content = command_path.read_text()
    except Exception as e:
        return False, f"파일 읽기 오류: {e}"

    # 빈 파일 확인
    if not content.strip():
        return False, "커맨드 파일이 비어있습니다"

    # frontmatter가 있으면 검증
    if content.startswith('---'):
        match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
        if not match:
            return False, "잘못된 frontmatter 형식 (닫는 --- 누락)"

        frontmatter = match.group(1)

        # 허용된 frontmatter 필드 검증
        valid_fields = {'description', 'allowed-tools', 'argument-hint', 'model', 'disable-model-invocation'}
        for line in frontmatter.split('\n'):
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if ':' in line:
                field = line.split(':')[0].strip()
                if field and field not in valid_fields:
                    return False, f"알 수 없는 frontmatter 필드: '{field}'"

        # description 확인
        desc_match = re.search(r'description:\s*(.+)', frontmatter)
        if desc_match:
            description = desc_match.group(1).strip()
            if '<' in description or '>' in description:
                return False, "description에 꺾쇠괄호(< 또는 >)를 포함할 수 없습니다"
            if '[TODO' in description:
                return False, "description에 TODO 플레이스홀더가 있습니다 - 완성해주세요"

        # frontmatter 이후 내용 확인
        body = content[match.end():].strip()
        if not body:
            return False, "커맨드에 frontmatter만 있고 지시사항이 없습니다"

    return True, "커맨드가 유효합니다!"


def validate_commands_folder(folder_path):
    """
    폴더 내 모든 커맨드 파일 검증.

    Args:
        folder_path: .md 파일이 포함된 폴더 경로

    Returns:
        (전체 유효 여부, 결과 리스트) 튜플
    """
    folder_path = Path(folder_path)

    if not folder_path.exists():
        return False, [("folder", False, f"폴더를 찾을 수 없음: {folder_path}")]

    if not folder_path.is_dir():
        return False, [("path", False, f"경로가 디렉토리가 아님: {folder_path}")]

    # 모든 .md 파일 찾기
    md_files = list(folder_path.glob('**/*.md'))

    if not md_files:
        return False, [("folder", False, "폴더에 .md 파일이 없습니다")]

    results = []
    all_valid = True

    for md_file in md_files:
        valid, message = validate_command(md_file)
        results.append((md_file.name, valid, message))
        if not valid:
            all_valid = False

    return all_valid, results


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("사용법: python quick_validate.py <command.md 또는 commands-폴더>")
        sys.exit(1)

    path = Path(sys.argv[1])

    if path.is_file():
        valid, message = validate_command(path)
        print(message)
        sys.exit(0 if valid else 1)
    elif path.is_dir():
        all_valid, results = validate_commands_folder(path)
        for name, valid, message in results:
            status = "✅" if valid else "❌"
            print(f"[{status}] {name}: {message}")
        sys.exit(0 if all_valid else 1)
    else:
        print(f"경로를 찾을 수 없음: {path}")
        sys.exit(1)
