#!/bin/bash
# Android 코드 셀프 리뷰 자동화 (인라인 코멘트 지원)

set -e

# PR 번호 파라미터 (선택적)
PR_NUMBER=$1

echo "🔍 Android 코드 리뷰 시작"
echo "========================"
echo ""

# PR 번호가 제공된 경우 GitHub 리뷰 모드
GITHUB_MODE=false
if [[ -n "$PR_NUMBER" ]]; then
    echo "📌 PR #$PR_NUMBER 리뷰 모드"
    GITHUB_MODE=true

    # PR diff로 변경된 파일 가져오기
    CHANGED_FILES=$(gh pr diff "$PR_NUMBER" --name-only 2>/dev/null || echo "")

    if [[ -z "$CHANGED_FILES" ]]; then
        echo "❌ PR #$PR_NUMBER의 변경 파일을 가져올 수 없습니다."
        exit 1
    fi
else
    # 로컬 git diff로 변경된 파일 가져오기
    CHANGED_FILES=$(git diff --name-only HEAD~1 2>/dev/null || git diff --name-only --cached)
fi

# 1. 변경된 파일 목록
echo "📁 변경된 파일:"
echo "$CHANGED_FILES"
echo ""

# Kotlin 파일만 필터링
KOTLIN_FILES=$(echo "$CHANGED_FILES" | grep "\.kt$" || true)

if [[ -z "$KOTLIN_FILES" ]]; then
    echo "⚠️  변경된 Kotlin 파일이 없습니다."
    exit 0
fi

# 임시 요약 파일
SUMMARY_FILE=$(mktemp)
trap "rm -f $SUMMARY_FILE" EXIT

# 요약 시작
cat > "$SUMMARY_FILE" <<EOF
## 🔍 Android 코드 리뷰 결과

EOF

# 2. ktlint 검사
echo "---"
echo "🔧 ktlint 검사..."
KTLINT_OUTPUT=$(./gradlew ktlintCheck 2>&1 || true)
KTLINT_RESULT=$(echo "$KTLINT_OUTPUT" | grep -E "(FAILED|✓|error)" | head -20 || echo "")

if echo "$KTLINT_OUTPUT" | grep -q "BUILD SUCCESSFUL"; then
    echo "✅ ktlint 통과"
    echo "### ✅ ktlint 검사" >> "$SUMMARY_FILE"
    echo "통과" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
else
    echo "⚠️  ktlint 이슈 발견"
    echo "### ⚠️ ktlint 검사" >> "$SUMMARY_FILE"
    echo '```' >> "$SUMMARY_FILE"
    echo "$KTLINT_RESULT" >> "$SUMMARY_FILE"
    echo '```' >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
fi
echo ""

# 3. 아키텍처 위반 검사
echo "---"
echo "🏗️  아키텍처 검사..."

ARCH_ISSUES=()
INLINE_COMMENTS=()

