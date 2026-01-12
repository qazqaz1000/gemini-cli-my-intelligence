# Mocking Guide

## Fake vs Mock

### Fake 사용 (권장)
직접 구현한 테스트용 클래스. 동작을 완전히 제어 가능.

```kotlin
class FakeFeatureRepository : FeatureRepository {
    private var items: List<ItemModel> = emptyList()
    private var error: Throwable? = null

    fun setItems(items: List<ItemModel>) {
        this.items = items
        this.error = null
    }

    fun setError(error: Throwable) {
        this.error = error
    }

    override suspend fun getItems(): Result<List<ItemModel>> {
        error?.let { return Result.failure(it) }
        return Result.success(items)
    }
}
```

### Mock 사용 (Mockito/MockK)
라이브러리로 생성한 Mock 객체. 간단한 테스트에 적합.

```kotlin
// MockK 사용
@MockK
private lateinit var repository: FeatureRepository

@Before
fun setup() {
    MockKAnnotations.init(this)
}

@Test
fun `test with mockk`() = runTest {
    // Given
    coEvery { repository.getItems() } returns Result.success(listOf())

    // When & Then
    // ...

    coVerify { repository.getItems() }
}
```

## Fake 클래스 패턴

### Repository Fake
```kotlin
class FakeFeatureRepository : FeatureRepository {
    private var feature: FeatureModel? = null
    private var features: List<FeatureModel> = emptyList()
    private var error: Throwable? = null
    private var delay: Long = 0

    // 설정 메서드
    fun setFeature(feature: FeatureModel) {
        this.feature = feature
        this.error = null
    }

    fun setFeatures(features: List<FeatureModel>) {
        this.features = features
        this.error = null
    }

    fun setError(error: Throwable) {
        this.error = error
    }

    fun setDelay(delay: Long) {
        this.delay = delay
    }

    // Repository 구현
    override suspend fun getFeature(id: String): Result<FeatureModel> {
        if (delay > 0) kotlinx.coroutines.delay(delay)
        error?.let { return Result.failure(it) }
        return feature?.let { Result.success(it) }
            ?: Result.failure(NoSuchElementException("Not found"))
    }

    override suspend fun getFeatures(): Result<List<FeatureModel>> {
        if (delay > 0) kotlinx.coroutines.delay(delay)
        error?.let { return Result.failure(it) }
        return Result.success(features)
    }
}
```

### UseCase Fake
```kotlin
class FakeFeatureUseCase : FeatureUseCase {
    private var result: Result<List<FeatureModel>> = Result.success(emptyList())
    private var delay: Long = 0

    fun setResult(result: Result<List<FeatureModel>>) {
        this.result = result
    }

    fun setDelay(delay: Long) {
        this.delay = delay
    }

    override suspend fun getFeatures(): Result<List<FeatureModel>> {
        if (delay > 0) kotlinx.coroutines.delay(delay)
        return result
    }
}
```

### API Fake
```kotlin
class FakeFeatureApi : FeatureApi {
    private var response: List<FeatureDto>? = null
    private var error: Throwable? = null

    fun setResponse(response: List<FeatureDto>) {
        this.response = response
        this.error = null
    }

    fun setError(error: Throwable) {
        this.error = error
    }

    override suspend fun getFeatures(): List<FeatureDto> {
        error?.let { throw it }
        return response ?: throw IllegalStateException("No response set")
    }
}
```

### DAO Fake
```kotlin
class FakeFeatureDao : FeatureDao {
    private val items = mutableListOf<FeatureEntity>()

    fun getCachedCount() = items.size

    override suspend fun insert(item: FeatureEntity) {
        items.add(item)
    }

    override suspend fun insertAll(items: List<FeatureEntity>) {
        this.items.addAll(items)
    }

    override suspend fun getAll(): List<FeatureEntity> = items.toList()

    override suspend fun deleteAll() {
        items.clear()
    }
}
```

## MockK 사용법

### 기본 설정
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class ViewModelMockKTest {

    @MockK
    private lateinit var useCase: FeatureUseCase

    private lateinit var viewModel: FeatureViewModel

    @Before
    fun setup() {
        MockKAnnotations.init(this)
        viewModel = FeatureViewModel(useCase)
    }

    @After
    fun tearDown() {
        unmockkAll()
    }
}
```

### Suspend 함수 Mock
```kotlin
@Test
fun `test with suspend mock`() = runTest {
    // Given
    coEvery { useCase.getFeatures() } returns Result.success(listOf())

    // When
    viewModel.onEvent(Event.LoadData)

    // Then
    coVerify(exactly = 1) { useCase.getFeatures() }
}
```

### 연속 응답 Mock
```kotlin
@Test
fun `test sequential responses`() = runTest {
    // Given
    coEvery { useCase.getFeatures() } returnsMany listOf(
        Result.success(listOf(item1)),
        Result.success(listOf(item1, item2))
    )

    // When - 첫 번째 호출
    viewModel.onEvent(Event.LoadData)
    assertEquals(1, viewModel.state.value.items.size)

    // When - 두 번째 호출
    viewModel.onEvent(Event.Refresh)
    assertEquals(2, viewModel.state.value.items.size)
}
```

### Exception Mock
```kotlin
@Test
fun `test exception`() = runTest {
    // Given
    coEvery { useCase.getFeatures() } throws IOException("Network error")

    // When
    viewModel.onEvent(Event.LoadData)

    // Then
    assertNotNull(viewModel.state.value.error)
}
```

## 테스트 의존성

```kotlin
// build.gradle.kts (app module)
dependencies {
    // JUnit
    testImplementation("junit:junit:4.13.2")

    // Coroutines Test
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")

    // MockK
    testImplementation("io.mockk:mockk:1.13.8")

    // Turbine (Flow 테스트)
    testImplementation("app.cash.turbine:turbine:1.0.0")
}
```

## Turbine 사용 (Flow 테스트)

```kotlin
@Test
fun `test flow with turbine`() = runTest {
    // Given
    coEvery { useCase.getFeatures() } returns Result.success(listOf(item))

    // When & Then
    viewModel.state.test {
        // 초기 상태
        assertEquals(UiState(), awaitItem())

        viewModel.onEvent(Event.LoadData)

        // 로딩 상태
        assertEquals(true, awaitItem().isLoading)

        // 완료 상태
        val finalState = awaitItem()
        assertEquals(false, finalState.isLoading)
        assertEquals(1, finalState.items.size)

        cancelAndIgnoreRemainingEvents()
    }
}
```
