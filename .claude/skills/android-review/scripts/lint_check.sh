#!/bin/bash

# KidsNote Android 린트 검사 스크립트

set -e

echo "=== KidsNote Android Lint Check ==="
echo ""

# 프로젝트 루트로 이동 (현재 위치가 프로젝트 내부라고 가정)
if [ -f "gradlew" ]; then
    PROJECT_ROOT="."
elif [ -f "../gradlew" ]; then
    PROJECT_ROOT=".."
else
    echo "Error: gradlew not found. Please run from project directory."
    exit 1
fi

cd "$PROJECT_ROOT"

echo "1. Running ktlint check..."
if ./gradlew ktlintCheck; then
    echo "   ✓ ktlint passed"
else
    echo "   ✗ ktlint failed"
    echo ""
    echo "   Run './gradlew ktlintFormat' to auto-fix issues"
    exit 1
fi

echo ""
echo "2. Running Android lint..."
if ./gradlew :app:lintKidsnoteStagingDebug; then
    echo "   ✓ Android lint passed"
else
    echo "   ✗ Android lint found issues"
    echo "   Check app/build/reports/lint-results-kidsnoteStagingDebug.html"
fi

echo ""
echo "3. Checking build..."
if ./gradlew assembleKidsnoteStagingDebug; then
    echo "   ✓ Build successful"
else
    echo "   ✗ Build failed"
    exit 1
fi

echo ""
echo "=== All checks passed! ==="
