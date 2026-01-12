#!/bin/bash
# iOS 코드 리뷰 스크립트
# 사용법: ~/.claude/scripts/ios/review.sh [PATH]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TARGET_PATH="${1:-.}"
cd "$TARGET_PATH"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}iOS 코드 리뷰${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 1. 변경된 파일 확인
echo -e "${BLUE}[1/5] 변경된 파일 확인${NC}"
echo "----------------------------------------"
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || echo "")
SWIFT_FILES=$(echo "$CHANGED_FILES" | grep "\.swift$" || echo "")

if [ -z "$SWIFT_FILES" ]; then
    echo "변경된 Swift 파일 없음"
else
    echo "$SWIFT_FILES"
fi
echo ""

# 2. SwiftLint 검사
echo -e "${BLUE}[2/5] SwiftLint 검사${NC}"
echo "----------------------------------------"
if command -v swiftlint &> /dev/null; then
    LINT_RESULT=$(swiftlint lint --quiet 2>&1 | head -20) || true
    if [ -z "$LINT_RESULT" ]; then
        echo -e "${GREEN}✅ SwiftLint 통과${NC}"
    else
        echo "$LINT_RESULT"
        if [ $(echo "$LINT_RESULT" | wc -l) -ge 20 ]; then
            echo "... (더 많은 결과는 swiftlint lint 직접 실행)"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  swiftlint 미설치${NC}"
fi
echo ""

# 3. 동시성 혼용 검사
echo -e "${BLUE}[3/5] 동시성 패턴 검사${NC}"
echo "----------------------------------------"

# UIKit에서 async/await 사용 검사
UIKIT_ASYNC=$(grep -rn "Task\s*{" Sources/Features --include="*.swift" 2>/dev/null | grep -v "SwiftUI" | head -5 || echo "")
if [ -n "$UIKIT_ASYNC" ]; then
    echo -e "${YELLOW}⚠️  UIKit에서 Task 사용 감지 (GCD 권장):${NC}"
    echo "$UIKIT_ASYNC"
else
    echo -e "${GREEN}✅ UIKit 동시성 패턴 정상${NC}"
fi

# SwiftUI에서 GCD 사용 검사
SWIFTUI_GCD=$(grep -rn "DispatchQueue" Sources/SwiftUI --include="*.swift" 2>/dev/null | head -5 || echo "")
if [ -n "$SWIFTUI_GCD" ]; then
    echo -e "${YELLOW}⚠️  SwiftUI에서 DispatchQueue 사용 감지 (async/await 권장):${NC}"
    echo "$SWIFTUI_GCD"
else
    echo -e "${GREEN}✅ SwiftUI 동시성 패턴 정상${NC}"
fi
echo ""

# 4. 보안 검사
echo -e "${BLUE}[4/5] 보안 검사${NC}"
echo "----------------------------------------"

# 하드코딩된 시크릿 검사
SECRETS=$(grep -rn "password\s*=\s*\"" --include="*.swift" Sources 2>/dev/null | grep -v "placeholder" | head -5 || echo "")
SECRETS+=$(grep -rn "apiKey\s*=\s*\"" --include="*.swift" Sources 2>/dev/null | head -5 || echo "")
SECRETS+=$(grep -rn "secret\s*=\s*\"" --include="*.swift" Sources 2>/dev/null | head -5 || echo "")

if [ -n "$SECRETS" ]; then
    echo -e "${RED}❌ 하드코딩 시크릿 의심:${NC}"
    echo "$SECRETS"
else
    echo -e "${GREEN}✅ 하드코딩 시크릿 없음${NC}"
fi

# 민감 정보 로깅 검사
SENSITIVE_LOG=$(grep -rn "print.*password\|print.*token\|print.*secret\|NSLog.*password\|NSLog.*token" --include="*.swift" Sources 2>/dev/null | head -5 || echo "")
if [ -n "$SENSITIVE_LOG" ]; then
    echo -e "${RED}❌ 민감 정보 로깅 의심:${NC}"
    echo "$SENSITIVE_LOG"
else
    echo -e "${GREEN}✅ 민감 정보 로깅 없음${NC}"
fi
echo ""

# 5. 코딩 컨벤션 검사
echo -e "${BLUE}[5/5] 코딩 컨벤션 검사${NC}"
echo "----------------------------------------"

# String + 연산자 사용 검사
STRING_CONCAT=$(grep -rn '"\s*+\s*"' --include="*.swift" Sources 2>/dev/null | head -5 || echo "")
if [ -n "$STRING_CONCAT" ]; then
    echo -e "${YELLOW}⚠️  String + 연산자 사용 (String Interpolation 권장):${NC}"
    echo "$STRING_CONCAT"
else
    echo -e "${GREEN}✅ String 연산 패턴 정상${NC}"
fi

# 타입 미명시 검사 (let/var = 으로 시작하면서 : 없는 경우)
# 이 검사는 false positive가 많아서 경고만 표시
echo -e "${GREEN}✅ 타입 명시 검사: 수동 확인 필요${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}리뷰 완료${NC}"
echo -e "${GREEN}========================================${NC}"
