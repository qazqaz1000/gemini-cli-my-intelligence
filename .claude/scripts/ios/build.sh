#!/bin/bash
# iOS 빌드 스크립트
# 사용법: ~/.claude/scripts/ios/build.sh [--lint] [--scheme SCHEME]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 기본값
RUN_LINT=false
SCHEME=""
PROJECT_DIR=""

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --lint)
            RUN_LINT=true
            shift
            ;;
        --scheme)
            SCHEME="$2"
            shift 2
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

# iOS 프로젝트 확인
if [ ! -d "*.xcworkspace" ] && [ ! -f "Workspace.swift" ]; then
    # xcworkspace 또는 Tuist 파일 찾기
    WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" -type d | head -1)
    if [ -z "$WORKSPACE" ] && [ ! -f "Workspace.swift" ]; then
        echo -e "${RED}Error: iOS 프로젝트를 찾을 수 없습니다${NC}"
        exit 1
    fi
fi

# Tuist 프로젝트인 경우 generate 실행
if [ -f "Workspace.swift" ] || [ -d "Tuist" ]; then
    echo -e "${YELLOW}Tuist 프로젝트 감지됨. tuist generate 실행 중...${NC}"
    if command -v tuist &> /dev/null; then
        tuist generate --no-open 2>/dev/null || true
    else
        echo -e "${YELLOW}Warning: tuist가 설치되어 있지 않습니다. mise install을 실행하세요.${NC}"
    fi
fi

# Workspace 찾기
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" -type d | head -1)

if [ -z "$WORKSPACE" ]; then
    echo -e "${RED}Error: xcworkspace를 찾을 수 없습니다${NC}"
    exit 1
fi

# Scheme 결정
if [ -z "$SCHEME" ]; then
    # 가장 일반적인 scheme 이름 시도
    SCHEME=$(basename "$WORKSPACE" .xcworkspace)
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}iOS Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Workspace: $WORKSPACE"
echo "Scheme: $SCHEME"
echo ""

# SwiftLint 실행 (옵션)
if [ "$RUN_LINT" = true ]; then
    echo -e "${YELLOW}SwiftLint 검사 중...${NC}"
    if command -v swiftlint &> /dev/null; then
        swiftlint lint --quiet || echo -e "${YELLOW}SwiftLint 경고가 있습니다${NC}"
    else
        echo -e "${YELLOW}Warning: swiftlint가 설치되어 있지 않습니다${NC}"
    fi
    echo ""
fi

# 빌드 실행
echo -e "${YELLOW}빌드 중...${NC}"
xcodebuild build \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -configuration Debug \
    CODE_SIGNING_ALLOWED=NO \
    -quiet \
    2>&1

BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ 빌드 성공${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ 빌드 실패${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
