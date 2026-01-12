# Common Patterns

## Result 처리

### 기본 패턴
```kotlin
useCase.getData()
    .onSuccess { data ->
        setState { copy(data = data) }
    }
    .onFailure { error ->
        setState { copy(error = error.message) }
    }
```

### fold 사용
```kotlin
useCase.getData().fold(
    onSuccess = { data -> handleSuccess(data) },
    onFailure = { error -> handleError(error) }
)
```

### getOrNull / getOrElse
```kotlin
val data = useCase.getData().getOrNull()
val dataWithDefault = useCase.getData().getOrElse { defaultValue }
```

## Flow 수집

### StateFlow 수집 (Compose)
```kotlin
@Composable
fun FeatureScreen(viewModel: FeatureViewModel) {
    val state by viewModel.state.collectAsStateWithLifecycle()

    // state 사용
}
```

### Effect 수집 (Compose)
```kotlin
LaunchedEffect(Unit) {
    viewModel.effect.collect { effect ->
        when (effect) {
            is Effect.ShowToast -> showToast(effect.message)
            is Effect.NavigateBack -> navController.popBackStack()
        }
    }
}
```

### Flow 수집 (Fragment/Activity)
```kotlin
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.state.collect { state ->
            updateUI(state)
        }
    }
}
```

## 네트워크 호출

### Repository 패턴
```kotlin
class FeatureRepositoryImpl @Inject constructor(
    private val api: FeatureApi,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO
) : FeatureRepository {

    override suspend fun getFeature(id: String): Result<FeatureModel> =
        withContext(dispatcher) {
            runCatching {
                api.getFeature(id).toDomain()
            }
        }
}
```

### 에러 처리 확장
```kotlin
suspend fun <T> safeApiCall(
    call: suspend () -> T
): Result<T> = runCatching { call() }
```

## DI 모듈

### Repository 바인딩
```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindFeatureRepository(
        impl: FeatureRepositoryImpl
    ): FeatureRepository
}
```

### UseCase 제공
```kotlin
@Module
@InstallIn(ViewModelComponent::class)
object UseCaseModule {

    @Provides
    @ViewModelScoped
    fun provideFeatureUseCase(
        repository: FeatureRepository
    ): FeatureUseCase = FeatureUseCase(repository)
}
```

## Navigation

### Compose Navigation
```kotlin
// NavHost 정의
NavHost(navController, startDestination = "home") {
    composable("home") {
        HomeScreen(
            onNavigateToDetail = { id ->
                navController.navigate("detail/$id")
            }
        )
    }
    composable(
        route = "detail/{id}",
        arguments = listOf(navArgument("id") { type = NavType.StringType })
    ) { backStackEntry ->
        val id = backStackEntry.arguments?.getString("id") ?: return@composable
        DetailScreen(id = id)
    }
}
```

### 화면 간 데이터 전달
```kotlin
// 전달
navController.navigate("detail/$id")

// 수신
val id = backStackEntry.arguments?.getString("id")
```

## 로딩 상태 처리

### UiState 패턴
```kotlin
data class UiState(
    val isLoading: Boolean = false,
    val data: DataType? = null,
    val error: String? = null
)

// Compose에서 사용
when {
    state.isLoading -> LoadingIndicator()
    state.error != null -> ErrorView(state.error)
    state.data != null -> ContentView(state.data)
}
```

### sealed class 패턴
```kotlin
sealed class UiState {
    object Loading : UiState()
    data class Success(val data: DataType) : UiState()
    data class Error(val message: String) : UiState()
}

when (state) {
    is UiState.Loading -> LoadingIndicator()
    is UiState.Success -> ContentView(state.data)
    is UiState.Error -> ErrorView(state.message)
}
```

## 확장 함수

### Context 확장
```kotlin
fun Context.showToast(message: String) {
    Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
}
```

### View 확장
```kotlin
fun View.visible() { visibility = View.VISIBLE }
fun View.gone() { visibility = View.GONE }
fun View.invisible() { visibility = View.INVISIBLE }
```

### String 확장
```kotlin
fun String.isValidEmail(): Boolean =
    Patterns.EMAIL_ADDRESS.matcher(this).matches()
```
