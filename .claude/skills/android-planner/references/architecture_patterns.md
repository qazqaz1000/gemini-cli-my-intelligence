# Architecture Patterns

## MVI 패턴 (기본)

KidsNote 프로젝트의 기본 아키텍처 패턴.

### 구조

```
ViewModel (BaseViewModelWithState)
    ├── UiState (data class)     - 화면 상태
    ├── Event (sealed class)     - 사용자/시스템 이벤트
    └── Effect (sealed class)    - 단발성 이벤트
```

### Contract 정의 예시

```kotlin
// FeatureContract.kt
object FeatureContract {
    data class UiState(
        val isLoading: Boolean = false,
        val items: List<ItemUiModel> = emptyList(),
        val error: String? = null
    )

    sealed class Event {
        object LoadItems : Event()
        data class ItemClicked(val id: String) : Event()
        object RetryClicked : Event()
    }

    sealed class Effect {
        data class ShowToast(val message: String) : Effect()
        data class NavigateToDetail(val id: String) : Effect()
    }
}
```

### ViewModel 구현

```kotlin
class FeatureViewModel @Inject constructor(
    private val useCase: FeatureUseCase
) : BaseViewModelWithState<UiState, Event, Effect>(UiState()) {

    override fun onEvent(event: Event) {
        when (event) {
            is Event.LoadItems -> loadItems()
            is Event.ItemClicked -> navigateToDetail(event.id)
            is Event.RetryClicked -> loadItems()
        }
    }

    private fun loadItems() {
        setState { copy(isLoading = true) }
        viewModelScope.launch {
            useCase.getItems()
                .onSuccess { items ->
                    setState { copy(isLoading = false, items = items.map { it.toUi() }) }
                }
                .onFailure { error ->
                    setState { copy(isLoading = false, error = error.message) }
                    sendEffect(Effect.ShowToast("로드 실패"))
                }
        }
    }
}
```

## MVVM 패턴 (단순한 경우)

MVI가 과한 경우에만 사용.

### 사용 조건
- 단순 조회 화면
- 상태 전환이 복잡하지 않은 경우
- 이벤트 종류가 적은 경우

### 구조

```kotlin
class SimpleViewModel @Inject constructor(
    private val repository: Repository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    fun loadData() {
        viewModelScope.launch {
            repository.getData()
                .onSuccess { _uiState.value = UiState.Success(it) }
                .onFailure { _uiState.value = UiState.Error(it.message) }
        }
    }
}
```

## Clean Architecture 레이어

```
┌─────────────────────────────────────────┐
│         Presentation (app)              │
│   UI, ViewModel, Navigation, UiModel    │
├─────────────────────────────────────────┤
│           Domain (domain)               │
│   UseCase, Model, Repository Interface  │
├─────────────────────────────────────────┤
│             Data (data)                 │
│   Repository Impl, DataSource, DTO      │
└─────────────────────────────────────────┘
```

## 의존성 규칙

- Presentation → Domain (O)
- Domain → Data (X)
- Data → Domain (O) - Repository 구현
- 의존성은 안쪽으로만 향함
