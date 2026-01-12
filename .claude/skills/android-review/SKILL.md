---
name: android-review
description: |
  Android 코드 셀프 리뷰 skill. ktlint 검사, 보안 검토, 아키텍처 위반 검토 수행.
  트리거: "코드 리뷰", "셀프 리뷰", "PR 전 체크"
---

# Android Review

코드 셀프 리뷰 skill.

## 자동화 리뷰

```bash
~/.claude/scripts/android/review.sh
```

검사 항목:
- 변경 파일 목록
- ktlint 검사
- 아키텍처 위반 (Context in ViewModel, Wildcard import)
- 보안 검사 (하드코딩 시크릿, 민감정보 로깅)

## 수동 체크리스트

### 아키텍처
- [ ] Clean Architecture 레이어 분리
- [ ] ViewModel에서 Context 미사용
- [ ] DTO/Model/UiModel 접미사 사용

### 보안
- [ ] 하드코딩 시크릿 없음
- [ ] 로그에 민감 정보 없음

### 리소스
- [ ] 문자열 3개 flavor 모두 추가
- [ ] 하드코딩 문자열 없음

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
