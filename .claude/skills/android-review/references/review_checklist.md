# Review Checklist

## 아키텍처

### Clean Architecture
- [ ] Presentation → Domain 의존성만 존재
- [ ] Data → Domain 의존성만 존재
- [ ] Domain은 외부 의존성 없음
- [ ] 레이어 간 데이터 변환 (DTO → Model → UiModel)

### ViewModel
- [ ] Android Context 직접 의존 없음
- [ ] BaseViewModelWithState 상속 (MVI)
- [ ] UseCase 또는 Repository 주입
- [ ] viewModelScope 사용

### Repository
- [ ] 데이터 도메인(Entity) 단위로 구성
- [ ] Interface는 domain 모듈에 위치
- [ ] Implementation은 data 모듈에 위치

### UseCase
- [ ] Service 스타일 (관련 로직 묶음)
- [ ] 비즈니스 로직 처리
- [ ] Repository 의존성 주입

## 코딩 스타일

### 네이밍
- [ ] 클래스: PascalCase
- [ ] 함수/변수: camelCase
- [ ] 상수: SCREAMING_SNAKE_CASE
- [ ] Composable: PascalCase

### 데이터 클래스
- [ ] API/DB: `Dto` 접미사
- [ ] Domain: `Model` 접미사
- [ ] UI: `UiModel` 접미사

### Import
- [ ] Wildcard import 없음
- [ ] 사용하지 않는 import 없음

### 타입
- [ ] 명시적 타입 선언
- [ ] Any 타입 사용 없음
- [ ] Nullable 최소화

## 코드 품질

### 함수
- [ ] 30줄 이내 권장
- [ ] 단일 책임
- [ ] 명확한 이름

### 에러 처리
- [ ] Result 타입 사용
- [ ] try-catch 최소화
- [ ] 에러 메시지 명확

### 비동기
- [ ] 적절한 Dispatcher 사용
- [ ] 취소 처리 고려
- [ ] 메모리 누수 방지

## UI

### Compose
- [ ] remember 적절한 사용
- [ ] 불필요한 recomposition 방지
- [ ] Preview 함수 작성

### 리소스
- [ ] 하드코딩 문자열 없음
- [ ] strings.xml 사용
- [ ] 3개 flavor 모두 추가

### 접근성
- [ ] contentDescription 제공
- [ ] 터치 타겟 크기 (48dp 이상)

## 성능

### 메모리
- [ ] 큰 객체 적절한 해제
- [ ] Bitmap 최적화
- [ ] ViewHolder 재사용

### 네트워크
- [ ] 불필요한 API 호출 없음
- [ ] 캐싱 전략
- [ ] 에러 재시도 로직

### UI
- [ ] 메인 스레드 블로킹 없음
- [ ] 무거운 작업 백그라운드 처리
- [ ] 리스트 최적화 (DiffUtil)

## 테스트

### 단위 테스트
- [ ] ViewModel 테스트 작성
- [ ] UseCase 테스트 작성
- [ ] Repository 테스트 작성

### 테스트 커버리지
- [ ] 핵심 비즈니스 로직 커버
- [ ] 엣지 케이스 포함
- [ ] 에러 케이스 포함
