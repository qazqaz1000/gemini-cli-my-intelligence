#!/bin/bash

# KidsNote Android 테스트 실행 스크립트

set -e

echo "=== KidsNote Android Test Runner ==="
echo ""

# 프로젝트 루트로 이동
if [ -f "gradlew" ]; then
    PROJECT_ROOT="."
elif [ -f "../gradlew" ]; then
    PROJECT_ROOT=".."
else
    echo "Error: gradlew not found. Please run from project directory."
    exit 1
fi

cd "$PROJECT_ROOT"

# 인자 파싱
MODULE=""
TEST_CLASS=""
FLAVOR="KidsnoteStagingDebug"

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--module)
            MODULE="$2"
            shift 2
            ;;
        -t|--test)
            TEST_CLASS="$2"
            shift 2
            ;;
        -f|--flavor)
            FLAVOR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: run_tests.sh [options]"
            echo ""
            echo "Options:"
            echo "  -m, --module <module>    Run tests for specific module (app, domain, data)"
            echo "  -t, --test <class>       Run specific test class"
            echo "  -f, --flavor <flavor>    Build flavor (default: KidsnoteStagingDebug)"
            echo "  -h, --help               Show this help"
            echo ""
            echo "Examples:"
            echo "  ./run_tests.sh                           # Run all tests"
            echo "  ./run_tests.sh -m app                    # Run app module tests"
            echo "  ./run_tests.sh -t FeatureViewModelTest   # Run specific test class"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 테스트 명령어 구성
if [ -n "$MODULE" ]; then
    GRADLE_CMD=":$MODULE:test${FLAVOR}UnitTest"
else
    GRADLE_CMD="test"
fi

if [ -n "$TEST_CLASS" ]; then
    GRADLE_CMD="$GRADLE_CMD --tests \"*.$TEST_CLASS\""
fi

echo "Running: ./gradlew $GRADLE_CMD"
echo ""

# 테스트 실행
eval "./gradlew $GRADLE_CMD"

echo ""
echo "=== Test Results ==="

# 결과 리포트 경로 출력
if [ -n "$MODULE" ]; then
    REPORT_PATH="$MODULE/build/reports/tests/test${FLAVOR}UnitTest/index.html"
else
    REPORT_PATH="app/build/reports/tests/test${FLAVOR}UnitTest/index.html"
fi

if [ -f "$REPORT_PATH" ]; then
    echo "Report: $REPORT_PATH"
    echo ""
    echo "To open report:"
    echo "  open $REPORT_PATH"
fi

echo ""
echo "=== Done ==="
