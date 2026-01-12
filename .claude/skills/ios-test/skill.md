---
name: ios-test
description: |
  iOS 테스트 작성 및 실행 skill.
  트리거: "테스트 작성", "테스트 실행", "TDD"
---

# iOS Test

테스트 작성 및 실행 skill.

## 테스트 실행

```bash
# 전체 Unit 테스트
~/.claude/scripts/ios/run_test.sh

# 특정 테스트 타겟
~/.claude/scripts/ios/run_test.sh -t kidsnoteSwiftTests

# 특정 테스트 클래스
~/.claude/scripts/ios/run_test.sh -t kidsnoteSwiftTests -c FeatureTests
```

## 테스트 작성 규칙

### 파일 위치
- `kidsnoteSwiftTests/` - Unit 테스트
- `kidsnoteUITests/` - UI 테스트

### 명명 규칙
```swift
func test_조건_행동_결과() { }
```

### XCTest 기본 구조
```swift
import XCTest
@testable import KidsNote

final class FeatureTests: XCTestCase {

    private var sut: FeatureViewModel!

    override func setUp() {
        super.setUp()
        sut = FeatureViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_example() {
        // Given

        // When

        // Then
        XCTAssertEqual(expected, actual)
    }
}
```

### ReactorKit 테스트
```swift
import XCTest
import RxSwift
import RxTest
@testable import KidsNote

final class FeatureReactorTests: XCTestCase {

    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    private var reactor: FeatureReactor!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        reactor = FeatureReactor()
    }

    func test_액션_상태변경() {
        // When
        reactor.action.onNext(.buttonTapped)

        // Then
        XCTAssertEqual(reactor.currentState.isLoading, true)
    }
}
```

## 테스트 대상별 핵심

| 대상 | 검증 내용 | Mock 대상 |
|------|----------|-----------|
| ViewModel | State 변경 | UseCase |
| Reactor | State/Mutation | Service |
| UseCase | 로직 | Repository |
| Repository | 매핑, API 호출 | API/Service |

## 참고

상세 패턴은 기존 테스트 코드 검색:
```bash
find kidsnoteSwiftTests -name "*Tests.swift" | head -5
```
