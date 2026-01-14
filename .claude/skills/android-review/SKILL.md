---
name: android-review
description: |
  Android 코드 셀프 리뷰 skill. ktlint 검사, 보안 검토, 아키텍처 위반 검토 수행.
  GitHub PR에 인라인 코멘트 및 전체 리뷰 작성 지원.
  트리거: "코드 리뷰", "셀프 리뷰", "PR 전 체크", "PR 리뷰"
---

# Android Review

Android 코드 자동 리뷰 skill with GitHub 인라인 코멘트 지원.

## 사용 방법

### 1. 로컬 리뷰 (인라인 코멘트 없음)
```bash
~/.claude/scripts/android/review.sh
```
- 현재 git diff 기준으로 리뷰
- 터미널에 결과만 출력

### 2. GitHub PR 리뷰 (인라인 코멘트 + 전체 요약)
```bash
~/.claude/scripts/android/review.sh <PR_NUMBER>
```
- PR diff 기준으로 리뷰
- **개별 이슈 → 인라인 코멘트** (특정 라인에 작성)
- **전체 요약 → PR 코멘트** (상단에 작성)

**예시:**
```bash
~/.claude/scripts/android/review.sh 6520
```

## 검사 항목

### ✅ 자동 검사
1. **ktlint**: 코드 스타일 검사
2. **아키텍처 위반**
   - ViewModel에서 Context 사용
   - Wildcard import (`import foo.bar.*`)
3. **보안 검사**
   - 하드코딩된 API Key/Secret/Password/Token
   - 민감 정보 로깅

### 📋 수동 체크리스트

#### 아키텍처
- [ ] Clean Architecture 레이어 분리
- [ ] ViewModel에서 Context 미사용
- [ ] DTO/Model/UiModel 접미사 사용

#### 보안
- [ ] 하드코딩 시크릿 없음
- [ ] 로그에 민감 정보 없음

#### 리소스
- [ ] 문자열 3개 flavor 모두 추가
- [ ] 하드코딩 문자열 없음

## GitHub 리뷰 결과 예시

### 인라인 코멘트 (reply/resolve 가능)
각 이슈가 발견된 **정확한 코드 라인**에 작성됩니다:

```
app/src/main/java/MyViewModel.kt:25

⚠️ 아키텍처 위반: ViewModel에서 Context 사용

ViewModel에서 직접 Context를 사용하는 것은 권장되지 않습니다.

문제점:
- 메모리 누수 위험
- 테스트 어려움
- Clean Architecture 위반

권장 방법:
1. UseCase에서 Context 필요 작업 처리
2. Repository에 Context 의존성 주입
3. AndroidViewModel 사용 (단, 신중하게)
```

### PR 전체 코멘트 (요약)
PR 상단에 전체 리뷰 결과 요약이 작성됩니다:

```markdown
## 🔍 Android 코드 리뷰 결과

### ✅ ktlint 검사
통과

### 🏗️ 아키텍처 검사
- ❌ ViewModel에서 Context 사용: app/src/main/java/MyViewModel.kt
- ⚠️ Wildcard import: app/src/main/java/Utils.kt

### 🔒 보안 검사
**통과 ✅**

---

## 📊 요약
⚠️ **발견된 문제: 2개**
- 아키텍처 이슈: 2개
- 보안 이슈: 0개

상세 내용은 각 파일의 인라인 코멘트를 확인해주세요.
```

## 스크립트 구조

```
~/.claude/skills/android-review/
├── SKILL.md                              # 이 문서
└── scripts/
    └── lint_check.sh                     # ktlint 검사 (deprecated)

~/.claude/scripts/git/
├── post_inline_comment.sh                # 인라인 코멘트 작성
└── post_review_summary.sh                # PR 전체 요약 작성

~/.claude/scripts/android/
└── review.sh                             # 메인 리뷰 스크립트
```

## Agent 사용 예시

```yaml
- name: android-review
  prompt: |
    PR #6520 리뷰해줘.
    개별 이슈는 인라인 코멘트로, 전체 요약은 PR 코멘트로 작성해줘.
```

Agent가 자동으로 `~/.claude/scripts/android/review.sh 6520`을 실행합니다.

## 리뷰 결과 형식

### 터미널 출력
```
🔍 Android 코드 리뷰 시작
========================

📌 PR #6520 리뷰 모드
📁 변경된 파일:
app/src/main/java/MyViewModel.kt
...

---
🔧 ktlint 검사...
✅ ktlint 통과

---
🏗️  아키텍처 검사...
❌ ViewModel에서 Context 사용: app/src/main/java/MyViewModel.kt

---
🔒 보안 검사...
✅ 보안 문제 없음

---
📋 리뷰 요약
============
⚠️  발견된 문제: 1 개

---
📤 GitHub PR에 리뷰 작성 중...
  📌 인라인 코멘트 1개 작성 중...
✅ Inline comment posted: app/src/main/java/MyViewModel.kt:25
  📝 리뷰 요약 작성 중...
✅ Review summary posted to PR #6520

✅ GitHub PR #6520에 리뷰 작성 완료!
   인라인 코멘트: 1개
   전체 요약: 1개
```

## 주의사항

### 인라인 코멘트 작성 실패 시
- **원인**: PR diff에 없는 파일이거나 라인 번호가 변경됨
- **해결**: PR을 최신 상태로 업데이트하거나 브랜치 rebase

### GitHub CLI 인증
```bash
# 인증 확인
gh auth status

# 인증 필요 시
gh auth login
```

## 개발자 가이드

### 새로운 검사 항목 추가

`~/.claude/scripts/android/review.sh`에 다음 형식으로 추가:

```bash
# 새로운 검사
for file in $KOTLIN_FILES; do
    if [[ -f "$file" ]]; then
        ISSUE_LINES=$(grep -n "패턴" "$file" 2>/dev/null || true)

        if [[ -n "$ISSUE_LINES" ]]; then
            ISSUES+=("설명: $file")

            # 인라인 코멘트 생성
            while IFS=: read -r line_num line_content; do
                COMMENT="코멘트 내용"

                if [[ "$GITHUB_MODE" == true ]]; then
                    INLINE_COMMENTS+=("$file:$line_num:$COMMENT")
                fi
            done <<< "$ISSUE_LINES"
        fi
    fi
done
```
