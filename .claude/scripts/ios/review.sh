#!/bin/bash
# iOS 코드 셀프 리뷰 자동화 (인라인 코멘트 지원)

set -e

# PR 번호 파라미터 (선택적)
PR_NUMBER=$1

echo "🔍 iOS 코드 리뷰 시작"
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

# Swift 파일만 필터링
SWIFT_FILES=$(echo "$CHANGED_FILES" | grep "\.swift$" || true)

if [[ -z "$SWIFT_FILES" ]]; then
    echo "⚠️  변경된 Swift 파일이 없습니다."
    exit 0
fi

# 임시 요약 파일
SUMMARY_FILE=$(mktemp)
trap "rm -f $SUMMARY_FILE" EXIT

# 요약 시작
cat > "$SUMMARY_FILE" <<EOF
## 🔍 iOS 코드 리뷰 결과

EOF

# 2. SwiftLint 검사
echo "---"
echo "🔧 SwiftLint 검사..."

echo "### ✅ SwiftLint 검사" >> "$SUMMARY_FILE"

if command -v swiftlint &> /dev/null; then
    LINT_OUTPUT=$(swiftlint lint --quiet 2>&1 || true)

    if [[ -z "$LINT_OUTPUT" ]]; then
        echo "✅ SwiftLint 통과"
        echo "통과" >> "$SUMMARY_FILE"
    else
        echo "⚠️  SwiftLint 이슈 발견"
        echo '```' >> "$SUMMARY_FILE"
        echo "$LINT_OUTPUT" | head -20 >> "$SUMMARY_FILE"
        echo '```' >> "$SUMMARY_FILE"
    fi
else
    echo "⚠️  swiftlint 미설치"
    echo "**swiftlint 미설치** - 설치 후 재실행 필요" >> "$SUMMARY_FILE"
fi
echo "" >> "$SUMMARY_FILE"
echo ""

# 3. 동시성 혼용 검사
echo "---"
echo "🏗️  동시성 패턴 검사..."

CONCURRENCY_ISSUES=()
INLINE_COMMENTS=()

