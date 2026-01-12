---
name: android-dev
description: |
  KidsNote Android 코드 구현 skill. Clean Architecture + MVI 패턴 기반 개발.
  트리거: "코드 구현", "개발 시작", "기능 구현", "버그 수정", "리팩토링"
---

# Android Dev

## 필수 원칙

- **Kotlin 전용** (Java 금지)
- **Clean Architecture** 레이어 분리
- **MVI 패턴** (BaseViewModelWithState 상속)
- **Deprecated API 금지**

## 개발 흐름

1. **Domain**: Model → Repository Interface → UseCase
2. **Data**: DTO → Mapper → Repository 구현
3. **Presentation**: Contract → UiModel → ViewModel → UI
4. **빌드 확인**: `~/.claude/scripts/android/build.sh`

## 데이터 모델 접미사

| 레이어 | 접미사 | 경로 |
|--------|--------|------|
| Data | `Dto` | `data/dto/` |
| Domain | `Model` | `domain/model/` |
| Presentation | `UiModel` | `app/model/` |

## 빌드/린트

```bash
~/.claude/scripts/android/build.sh              # 빌드
~/.claude/scripts/android/build.sh --lint       # lint + 빌드
~/.claude/scripts/android/ktlint.sh             # lint만
```

## 문자열 추가

3개 경로 모두 추가:
- `app/src/main/res/values-ko/strings.xml`
- `app/src/classnote/res/values-ko/strings.xml`
- `app/src/familynote/res/values-ko/strings.xml`

## 패턴 참조

상세 패턴은 기존 코드 검색으로 확인:
```bash
# ViewModel 예시
find app/src/main -name "*ViewModel.kt" | head -3

# Repository 예시
find data/src/main -name "*RepositoryImpl.kt" | head -3
```
