#!/bin/bash
# Android 코드 셀프 리뷰 자동화

set -e

echo "🔍 Android 코드 리뷰 시작"
echo "========================"
echo ""

# 1. 변경된 파일 목록
echo "📁 변경된 파일:"
CHANGED_FILES=$(git diff --name-only HEAD~1 2>/dev/null || git diff --name-only --cached)
echo "$CHANGED_FILES"
echo ""

# Kotlin 파일만 필터링
KOTLIN_FILES=$(echo "$CHANGED_FILES" | grep "\.kt$" || true)

if [[ -z "$KOTLIN_FILES" ]]; then
    echo "⚠️  변경된 Kotlin 파일이 없습니다."
    exit 0
fi

# 2. ktlint 검사
echo "---"
echo "🔧 ktlint 검사..."
./gradlew ktlintCheck 2>&1 | grep -E "(FAILED|✓|error)" | head -20 || echo "✅ ktlint 통과"
echo ""

# 3. 아키텍처 위반 검사
echo "---"
echo "🏗️  아키텍처 검사..."

ISSUES=()

# Context in ViewModel
for file in $KOTLIN_FILES; do
    if [[ "$file" == *"ViewModel.kt" ]]; then
        if grep -l "android\.content\.Context" "$file" 2>/dev/null; then
            ISSUES+=("❌ ViewModel에서 Context 사용: $file")
        fi
    fi
done

# Wildcard import
for file in $KOTLIN_FILES; do
    if grep -E "^import .+\.\*$" "$file" 2>/dev/null; then
        ISSUES+=("⚠️  Wildcard import: $file")
    fi
done

if [[ ${#ISSUES[@]} -eq 0 ]]; then
    echo "✅ 아키텍처 위반 없음"
else
    for issue in "${ISSUES[@]}"; do
        echo "$issue"
    done
fi
echo ""

# 4. 보안 검사
echo "---"
echo "🔒 보안 검사..."

SECURITY_ISSUES=()

# 하드코딩된 API Key 패턴
for file in $KOTLIN_FILES; do
    if grep -E "(api[_-]?key|secret|password|token)\s*=\s*\"[^\"]+\"" "$file" 2>/dev/null | grep -v "BuildConfig"; then
        SECURITY_ISSUES+=("❌ 하드코딩된 시크릿 의심: $file")
    fi
done

# 민감 정보 로깅
for file in $KOTLIN_FILES; do
    if grep -E "Log\.(d|e|w|i|v)\(.*password|token|secret" "$file" 2>/dev/null; then
        SECURITY_ISSUES+=("❌ 민감 정보 로깅: $file")
    fi
done

if [[ ${#SECURITY_ISSUES[@]} -eq 0 ]]; then
    echo "✅ 보안 문제 없음"
else
    for issue in "${SECURITY_ISSUES[@]}"; do
        echo "$issue"
    done
fi
echo ""

# 5. 결과 요약
echo "---"
echo "📋 리뷰 요약"
echo "============"

TOTAL_ISSUES=$((${#ISSUES[@]} + ${#SECURITY_ISSUES[@]}))

if [[ $TOTAL_ISSUES -eq 0 ]]; then
    echo "✅ 모든 검사 통과!"
    echo ""
    echo "다음 단계: 빌드 확인"
    echo "~/.claude/scripts/android/build.sh"
else
    echo "⚠️  발견된 문제: $TOTAL_ISSUES 개"
    echo ""
    echo "수정 후 다시 리뷰해주세요."
fi