echo "### 🏗️ 동시성 패턴 검사" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# UIKit에서 async/await 사용 검사
for file in $SWIFT_FILES; do
    if [[ -f "$file" ]] && [[ "$file" != *"SwiftUI"* ]]; then
        # Task, async/await 사용 라인 찾기
        ASYNC_LINES=$(grep -n "Task\s*{" "$file" 2>/dev/null || true)

        if [[ -n "$ASYNC_LINES" ]]; then
            CONCURRENCY_ISSUES+=("⚠️  UIKit에서 Task 사용 (GCD 권장): $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="⚠️ **동시성 혼용: UIKit에서 Swift Concurrency 사용**

UIKit 화면에서는 GCD(DispatchQueue)를 사용해야 합니다.

**문제점:**
- UIKit과 Swift Concurrency 혼용 시 예측 불가능한 동작
- 프로젝트 컨벤션 위반

**권장 방법:**
\`\`\`swift
// ❌ 나쁜 예 (UIKit에서)
Task {
    await fetchData()
}

// ✅ 좋은 예 (UIKit에서)
DispatchQueue.main.async {
    // UI 업데이트
}
\`\`\`

**참고**: CLAUDE.md - \"UIKit: GCD만 사용 (async/await 금지)\""

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$ASYNC_LINES"
        fi
    fi
done

# SwiftUI에서 GCD 사용 검사
for file in $SWIFT_FILES; do
    if [[ -f "$file" ]] && [[ "$file" == *"SwiftUI"* ]]; then
        # DispatchQueue 사용 라인 찾기
        GCD_LINES=$(grep -n "DispatchQueue" "$file" 2>/dev/null || true)

        if [[ -n "$GCD_LINES" ]]; then
            CONCURRENCY_ISSUES+=("⚠️  SwiftUI에서 GCD 사용 (async/await 권장): $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="⚠️ **동시성 혼용: SwiftUI에서 GCD 사용**

SwiftUI 화면에서는 Swift Concurrency(async/await)를 사용해야 합니다.

**문제점:**
- SwiftUI와 GCD 혼용 시 상태 관리 복잡도 증가
- 프로젝트 컨벤션 위반

**권장 방법:**
\`\`\`swift
// ❌ 나쁜 예 (SwiftUI에서)
DispatchQueue.main.async {
    // 작업
}

// ✅ 좋은 예 (SwiftUI에서)
Task {
    await fetchData()
}
\`\`\`

**참고**: CLAUDE.md - \"SwiftUI: Swift Concurrency만 사용 (GCD 금지)\""

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$GCD_LINES"
        fi
    fi
done

if [[ ${#CONCURRENCY_ISSUES[@]} -eq 0 ]]; then
    echo "✅ 동시성 패턴 정상"
    echo "**통과 ✅**" >> "$SUMMARY_FILE"
else
    for issue in "${CONCURRENCY_ISSUES[@]}"; do
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

# 하드코딩된 시크릿 검사
for file in $SWIFT_FILES; do
    if [[ -f "$file" ]]; then
        SECRET_LINES=$(grep -n -E "(password|apiKey|secret|token)\\s*=\\s*\"" "$file" 2>/dev/null | grep -v "placeholder" | grep -v "//" || true)

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
1. Xcode Configuration (.xcconfig) 파일에 저장
2. Info.plist에서 읽어오기
3. Keychain 사용

\`\`\`swift
// ❌ 나쁜 예
let apiKey = \"sk-1234567890abcdef\"

// ✅ 좋은 예
let apiKey = Bundle.main.object(forInfoDictionaryKey: \"API_KEY\") as? String
\`\`\`"

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$SECRET_LINES"
        fi
    fi
done

# 민감 정보 로깅 검사
for file in $SWIFT_FILES; do
    if [[ -f "$file" ]]; then
        LOG_LINES=$(grep -n -E "print.*password|print.*token|print.*secret|NSLog.*password|NSLog.*token" "$file" 2>/dev/null || true)

        if [[ -n "$LOG_LINES" ]]; then
            SECURITY_ISSUES+=("❌ 민감 정보 로깅: $file")
            echo "$file"

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="🔒 **보안 이슈: 민감 정보 로깅**

Password, Token, Secret 등 민감 정보를 로그에 출력하고 있습니다.

**위험성:**
- 콘솔 로그에 민감 정보 노출
- 디버그 빌드에서 정보 유출 가능

**권장 방법:**
1. 민감 정보는 로깅하지 않기
2. 마스킹 처리 (\`****\`)
3. Release 빌드에서 로그 비활성화

\`\`\`swift
// ❌ 나쁜 예
print(\"Password: \\(password)\")

// ✅ 좋은 예
#if DEBUG
print(\"Password: [MASKED]\")
#endif
\`\`\`"

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

TOTAL_ISSUES=$((${#CONCURRENCY_ISSUES[@]} + ${#SECURITY_ISSUES[@]}))

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
    echo "~/.claude/scripts/ios/build.sh" >> "$SUMMARY_FILE"
    echo "\`\`\`" >> "$SUMMARY_FILE"
else
    echo "⚠️  발견된 문제: $TOTAL_ISSUES 개"
    echo "⚠️ **발견된 문제: $TOTAL_ISSUES개**" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"

    if [[ "$GITHUB_MODE" == true ]]; then
        echo "- 동시성 이슈: ${#CONCURRENCY_ISSUES[@]}개" >> "$SUMMARY_FILE"
        echo "- 보안 이슈: ${#SECURITY_ISSUES[@]}개" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        echo "상세 내용은 각 파일의 인라인 코멘트를 확인해주세요." >> "$SUMMARY_FILE"
    fi
fi

echo "" >> "$SUMMARY_FILE"
echo "---" >> "$SUMMARY_FILE"
echo "🤖 Generated by [ios-review](https://github.com/kidsnote/kidsnote_ios) skill" >> "$SUMMARY_FILE"

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
