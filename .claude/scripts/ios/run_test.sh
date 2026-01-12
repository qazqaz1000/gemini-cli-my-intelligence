#!/bin/bash
# iOS 테스트 실행 스크립트
# 사용법: ~/.claude/scripts/ios/run_test.sh [-t TARGET] [-c CLASS] [--report]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 기본값
TEST_TARGET=""
TEST_CLASS=""
GENERATE_REPORT=false
PROJECT_DIR=""

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--target)
            TEST_TARGET="$2"
            shift 2
            ;;
        -c|--class)
            TEST_CLASS="$2"
            shift 2
            ;;
        --report)
            GENERATE_REPORT=true
            shift
            ;;
        *)
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

# 프로젝트 디렉토리 결정
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR=$(pwd)
fi

cd "$PROJECT_DIR"

# Workspace 찾기
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" -type d | head -1)

if [ -z "$WORKSPACE" ]; then
    echo -e "${RED}Error: xcworkspace를 찾을 수 없습니다${NC}"
    exit 1
fi

SCHEME=$(basename "$WORKSPACE" .xcworkspace)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}iOS Test${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Workspace: $WORKSPACE"
echo "Scheme: $SCHEME"
if [ -n "$TEST_TARGET" ]; then
    echo "Target: $TEST_TARGET"
fi
if [ -n "$TEST_CLASS" ]; then
    echo "Class: $TEST_CLASS"
fi
echo ""

# 테스트 명령어 구성
TEST_CMD="xcodebuild test"
TEST_CMD+=" -workspace $WORKSPACE"
TEST_CMD+=" -scheme $SCHEME"
TEST_CMD+=" -destination 'platform=iOS Simulator,name=iPhone 16'"
TEST_CMD+=" -configuration Debug"
TEST_CMD+=" CODE_SIGNING_ALLOWED=NO"

if [ -n "$TEST_TARGET" ]; then
    TEST_CMD+=" -only-testing:$TEST_TARGET"

    if [ -n "$TEST_CLASS" ]; then
        TEST_CMD+=" -only-testing:$TEST_TARGET/$TEST_CLASS"
    fi
fi

if [ "$GENERATE_REPORT" = true ]; then
    TEST_CMD+=" -resultBundlePath TestResults.xcresult"
fi

# 테스트 실행
echo -e "${YELLOW}테스트 실행 중...${NC}"
echo ""

eval $TEST_CMD 2>&1 | xcpretty || TEST_RESULT=$?

# xcpretty가 없으면 일반 출력
if ! command -v xcpretty &> /dev/null; then
    eval $TEST_CMD 2>&1
    TEST_RESULT=$?
else
    TEST_RESULT=${TEST_RESULT:-0}
fi

echo ""
if [ ${TEST_RESULT:-0} -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ 테스트 성공${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ 테스트 실패${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi

if [ "$GENERATE_REPORT" = true ]; then
    echo ""
    echo "리포트 위치: TestResults.xcresult"
fi
