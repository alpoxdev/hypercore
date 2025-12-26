#!/usr/bin/env python3
"""
커맨드 패키저 - 커맨드 파일을 배포용 zip 파일로 생성

사용법:
    python package_command.py <commands-폴더-경로> [출력-디렉토리]
    python package_command.py <command.md-경로> [출력-디렉토리]

예시:
    python package_command.py .claude/commands
    python package_command.py .claude/commands ./dist
    python package_command.py .claude/commands/review-security.md
"""

import sys
import zipfile
from pathlib import Path
from quick_validate import validate_command, validate_commands_folder


def package_commands(source_path, output_dir=None):
    """
    커맨드 파일(들)을 zip 파일로 패키징.

    Args:
        source_path: 커맨드 파일 또는 커맨드 폴더 경로
        output_dir: zip 파일 출력 디렉토리 (선택)

    Returns:
        생성된 zip 파일 경로, 오류 시 None
    """
    source_path = Path(source_path).resolve()

    # 소스 존재 확인
    if not source_path.exists():
        print(f"❌ 오류: 경로를 찾을 수 없음: {source_path}")
        return None

    # 단일 파일인지 폴더인지 확인
    is_folder = source_path.is_dir()

    # 패키징 전 검증
    print("🔍 커맨드 검증 중...")

    if is_folder:
        valid, results = validate_commands_folder(source_path)
        for name, v, message in results:
            status = "✅" if v else "❌"
            print(f"  [{status}] {name}: {message}")
        if not valid:
            print("\n❌ 검증 실패. 패키징 전에 오류를 수정해주세요.")
            return None
        print(f"\n✅ 모든 {len(results)}개 커맨드 검증 완료.\n")
    else:
        valid, message = validate_command(source_path)
        if not valid:
            print(f"  ❌ 검증 실패: {message}")
            print("\n패키징 전에 검증 오류를 수정해주세요.")
            return None
        print(f"  ✅ {message}\n")

    # 출력 위치 결정
    if is_folder:
        zip_name = source_path.name
    else:
        zip_name = source_path.stem

    if output_dir:
        output_path = Path(output_dir).resolve()
        output_path.mkdir(parents=True, exist_ok=True)
    else:
        output_path = Path.cwd()

    zip_filename = output_path / f"{zip_name}-commands.zip"

    # zip 파일 생성
    try:
        with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
            if is_folder:
                # 폴더의 모든 .md 파일 추가
                for md_file in source_path.glob('**/*.md'):
                    arcname = md_file.relative_to(source_path.parent)
                    zipf.write(md_file, arcname)
                    print(f"  📦 추가: {arcname}")
            else:
                # 단일 파일 추가
                arcname = source_path.name
                zipf.write(source_path, arcname)
                print(f"  📦 추가: {arcname}")

        print(f"\n✅ 패키징 완료: {zip_filename}")
        return zip_filename

    except Exception as e:
        print(f"❌ zip 파일 생성 오류: {e}")
        return None


def main():
    if len(sys.argv) < 2:
        print("사용법: python package_command.py <commands-경로> [출력-디렉토리]")
        print("\n예시:")
        print("  python package_command.py .claude/commands")
        print("  python package_command.py .claude/commands ./dist")
        print("  python package_command.py .claude/commands/review-security.md")
        sys.exit(1)

    source_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None

    print(f"📦 커맨드 패키징: {source_path}")
    if output_dir:
        print(f"   출력 디렉토리: {output_dir}")
    print()

    result = package_commands(source_path, output_dir)

    if result:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
