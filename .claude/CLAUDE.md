# Kyle의 개인 Claude Code 설정

## 사용자 정보
- 이름: Kyle
- 역할: Android 개발자

## 응답 언어 규칙
- 기본 응답 언어: 한국어
- 코드, 변수명, 고유명사, 기술 용어는 영어 사용 가능
- **사용자에게 질문할 때도 반드시 한국어로 질문**

## 주요 기술 스택
- **Primary**: Kotlin, Android
- **Build**: Gradle
- **Architecture**: MVI (우선), MVVM, Clean Architecture
- **Testing**: JUnit, Espresso, UiAutomator

## Git 커밋 메시지 스타일
- 형식: `[PK-XXXXXX] type(scope) : 한국어 설명`
- type 종류: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- description은 한국어로 작업 내용 요약

## 자주 사용하는 도구
- IDE: Android Studio
- Version Control: Git, GitHub
- Project Management: Jira
- Documentation: Notion
- Communication: Slack

---

## Android 개발 전역 규칙

### 아키텍처
- **Clean Architecture** 준수
- **MVI 패턴 우선** (Model-View-Intent)
- MVVM은 MVI가 과한 경우에만 사용

### 코딩 스타일
- **ktlint** 규칙 준수
- 클래스: PascalCase / 함수, 변수: camelCase
- Composable 함수: PascalCase
- Wildcard import (`*`) 사용 금지
- 모든 타입 명시적 선언 (`any` 지양)

### 금지 사항
- **Deprecated API 사용 금지** (AsyncTask, startActivityForResult 등)
- **Java 코드 작성 금지** (특수한 경우 제외)
- **XML 레이아웃 지양** (신규 UI는 Jetpack Compose)
- ViewModel에서 Android Context 직접 의존 금지

### 데이터 모델 규칙
- **DTO** (`data` 모듈): API/DB용, 접미사 `Dto`
- **Domain Model** (`domain` 모듈): 비즈니스 로직용, 접미사 `Model`
- **UI Model** (`app` 모듈): 화면 표시용, 접미사 `UiModel`
- 계층 간 이동 시 Mapper 함수 사용 (`toDomain()`, `toUi()`)

### 작업 방식
- 변경 전 기존 코드 먼저 확인
- 최소한의 변경으로 목표 달성
- 빌드 에러 없이 작업 완료
- 복잡한 기능은 계획(PRD) 수립 후 진행
