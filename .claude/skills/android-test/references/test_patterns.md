# Test Patterns

## 테스트 명명 규칙

### 메서드 이름 패턴
```kotlin
// 패턴: `조건_행동_기대결과`
@Test
fun `loadData success should update state with items`()

@Test
fun `click retry button should reload data`()

@Test
fun `empty list should show empty view`()
```

## Given-When-Then 패턴

```kotlin
@Test
fun `loadData success should update state`() = runTest {
    // Given - 테스트 준비
    val expectedItems = listOf(ItemModel("1", "Test"))
    fakeRepository.setItems(expectedItems)

    // When - 행동 수행
    viewModel.onEvent(Event.LoadData)

    // Then - 결과 검증
    val state = viewModel.state.value
    assertEquals(expectedItems.size, state.items.size)
}
```

## ViewModel 테스트 패턴

### 기본 구조
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class FeatureViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private lateinit var viewModel: FeatureViewModel
    private lateinit var fakeUseCase: FakeFeatureUseCase

    @Before
    fun setup() {
        fakeUseCase = FakeFeatureUseCase()
        viewModel = FeatureViewModel(fakeUseCase)
    }

    @After
    fun tearDown() {
        // 필요시 정리
    }
}
```

### State 테스트
```kotlin
@Test
fun `initial state should be loading false`() {
    val state = viewModel.state.value
    assertFalse(state.isLoading)
    assertTrue(state.items.isEmpty())
    assertNull(state.error)
}

@Test
fun `loadData should set loading true then false`() = runTest {
    // Given
    fakeUseCase.setDelay(100)

    // When
    viewModel.onEvent(Event.LoadData)

    // Then - 로딩 시작
    assertTrue(viewModel.state.value.isLoading)

    // Then - 로딩 완료
    advanceUntilIdle()
    assertFalse(viewModel.state.value.isLoading)
}
```

### Effect 테스트
```kotlin
@Test
fun `error should emit toast effect`() = runTest {
    // Given
    fakeUseCase.setError(Exception("Error"))

    // When
    viewModel.onEvent(Event.LoadData)

    // Then
    val effects = mutableListOf<Effect>()
    val job = launch {
        viewModel.effect.toList(effects)
    }

    advanceUntilIdle()
    job.cancel()

    assertTrue(effects.any { it is Effect.ShowToast })
}
```

## UseCase 테스트 패턴

```kotlin
class FeatureUseCaseTest {

    private lateinit var useCase: FeatureUseCase
    private lateinit var fakeRepository: FakeFeatureRepository

    @Before
    fun setup() {
        fakeRepository = FakeFeatureRepository()
        useCase = FeatureUseCase(fakeRepository)
    }

    @Test
    fun `getItems should return items from repository`() = runTest {
        // Given
        val expected = listOf(ItemModel("1", "Test"))
        fakeRepository.setItems(expected)

        // When
        val result = useCase.getItems()

        // Then
        assertTrue(result.isSuccess)
        assertEquals(expected, result.getOrNull())
    }

    @Test
    fun `getItems should return failure when repository fails`() = runTest {
        // Given
        fakeRepository.setError(Exception("Network error"))

        // When
        val result = useCase.getItems()

        // Then
        assertTrue(result.isFailure)
    }
}
```

## Repository 테스트 패턴

```kotlin
class FeatureRepositoryTest {

    private lateinit var repository: FeatureRepositoryImpl
    private lateinit var fakeApi: FakeFeatureApi
    private lateinit var fakeDao: FakeFeatureDao

    @Before
    fun setup() {
        fakeApi = FakeFeatureApi()
        fakeDao = FakeFeatureDao()
        repository = FeatureRepositoryImpl(fakeApi, fakeDao)
    }

    @Test
    fun `getItems should fetch from api and cache`() = runTest {
        // Given
        val dtos = listOf(ItemDto("1", "Test"))
        fakeApi.setResponse(dtos)

        // When
        val result = repository.getItems()

        // Then
        assertTrue(result.isSuccess)
        assertEquals(1, fakeDao.getCachedCount())
    }
}
```

## 에러 케이스 테스트

```kotlin
@Test
fun `network error should show error message`() = runTest {
    // Given
    fakeRepository.setError(IOException("Network error"))

    // When
    viewModel.onEvent(Event.LoadData)

    // Then
    assertNotNull(viewModel.state.value.error)
}

@Test
fun `empty response should show empty state`() = runTest {
    // Given
    fakeRepository.setItems(emptyList())

    // When
    viewModel.onEvent(Event.LoadData)

    // Then
    assertTrue(viewModel.state.value.items.isEmpty())
    assertTrue(viewModel.state.value.isEmpty)
}
```

## 테스트 유틸리티

### TestDispatcher Rule
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(
    private val dispatcher: TestDispatcher = UnconfinedTestDispatcher()
) : TestWatcher() {

    override fun starting(description: Description) {
        Dispatchers.setMain(dispatcher)
    }

    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}
```

### Flow 수집 헬퍼
```kotlin
suspend fun <T> Flow<T>.collectValues(
    scope: CoroutineScope
): List<T> {
    val values = mutableListOf<T>()
    val job = scope.launch {
        collect { values.add(it) }
    }
    return values.also { job.cancel() }
}
```