echo "### 🏗️ 아키텍처 검사" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Context in ViewModel
for file in $KOTLIN_FILES; do
    if [[ "$file" == *"ViewModel.kt" ]] && [[ -f "$file" ]]; then
        # Context 사용 라인 찾기
        CONTEXT_LINES=$(grep -n "android\.content\.Context" "$file" 2>/dev/null || true)

        if [[ -n "$CONTEXT_LINES" ]]; then
            ARCH_ISSUES+=("❌ ViewModel에서 Context 사용: $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="⚠️ **아키텍처 위반: ViewModel에서 Context 사용**

ViewModel에서 직접 Context를 사용하는 것은 권장되지 않습니다.

**문제점:**
- 메모리 누수 위험
- 테스트 어려움
- Clean Architecture 위반

**권장 방법:**
1. UseCase에서 Context 필요 작업 처리
2. Repository에 Context 의존성 주입
3. AndroidViewModel 사용 (단, 신중하게)

\`\`\`kotlin
// ❌ 나쁜 예
class MyViewModel(private val context: Context) : ViewModel()

// ✅ 좋은 예
class MyViewModel(private val useCase: MyUseCase) : ViewModel()
\`\`\`"

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$CONTEXT_LINES"
        fi
    fi
done

# Wildcard import
for file in $KOTLIN_FILES; do
    if [[ -f "$file" ]]; then
        WILDCARD_LINES=$(grep -n "^import .\\+\\.\\*$" "$file" 2>/dev/null || true)

        if [[ -n "$WILDCARD_LINES" ]]; then
            ARCH_ISSUES+=("⚠️  Wildcard import: $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="⚠️ **Wildcard import 사용**

Wildcard import (\`import foo.bar.*\`)는 사용하지 않는 것이 좋습니다.

**문제점:**
- 어떤 클래스를 사용하는지 불명확
- 네임 충돌 가능성
- 코드 가독성 저하

**해결 방법:**
Android Studio에서 \`Optimize Imports\` 실행하거나 \`./gradlew ktlintFormat\`으로 자동 수정 가능합니다."

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$WILDCARD_LINES"
        fi
    fi
done

if [[ ${#ARCH_ISSUES[@]} -eq 0 ]]; then
    echo "✅ 아키텍처 위반 없음"
    echo "**통과 ✅**" >> "$SUMMARY_FILE"
else
    for issue in "${ARCH_ISSUES[@]}"; do
        echo "$issue"
        echo "- $issue" >> "$SUMMARY_FILE"
    done
fi
echo "" >> "$SUMMARY_FILE"
echo ""

# 4. 보안 검사
echo "---"
echo "🔒 보안 검사..."

SECURITY_ISSUES=()

echo "### 🔒 보안 검사" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# 하드코딩된 API Key 패턴
for file in $KOTLIN_FILES; do
    if [[ -f "$file" ]]; then
        SECRET_LINES=$(grep -n -E "(api[_-]?key|secret|password|token)\\s*=\\s*\"[^\"]+\"" "$file" 2>/dev/null | grep -v "BuildConfig" || true)

        if [[ -n "$SECRET_LINES" ]]; then
            SECURITY_ISSUES+=("❌ 하드코딩된 시크릿 의심: $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="🔒 **보안 이슈: 하드코딩된 시크릿 의심**

API Key, Secret, Password, Token 등이 하드코딩된 것으로 보입니다.

**위험성:**
- 소스 코드에 민감 정보 노출
- Git 히스토리에 영구 저장
- 보안 취약점

**권장 방법:**
1. \`local.properties\`에 저장
2. \`BuildConfig\`로 접근
3. 환경 변수 사용

\`\`\`kotlin
// ❌ 나쁜 예
val apiKey = \"sk-1234567890abcdef\"

// ✅ 좋은 예
val apiKey = BuildConfig.API_KEY
\`\`\`"

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$SECRET_LINES"
        fi
    fi
done

# 민감 정보 로깅
for file in $KOTLIN_FILES; do
    if [[ -f "$file" ]]; then
        LOG_LINES=$(grep -n -E "Log\\.(d|e|w|i|v)\\(.*password|token|secret" "$file" 2>/dev/null || true)

        if [[ -n "$LOG_LINES" ]]; then
            SECURITY_ISSUES+=("❌ 민감 정보 로깅: $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="🔒 **보안 이슈: 민감 정보 로깅**

Password, Token, Secret 등 민감 정보를 로그에 출력하고 있습니다.

**위험성:**
- Logcat에 민감 정보 노출
- 디버그 빌드에서 정보 유출 가능

**권장 방법:**
1. 민감 정보는 로깅하지 않기
2. 마스킹 처리 (\`****\`)
3. Release 빌드에서 로그 비활성화"

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$LOG_LINES"
        fi
    fi
done

if [[ ${#SECURITY_ISSUES[@]} -eq 0 ]]; then
    echo "✅ 보안 문제 없음"
    echo "**통과 ✅**" >> "$SUMMARY_FILE"
else
    for issue in "${SECURITY_ISSUES[@]}"; do
        echo "$issue"
        echo "- $issue" >> "$SUMMARY_FILE"
    done
fi
echo "" >> "$SUMMARY_FILE"
echo ""

# 5. 결과 요약
echo "---"
echo "📋 리뷰 요약"
echo "============"

TOTAL_ISSUES=$((${#ARCH_ISSUES[@]} + ${#SECURITY_ISSUES[@]}))

echo "" >> "$SUMMARY_FILE"
echo "---" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "## 📊 요약" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

if [[ $TOTAL_ISSUES -eq 0 ]]; then
    echo "✅ 모든 검사 통과!"
    echo "**✅ 모든 검사 통과!**" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    echo "다음 단계: 빌드 확인" >> "$SUMMARY_FILE"
    echo "\`\`\`bash" >> "$SUMMARY_FILE"
    echo "~/.claude/scripts/android/build.sh" >> "$SUMMARY_FILE"
    echo "\`\`\`" >> "$SUMMARY_FILE"
else
    echo "⚠️  발견된 문제: $TOTAL_ISSUES 개"
    echo "⚠️ **발견된 문제: $TOTAL_ISSUES개**" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"

    if [[ "$GITHUB_MODE" == true ]]; then
        echo "- 아키텍처 이슈: ${#ARCH_ISSUES[@]}개" >> "$SUMMARY_FILE"
        echo "- 보안 이슈: ${#SECURITY_ISSUES[@]}개" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        echo "상세 내용은 각 파일의 인라인 코멘트를 확인해주세요." >> "$SUMMARY_FILE"
    fi
fi

echo "" >> "$SUMMARY_FILE"
echo "---" >> "$SUMMARY_FILE"
echo "🤖 Generated by [android-review](https://github.com/kidsnote/kidsnote_android) skill" >> "$SUMMARY_FILE"

# 6. GitHub 리뷰 작성
if [[ "$GITHUB_MODE" == true ]]; then
    echo ""
    echo "---"
    echo "📤 GitHub PR에 리뷰 작성 중..."

    # 인라인 코멘트 작성
    INLINE_SCRIPT="$HOME/.claude/scripts/common/post_inline_comment.sh"

    if [[ ${#INLINE_COMMENTS[@]} -gt 0 ]]; then
        echo "  📌 인라인 코멘트 ${#INLINE_COMMENTS[@]}개 작성 중..."

        for comment_data in "${INLINE_COMMENTS[@]}"; do
            IFS=: read -r file line body <<< "$comment_data"
            "$INLINE_SCRIPT" "$PR_NUMBER" "$file" "$line" "$body" || true
        done
    fi

    # 전체 요약 작성
    echo "  📝 리뷰 요약 작성 중..."
    SUMMARY_SCRIPT="$HOME/.claude/scripts/common/post_review_summary.sh"
    "$SUMMARY_SCRIPT" "$PR_NUMBER" "$SUMMARY_FILE"

    echo ""
    echo "✅ GitHub PR #$PR_NUMBER에 리뷰 작성 완료!"
    echo "   인라인 코멘트: ${#INLINE_COMMENTS[@]}개"
    echo "   전체 요약: 1개"
else
    echo ""
    echo "수정 후 다시 리뷰해주세요."
fi
