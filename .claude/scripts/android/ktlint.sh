#!/bin/bash
# ktlint 실행 및 결과 파싱

show_help() {
    cat << EOF
사용법: ktlint.sh [OPTIONS] [PATH]

OPTIONS:
  -c, --check    검사만 (수정 안함)
  -f, --format   자동 수정 (기본)
  -h, --help     도움말

PATH:
  특정 파일/디렉토리 지정 (선택)

EXAMPLES:
  ktlint.sh                           # 전체 format
  ktlint.sh -c                        # 전체 check만
  ktlint.sh app/src/main/java/...     # 특정 경로
EOF
}

MODE="format"
TARGET_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--check) MODE="check"; shift ;;
        -f|--format) MODE="format"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) TARGET_PATH="$1"; shift ;;
    esac
done

if [[ "$MODE" == "format" ]]; then
    TASK="ktlintFormat"
    echo "🔧 ktlint Format 실행..."
else
    TASK="ktlintCheck"
    echo "🔍 ktlint Check 실행..."
fi

echo "---"

./gradlew $TASK 2>&1 | tee /tmp/ktlint_output.txt

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "---"

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✅ ktlint 완료"
else
    echo "❌ ktlint 오류 발견"
    echo ""
    echo "📋 오류 목록:"
    grep -E "\.kt:\d+:\d+:" /tmp/ktlint_output.txt | head -20
fi

exit $EXIT_CODE
