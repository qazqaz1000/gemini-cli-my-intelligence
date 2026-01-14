---
name: ios-dev
description: |
  KidsNote iOS 코드 구현 skill. Clean Architecture + ReactorKit/TCA 패턴 기반 개발.
  트리거: "코드 구현", "개발 시작", "기능 구현", "버그 수정", "리팩토링"
---

# iOS Dev

## 필수 원칙

- **Swift 전용** (Objective-C 신규 금지)
- **Clean Architecture** 레이어 분리
- **UIKit**: ReactorKit 패턴
- **SwiftUI**: ViewModel 패턴 (권장) 또는 TCA
- **Deprecated API 금지**

## 코드 포맷팅

Xcode 기본 정렬 (`Ctrl + I`) 준수:
- **Indentation**: 4 spaces 기준
- **Trailing whitespace 금지**: 줄 끝 불필요한 공백 제거
- **빈 줄**: 현재 들여쓰기 레벨의 공백 포함 (완전히 비우지 않음)
- **메서드/함수 시작 직후**: 빈 줄 없이 바로 코드 시작
- **Objective-C 블록**: 파라미터 정렬 X, 4 spaces 기준 들여쓰기
- **주석 블록**: 현재 들여쓰기 레벨에 맞게 정렬

## 개발 흐름

1. **Domain**: Entity → UseCase 인터페이스
2. **Data**: DTO → Mapper → Repository 구현
3. **Presentation**: Reactor/ViewModel → View/ViewController
4. **빌드 확인**: `~/.claude/scripts/ios/build.sh`

## 아키텍처 선택

| 프레임워크 | 패턴 | 데이터 흐름 |
|-----------|------|------------|
| UIKit | ReactorKit | View → Action → Reactor → Mutation → State → View |
| SwiftUI | ViewModel | View → ViewModel → UseCase → Repository |
| SwiftUI | TCA | View → Action → Reducer → State → View |

## 데이터 모델

| 레이어 | 네이밍 | 예시 |
|--------|--------|------|
| Data | `{API}{Action}Response` | `AlbumListResponse` |
| Domain | `{Domain}Entity` | `AlbumEntity` |

## 동시성 (필수)

```swift
// UIKit 환경 ✅
DispatchQueue.main.async {
    self.tableView.reloadData()
}

// SwiftUI 환경 ✅
Task { @MainActor in
    await viewModel.fetchData()
}
```

## 빌드/린트

```bash
~/.claude/scripts/ios/build.sh              # 빌드
~/.claude/scripts/ios/swiftlint.sh          # SwiftLint만
~/.claude/scripts/ios/build.sh --lint       # lint + 빌드
```

## UI 초기화 (Then 라이브러리)

```swift
private let tableView: UITableView = UITableView(frame: .zero, style: .grouped).then {
    $0.backgroundColor = Color.tableViewBackgroundColor
    $0.register(Reusable.headerCell)
}
```

## 패턴 참조

```bash
# ReactorKit 예시
find Sources -name "*Reactor.swift" | head -3

# ViewModel 예시
find Sources -name "*ViewModel.swift" | head -3
```
