# Coding Conventions

## 네이밍 규칙

### 클래스/인터페이스
```kotlin
// PascalCase
class FeatureRepository
interface UserService
object AppConstants
```

### 함수/변수
```kotlin
// camelCase
fun getUserById(userId: String): User
val userName: String
var isLoading: Boolean
```

### 상수
```kotlin
// SCREAMING_SNAKE_CASE (companion object 내)
companion object {
    private const val MAX_RETRY_COUNT = 3
    private const val TAG = "FeatureViewModel"
}
```

### Composable
```kotlin
// PascalCase
@Composable
fun FeatureScreen(viewModel: FeatureViewModel) { }

@Composable
fun UserProfileCard(user: User) { }
```

## 데이터 클래스 접미사

| 레이어 | 접미사 | 예시 |
|-------|-------|-----|
| Data (API/DB) | `Dto` | `UserDto` |
| Domain | `Model` | `UserModel` |
| Presentation | `UiModel` | `UserUiModel` |

## Import 규칙

```kotlin
// Wildcard import 금지
import com.kidsnote.domain.model.UserModel  // O
import com.kidsnote.domain.model.*          // X

// 정렬 순서
import android.*
import androidx.*
import com.*
import java.*
import javax.*
import kotlin.*
```

## 함수 작성 규칙

### 함수 길이
- 한 함수는 30줄 이내 권장
- 복잡한 로직은 private 함수로 분리

### 파라미터
```kotlin
// 3개 이하: 한 줄
fun doSomething(a: Int, b: String, c: Boolean)

// 4개 이상: 줄바꿈
fun doSomething(
    param1: Int,
    param2: String,
    param3: Boolean,
    param4: Long
)
```

### 반환 타입
```kotlin
// 단일 표현식: = 사용
fun getUserName(): String = user.name

// 복잡한 로직: 블록 사용
fun processUser(): Result<User> {
    // ...
    return result
}
```

## 클래스 구조 순서

```kotlin
class FeatureViewModel @Inject constructor(
    private val useCase: FeatureUseCase
) : BaseViewModel() {

    // 1. companion object
    companion object {
        private const val TAG = "FeatureViewModel"
    }

    // 2. 프로퍼티
    private val _state = MutableStateFlow(UiState())
    val state: StateFlow<UiState> = _state.asStateFlow()

    // 3. 초기화 블록
    init {
        loadData()
    }

    // 4. public 메서드
    fun onEvent(event: Event) { }

    // 5. private 메서드
    private fun loadData() { }
}
```

## 널 처리

```kotlin
// 안전 호출
user?.name

// Elvis 연산자
val name = user?.name ?: "Unknown"

// let 스코프 함수
user?.let { saveUser(it) }

// 강제 언래핑 금지 (특수한 경우 제외)
user!!.name  // X
```

## 주석 규칙

```kotlin
// 한 줄 주석: 설명이 필요한 경우만
val timeout = 30_000L  // 30초

/**
 * KDoc: public API에만 작성
 * @param userId 사용자 ID
 * @return 사용자 정보
 */
fun getUser(userId: String): User

// TODO 형식
// TODO: [PK-12345] 리팩토링 필요
```

## 금지 사항

```kotlin
// 1. Deprecated API
startActivityForResult()  // X
registerForActivityResult()  // O

// 2. Java 코드
public class JavaClass { }  // X

// 3. any 타입
val data: Any  // X
val data: SpecificType  // O

// 4. 하드코딩 문자열 (UI)
Text("안녕하세요")  // X
Text(stringResource(R.string.greeting))  // O
```
