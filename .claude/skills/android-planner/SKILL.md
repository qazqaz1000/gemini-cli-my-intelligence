---
name: android-planner
description: |
  Android 개발 계획 수립 skill. Jira 티켓 분석 후 기술 요구사항 도출, 영향 범위 파악, 작업 단계 세분화.
  트리거: "계획 수립", "PRD 작성", "영향 범위 분석", "작업 계획", Jira 티켓 기반 작업 시작 전, 복잡한 리팩토링 전.
---

# Android Planner

KidsNote Android 프로젝트의 개발 계획을 수립하는 skill.

## 계획 수립 프로세스

### 1단계: 요구사항 분석

Jira 티켓 확인 (jira-helper skill 사용):
- 제목/설명에서 핵심 요구사항 추출
- 댓글에서 추가 요구사항/제약사항 확인
- 연관 티켓 확인 (Epic, Sub-task)

### 2단계: 아키텍처 분석

영향 받는 레이어 파악:
- **Presentation**: UI, ViewModel, Navigation
- **Domain**: UseCase, Model
- **Data**: Repository, DataSource, DTO

### 3단계: 영향 범위 식별

코드베이스 탐색으로 확인:
- 수정 필요 파일 목록
- 새로 생성할 파일 목록
- 테스트 파일 영향 범위

### 4단계: 작업 세분화

레이어별 분할:
1. Domain 모델 정의
2. Data 레이어 (Repository, DTO)
3. Domain UseCase
4. Presentation 레이어 (ViewModel, UI)
5. 테스트 작성

### 5단계: 리스크 분석

고려 항목:
- 기존 기능 영향도
- Breaking Change 가능성
- 성능/보안 이슈

## 출력 형식

계획서 템플릿: [references/planning_template.md](references/planning_template.md)

## 참고 문서

- **아키텍처 패턴**: [references/architecture_patterns.md](references/architecture_patterns.md) - MVI/MVVM, Clean Architecture
- **모듈 구조**: [references/module_structure.md](references/module_structure.md) - 패키지, Flavor, 리소스 위치
- **계획서 템플릿**: [references/planning_template.md](references/planning_template.md) - 전체/간단 템플릿
