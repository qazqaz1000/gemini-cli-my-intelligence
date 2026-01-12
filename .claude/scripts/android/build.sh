#!/bin/bash
# Android 빌드 및 에러 파싱

set -e

show_help() {
    cat << EOF
사용법: build.sh [OPTIONS] [FLAVOR]

FLAVOR:
  kidsnote (기본), classnote, familynote

OPTIONS:
  -t, --type TYPE    빌드 타입 (staging, release) [기본: staging]
  -d, --debug        Debug 빌드 (기본)
  -r, --release      Release 빌드
  --lint             빌드 전 ktlint 실행
  --clean            클린 빌드
  -h, --help         도움말

EXAMPLES:
  build.sh                    # kidsnoteStagingDebug
  build.sh classnote          # classnoteStagingDebug
  build.sh -t release         # kidsnoteReleaseRelease
  build.sh --lint             # ktlint 후 빌드
EOF
}

FLAVOR="kidsnote"
TYPE="staging"
BUILD_TYPE="Debug"
RUN_LINT=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type) TYPE="$2"; shift 2 ;;
        -d|--debug) BUILD_TYPE="Debug"; shift ;;
        -r|--release) BUILD_TYPE="Release"; shift ;;
        --lint) RUN_LINT=true; shift ;;
        --clean) CLEAN=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        kidsnote|classnote|familynote) FLAVOR="$1"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Flavor/Type 조합 (첫글자 대문자)
VARIANT="${FLAVOR^}${TYPE^}${BUILD_TYPE}"

# Clean
if [[ "$CLEAN" == true ]]; then
    echo "🧹 Clean build..."
    ./gradlew clean
fi

# ktlint
if [[ "$RUN_LINT" == true ]]; then
    echo "🔍 Running ktlint..."
    ./gradlew ktlintFormat 2>&1 | grep -E "(Lint|Format)" || true
    echo ""
fi

# Build
echo "🔨 Building: assemble${VARIANT}"
echo "---"

./gradlew "assemble${VARIANT}" 2>&1 | tee /tmp/build_output.txt

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "---"

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✅ 빌드 성공: ${VARIANT}"
    APK_PATH=$(find app/build/outputs/apk -name "*.apk" -type f 2>/dev/null | head -1)
    if [[ -n "$APK_PATH" ]]; then
        echo "📦 APK: $APK_PATH"
    fi
else
    echo "❌ 빌드 실패"
    echo ""
    echo "📋 에러 요약:"
    grep -E "^e:|error:|FAILURE|Exception|Unresolved reference" /tmp/build_output.txt | head -20
fi

exit $EXIT_CODE
