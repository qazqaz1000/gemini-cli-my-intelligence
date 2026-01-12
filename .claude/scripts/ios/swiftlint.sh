#!/bin/bash
# SwiftLint 검사 스크립트
# 사용법: ~/.claude/scripts/ios/swiftlint.sh [--fix] [PATH]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 기본값
FIX_MODE=false
TARGET_PATH=""

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            FIX_MODE=true
            shift
            ;;
        *)
            TARGET_PATH="$1"
            shift
            ;;
    esac
done

# 프로젝트 디렉토리 결정
if [ -z "$TARGET_PATH" ]; then
    TARGET_PATH=$(pwd)
fi

cd "$TARGET_PATH"

# SwiftLint 설치 확인
if ! command -v swiftlint &> /dev/null; then
    echo -e "${RED}Error: swiftlint가 설치되어 있지 않습니다${NC}"
    echo "설치: brew install swiftlint"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SwiftLint${NC}"
echo -e "${GREEN}========================================${NC}"

if [ "$FIX_MODE" = true ]; then
    echo -e "${YELLOW}자동 수정 모드로 실행 중...${NC}"
    swiftlint lint --fix --quiet
    echo ""
fi

echo -e "${YELLOW}검사 중...${NC}"
echo ""

# SwiftLint 실행
LINT_OUTPUT=$(swiftlint lint 2>&1) || true
LINT_EXIT_CODE=$?

if [ -z "$LINT_OUTPUT" ]; then
    echo -e "${GREEN}✅ SwiftLint 검사 통과 - 문제 없음${NC}"
else
    echo "$LINT_OUTPUT"

    # 에러/경고 카운트
    ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -c "error:" || echo "0")
    WARNING_COUNT=$(echo "$LINT_OUTPUT" | grep -c "warning:" || echo "0")

    echo ""
    echo -e "${GREEN}========================================${NC}"
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}❌ Error: $ERROR_COUNT개${NC}"
    fi
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Warning: $WARNING_COUNT개${NC}"
    fi
    echo -e "${GREEN}========================================${NC}"
fi

exit 0
