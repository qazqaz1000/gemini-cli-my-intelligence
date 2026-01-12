---
name: ios-planner
description: |
  iOS 개발 계획 수립 skill. Jira 티켓 분석 후 기술 요구사항 도출, 영향 범위 파악, 작업 단계 세분화.
  트리거: "계획 수립", "PRD 작성", "영향 범위 분석", "작업 계획", Jira 티켓 기반 작업 시작 전, 복잡한 리팩토링 전.
---

# iOS Planner

KidsNote iOS 프로젝트의 개발 계획을 수립하는 skill.

## 계획 수립 프로세스

### 1단계: 요구사항 분석

Jira 티켓 확인 (jira-helper skill 사용):
- 제목/설명에서 핵심 요구사항 추출
- 댓글에서 추가 요구사항/제약사항 확인
- 연관 티켓 확인 (Epic, Sub-task)

### 2단계: 아키텍처 분석

영향 받는 레이어 파악:
- **Presentation**: View, ViewController, Reactor, ViewModel
- **Domain**: UseCase, Entity
- **Data**: Repository, DTO, Service

프레임워크 결정:
- 신규 화면: SwiftUI + ViewModel (권장)
- 기존 UIKit: ReactorKit 유지
- 기존 TCA: TCA 유지

### 3단계: 영향 범위 식별

코드베이스 탐색으로 확인:
- 수정 필요 파일 목록
- 새로 생성할 파일 목록
- 테스트 파일 영향 범위

```bash
# 관련 파일 검색
grep -r "키워드" --include="*.swift" Sources/
```

### 4단계: 작업 세분화

레이어별 분할:
1. Domain 모델 정의 (Entity)
2. Data 레이어 (Repository, DTO)
3. Domain UseCase
4. Presentation 레이어 (Reactor/ViewModel, View)
5. 테스트 작성

### 5단계: 리스크 분석

고려 항목:
- 기존 기능 영향도
- Breaking Change 가능성
- 성능/보안 이슈

## 출력 형식

```markdown
# [PK-XXXXX] 기능명 구현 계획

## 1. 개요
- 목적:
- 범위:
- 아키텍처: UIKit+ReactorKit / SwiftUI+ViewModel / SwiftUI+TCA

## 2. 영향 범위
- 수정 파일:
- 신규 파일:

## 3. 작업 단계
### Phase 1: Domain Layer
- [ ] Entity 정의

### Phase 2: Data Layer
- [ ] DTO 정의
- [ ] Repository 구현

### Phase 3: Presentation Layer
- [ ] Reactor/ViewModel 구현
- [ ] View 작성

### Phase 4: 검증
- [ ] SwiftLint 검사
- [ ] 빌드 확인

## 4. 예상 리스크
- 리스크 및 대응 방안

## 5. 검증 계획
- 테스트 및 검증 방법
```
