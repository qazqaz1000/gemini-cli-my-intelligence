# Kyle의 개인 Claude Code 설정

## 사용자 정보
- 이름: Kyle
- 역할: Mobile 개발자 (Android 주력, iOS 보조)

## 응답 언어 규칙
- 기본 응답 언어: 한국어
- 코드, 변수명, 고유명사, 기술 용어는 영어 사용 가능
- **사용자에게 질문할 때도 반드시 한국어로 질문**

## 주요 기술 스택

### Android
- **Language**: Kotlin
- **Build**: Gradle
- **Architecture**: MVI (우선), MVVM, Clean Architecture
- **Testing**: JUnit, Espresso, UiAutomator

### iOS
- **Language**: Swift (메인), Objective-C (레거시)
- **Build**: Tuist, Xcode
- **Architecture**: ReactorKit (UIKit), ViewModel/TCA (SwiftUI), Clean Architecture
- **Testing**: XCTest, RxTest

---

## Subagents & Skills

### 플랫폼별 Agents

| 역할 | Android | iOS |
|------|---------|-----|
| 코드 구현 | `android-dev` | `ios-dev` |
| 계획 수립 | `android-planner` | `ios-planner` |
| 코드 리뷰 | `android-review` | `ios-review` |
| 테스트 | `android-test` | `ios-test` |

### 공통 Agents
- `git-helper`: Git/GitHub 작업 (커밋, PR, 브랜치)
- `jira-helper`: Jira 티켓 관리
- `slack-reader`: Slack 메시지 조회
- `mungchi`: 개인 비서 (작업 분석 및 위임)

### 플랫폼 자동 감지 기준
- **Android**: `build.gradle.kts`, `app/src/main`, `*.kt`
- **iOS**: `*.xcworkspace`, `Tuist/`, `Sources/`, `*.swift`

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

---

## iOS 개발 전역 규칙

### 언어
- **Swift**: 신규 코드 작성 시 사용
- **Objective-C**: 레거시 유지보수 및 Swift 브릿징용
- 신규 Objective-C 코드 작성 금지 (기존 파일 수정은 허용)

### 아키텍처
- **Clean Architecture** 준수 (UseCase, Repository, Entity 분리)
- **UIKit**: ReactorKit 패턴 (View → Action → Reactor → Mutation → State)
- **SwiftUI**: ViewModel 패턴 권장 (View → ViewModel → UseCase → Repository)
- **SwiftUI + TCA**: 지양 (기존 코드 유지보수만)
- **MVC**: 레거시, 점진적 전환 대상

### 빌드 시스템
- **Tuist** 기반 멀티 모듈 프로젝트
- Workspace.swift + Project.swift 구성

### 핵심 라이브러리
- **RxSwift/RxCocoa 6.6.0**: 비동기 처리
- **SnapKit**: 코드 기반 UI 레이아웃
- **ReactorKit**: UIKit 단방향 데이터 흐름
- **Dependencies (pointfreeco)**: 의존성 주입
- **TCA**: SwiftUI 단방향 아키텍처 (신규 지양)

### 데이터 모델 규칙
- **DTO**: 서버 raw 데이터, `{API}{Action}Response` 형식
- **Entity**: 도메인 모델, `{Domain}Entity` 형식
- ViewModel은 Entity를 주입받음
- DTO → Entity 변환은 Mapper 또는 init에서 처리

### 코딩 스타일
- **SwiftLint** 규칙 준수
- 클래스/구조체/열거형: PascalCase
- 함수/변수/프로퍼티: camelCase
- UI 컴포넌트 초기화: `Then` 라이브러리 활용

### 금지 사항
- **Deprecated API 사용 금지**
- **신규 Objective-C 코드 작성 금지**
- **강제 언래핑 (`!`) 지양** (guard let, if let 사용)
- ViewController에서 비즈니스 로직 직접 처리 금지
