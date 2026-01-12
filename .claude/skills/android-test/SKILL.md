---
name: android-test
description: |
  Android 테스트 작성 및 실행 skill.
  트리거: "테스트 작성", "테스트 실행", "TDD"
---

# Android Test

테스트 작성 및 실행 skill.

## 테스트 실행

```bash
# 전체
~/.claude/scripts/android/run_test.sh

# 특정 모듈
~/.claude/scripts/android/run_test.sh -m app

# 특정 클래스
~/.claude/scripts/android/run_test.sh -m app "*.FeatureViewModelTest"

# 리포트 포함
~/.claude/scripts/android/run_test.sh -m app --report
```

## 테스트 작성 규칙

### 파일 위치
- `app/src/test/` - Presentation 테스트
- `domain/src/test/` - Domain 테스트
- `data/src/test/` - Data 테스트

### 명명 규칙
```kotlin
@Test
fun `loadData success should update state`()
```

### 기본 구조
```kotlin
@get:Rule
val mainDispatcherRule = MainDispatcherRule()

@Test
fun `test example`() = runTest {
    // Given
    // When
    // Then
}
```

## 테스트 대상별 핵심

| 대상 | 검증 내용 | Mock 대상 |
|------|----------|-----------|
| ViewModel | State/Effect 변경 | UseCase |
| UseCase | 로직, Repository 호출 | Repository |
| Repository | 매핑, API 호출 | API/DAO |

## 참고

상세 패턴은 기존 테스트 코드 검색:
```bash
find app/src/test -name "*Test.kt" | head -5
```
