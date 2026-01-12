# Planning Template

## 작업 계획서 템플릿

```markdown
# [PK-XXXXX] 기능명

## 개요

| 항목 | 내용 |
|-----|-----|
| 티켓 | PK-XXXXX |
| 제목 | 기능명 |
| 분석일 | YYYY-MM-DD |
| 예상 영향 범위 | 높음 / 중간 / 낮음 |

## 요구사항

### 기능 요구사항
1. [ ] 요구사항 1
2. [ ] 요구사항 2
3. [ ] 요구사항 3

### 비기능 요구사항
- 성능: ...
- 보안: ...
- 접근성: ...

## 아키텍처 결정

### 패턴
- [ ] MVI (기본)
- [ ] MVVM (단순 화면)

### 주요 컴포넌트
- ViewModel: `FeatureViewModel`
- UseCase: `FeatureUseCase`
- Repository: `FeatureRepository`

## 영향 범위 분석

### 수정 파일

| 파일 경로 | 변경 내용 | 위험도 |
|---------|---------|-------|
| `app/src/.../Feature.kt` | 설명 | 낮음 |

### 신규 파일

| 파일 경로 | 역할 |
|---------|-----|
| `domain/src/.../FeatureModel.kt` | 도메인 모델 |
| `data/src/.../FeatureDto.kt` | API DTO |

### 영향 받는 기존 기능
- [ ] 기능 A: 영향 내용
- [ ] 기능 B: 영향 내용

## 작업 단계

### Phase 1: Domain Layer
- [ ] 1.1 Model 클래스 정의
- [ ] 1.2 Repository Interface 정의

### Phase 2: Data Layer
- [ ] 2.1 DTO 클래스 정의
- [ ] 2.2 API Endpoint 추가
- [ ] 2.3 Repository 구현

### Phase 3: Domain UseCase
- [ ] 3.1 UseCase 구현

### Phase 4: Presentation Layer
- [ ] 4.1 Contract 정의 (UiState, Event, Effect)
- [ ] 4.2 UiModel 정의
- [ ] 4.3 ViewModel 구현
- [ ] 4.4 UI 구현 (Compose / XML)

### Phase 5: 테스트
- [ ] 5.1 UseCase 테스트
- [ ] 5.2 ViewModel 테스트
- [ ] 5.3 Repository 테스트

### Phase 6: 마무리
- [ ] 6.1 코드 리뷰 반영
- [ ] 6.2 ktlint 검사
- [ ] 6.3 빌드 확인

## 리스크 분석

| 리스크 | 가능성 | 영향도 | 대응 방안 |
|-------|-------|-------|---------|
| 리스크 1 | 높음/중간/낮음 | 높음/중간/낮음 | 대응 방안 |

## 검증 방법

### 자동화 테스트
```bash
./gradlew test
./gradlew :app:testKidsnoteStagingDebugUnitTest
```

### 수동 테스트 시나리오
1. 시나리오 1: 기대 결과
2. 시나리오 2: 기대 결과
3. 에러 케이스: 기대 결과

## 참고 자료
- Jira 티켓: [PK-XXXXX](https://kidsnote.atlassian.net/browse/PK-XXXXX)
- 관련 문서: ...
```

## 빠른 계획서 (단순 작업용)

```markdown
# [PK-XXXXX] 단순 작업명

## 요약
간단한 작업 설명

## 변경 내용
- [ ] 파일1.kt: 변경 내용
- [ ] 파일2.kt: 변경 내용

## 검증
- [ ] 빌드 성공
- [ ] 기존 테스트 통과
```
