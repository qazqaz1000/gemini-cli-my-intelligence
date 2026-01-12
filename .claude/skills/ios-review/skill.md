---
name: ios-review
description: |
  iOS 코드 셀프 리뷰 skill. SwiftLint 검사, 보안 검토, 아키텍처 위반 검토 수행.
  트리거: "코드 리뷰", "셀프 리뷰", "PR 전 체크"
---

# iOS Review

코드 셀프 리뷰 skill.

## 자동화 리뷰

```bash
~/.claude/scripts/ios/review.sh
```

검사 항목:
- 변경 파일 목록
- SwiftLint 검사
- 아키텍처 위반 (동시성 혼용, 패턴 위반)
- 보안 검사 (하드코딩 시크릿, 민감정보 로깅)

## 수동 체크리스트

### 아키텍처
- [ ] Clean Architecture 레이어 분리
- [ ] UIKit → ReactorKit 패턴 준수
- [ ] SwiftUI → ViewModel/TCA 패턴 준수
- [ ] DTO/Entity 분리

### 동시성
- [ ] UIKit: GCD만 사용 (async/await 금지)
- [ ] SwiftUI: Swift Concurrency만 사용 (GCD 금지)

### 보안
- [ ] 하드코딩 시크릿 없음
- [ ] 로그에 민감 정보 없음

### 코딩 컨벤션
- [ ] 타입 명시적 선언
- [ ] String Interpolation 사용
- [ ] guard문 다음 개행
- [ ] @objc 키워드 다음 라인에 코드

### 주석
- [ ] 함수/모듈에 문서화 주석 작성

## 리뷰 결과 형식

```markdown
## 리뷰 결과

### 심각도: 높음
- [파일:라인] 문제 설명

### 심각도: 중간
- [파일:라인] 문제 설명

### 통과 항목
- 잘 된 부분
```
