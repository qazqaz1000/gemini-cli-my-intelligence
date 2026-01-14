---
name: ios-review
description: |
  iOS 코드 셀프 리뷰 skill. SwiftLint 검사, 보안 검토, 아키텍처 위반 검토 수행.
  GitHub PR에 인라인 코멘트 및 전체 리뷰 작성 지원.
  트리거: "코드 리뷰", "셀프 리뷰", "PR 전 체크", "PR 리뷰"
---

# iOS Review

iOS 코드 자동 리뷰 skill with GitHub 인라인 코멘트 지원.

## 사용 방법

### 1. 로컬 리뷰 (인라인 코멘트 없음)
\`\`\`bash
~/.claude/scripts/ios/review.sh
\`\`\`
- 현재 git diff 기준으로 리뷰
- 터미널에 결과만 출력

### 2. GitHub PR 리뷰 (인라인 코멘트 + 전체 요약)
\`\`\`bash
~/.claude/scripts/ios/review.sh <PR_NUMBER>
\`\`\`
- PR diff 기준으로 리뷰
- **개별 이슈 → 인라인 코멘트** (특정 라인에 작성)
- **전체 요약 → PR 코멘트** (상단에 작성)

**예시:**
\`\`\`bash
~/.claude/scripts/ios/review.sh 1234
\`\`\`

## 검사 항목

### ✅ 자동 검사
1. **SwiftLint**: 코드 스타일 검사
2. **동시성 혼용 검사**
   - UIKit에서 Swift Concurrency (Task, async/await) 사용
   - SwiftUI에서 GCD (DispatchQueue) 사용
3. **보안 검사**
   - 하드코딩된 API Key/Secret/Password/Token
   - 민감 정보 로깅 (print, NSLog)

### 📋 수동 체크리스트

#### 아키텍처
- [ ] Clean Architecture 레이어 분리
- [ ] UIKit → ReactorKit 패턴 준수
- [ ] SwiftUI → ViewModel/TCA 패턴 준수
- [ ] DTO/Entity 분리

#### 동시성
- [ ] UIKit: GCD만 사용 (async/await 금지)
- [ ] SwiftUI: Swift Concurrency만 사용 (GCD 금지)

#### 보안
- [ ] 하드코딩 시크릿 없음
- [ ] 로그에 민감 정보 없음
