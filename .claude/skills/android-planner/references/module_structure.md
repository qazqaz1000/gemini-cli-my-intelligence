# KidsNote Module Structure

## 모듈 개요

| 모듈 | 역할 |
|------|------|
| `app` | 메인 앱 모듈 (APK/AAB 빌드, Presentation Layer) |
| `domain` | 비즈니스 로직 (UseCase, Model, Repository Interface) |
| `data` | 데이터 처리 (Repository Impl, Network, Local DB) |
| `common` | 공통 유틸리티, 확장 함수, UI 컴포넌트 |

## 세부 모듈

| 모듈 | 역할 |
|------|------|
| `ads` | 광고 기능 |
| `blur` | 이미지 블러 처리 |
| `channeltalk-kidsnote` | 채널톡 연동 |
| `platform` | 플랫폼 기능 추상화 |
| `video-compressor` | 동영상 압축 |
| `buildSrc` | Gradle 빌드 로직, 의존성 버전 관리 |
| `lint` | 커스텀 Lint 규칙 |

## 패키지 구조

### app 모듈 (Presentation)
```
app/src/main/java/com/kidsnote/
├── ui/
│   ├── feature/
│   │   ├── FeatureActivity.kt
│   │   ├── FeatureFragment.kt
│   │   ├── FeatureViewModel.kt
│   │   └── FeatureContract.kt
│   └── common/
├── di/
│   └── FeatureModule.kt
└── model/
    └── FeatureUiModel.kt
```

### domain 모듈
```
domain/src/main/java/com/kidsnote/domain/
├── usecase/
│   └── FeatureUseCase.kt
├── model/
│   └── FeatureModel.kt
└── repository/
    └── FeatureRepository.kt (Interface)
```

### data 모듈
```
data/src/main/java/com/kidsnote/data/
├── repository/
│   └── FeatureRepositoryImpl.kt
├── datasource/
│   ├── remote/
│   │   └── FeatureRemoteDataSource.kt
│   └── local/
│       └── FeatureLocalDataSource.kt
├── dto/
│   └── FeatureDto.kt
└── mapper/
    └── FeatureMapper.kt
```

## Build Flavor

### Kids Note
- `app/src/kidsnote/` - Kids Note 전용 리소스
- `app/src/main/res/values*/strings.xml`

### Class Note
- `app/src/classnote/` - Class Note 전용 리소스
- `app/src/classnote/res/values*/strings.xml`

### Family Note
- `app/src/familynote/` - Family Note 전용 리소스
- `app/src/familynote/res/values*/strings.xml`

## 리소스 위치

### 문자열
신규 문자열 추가 시 3개 경로 모두에 추가:
1. `app/src/main/res/values*/strings.xml`
2. `app/src/classnote/res/values*/strings.xml`
3. `app/src/familynote/res/values*/strings.xml`

### 다국어
- 기본 (영어): `values/strings.xml`
- 한국어: `values-ko/strings.xml`
- 일본어: `values-ja/strings.xml`
- 베트남어: `values-vi/strings.xml`

**Family Note 예외**: 영어/일본어 파일에도 한국어 텍스트 입력

## 개발용 빌드

```bash
./gradlew assembleKidsnoteStagingDebug
```
