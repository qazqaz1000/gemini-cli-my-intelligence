#!/bin/bash
# Android 테스트 실행 및 결과 파싱

set -e

# 사용법 출력
show_help() {
    cat << EOF
사용법: run_test.sh [OPTIONS] [TEST_FILTER]

OPTIONS:
  -m, --module MODULE    테스트할 모듈 (app, domain, data)
  -f, --flavor FLAVOR    빌드 Flavor (kidsnote, classnote, familynote)
  -t, --type TYPE        빌드 타입 (staging, release) [기본: staging]
  --report               테스트 후 리포트 경로 출력
  -h, --help            도움말

EXAMPLES:
  run_test.sh                                    # 전체 테스트
  run_test.sh -m app                             # app 모듈만
  run_test.sh -m app "*.FeatureViewModelTest"    # 특정 테스트 클래스
  run_test.sh -m app --report                    # 테스트 후 리포트 확인
EOF
}

# 기본값
MODULE=""
FLAVOR="kidsnote"
TYPE="staging"
TEST_FILTER=""
SHOW_REPORT=false

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--module) MODULE="$2"; shift 2 ;;
        -f|--flavor) FLAVOR="$2"; shift 2 ;;
        -t|--type) TYPE="$2"; shift 2 ;;
        --report) SHOW_REPORT=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) TEST_FILTER="$1"; shift ;;
    esac
done

# Flavor/Type 조합
VARIANT="${FLAVOR^}${TYPE^}"  # kidsnoteStagingDebug

# 테스트 명령 구성
if [[ -n "$MODULE" ]]; then
    TASK=":${MODULE}:test${VARIANT}DebugUnitTest"
else
    TASK="test"
fi

# 테스트 필터 추가
FILTER_ARG=""
if [[ -n "$TEST_FILTER" ]]; then
    FILTER_ARG="--tests \"$TEST_FILTER\""
fi

echo "🧪 테스트 실행: ./gradlew $TASK $FILTER_ARG"
echo "---"

# 테스트 실행
if [[ -n "$FILTER_ARG" ]]; then
    ./gradlew $TASK --tests "$TEST_FILTER" 2>&1 | tee /tmp/test_output.txt
else
    ./gradlew $TASK 2>&1 | tee /tmp/test_output.txt
fi

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "---"

# 결과 요약
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✅ 테스트 성공"
else
    echo "❌ 테스트 실패"
    # 실패한 테스트 추출
    grep -E "^.*FAILED$|^.*> .* FAILED$" /tmp/test_output.txt 2>/dev/null || true
fi

# 리포트 경로 출력
if [[ "$SHOW_REPORT" == true ]] && [[ -n "$MODULE" ]]; then
    REPORT_PATH="${MODULE}/build/reports/tests/test${VARIANT}DebugUnitTest/index.html"
    if [[ -f "$REPORT_PATH" ]]; then
        echo ""
        echo "📊 리포트: $REPORT_PATH"
    fi
fi

exit $EXIT_CODE
