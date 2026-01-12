# Security Checklist

## OWASP Mobile Top 10 기반

### M1: 부적절한 자격 증명 사용
- [ ] API 키/토큰 하드코딩 없음
- [ ] 비밀번호 소스코드에 포함 없음
- [ ] 민감 정보 BuildConfig 또는 환경변수 사용
- [ ] Git에 민감 정보 커밋 없음

```kotlin
// BAD
const val API_KEY = "sk-1234567890"

// GOOD
val apiKey = BuildConfig.API_KEY
```

### M2: 불충분한 데이터 저장
- [ ] SharedPreferences에 민감 정보 암호화
- [ ] EncryptedSharedPreferences 사용
- [ ] 외부 저장소에 민감 정보 저장 없음
- [ ] 로그에 민감 정보 출력 없음

```kotlin
// BAD
KLog.d(TAG) { "Token: $accessToken" }

// GOOD
KLog.d(TAG) { "Token received" }
```

### M3: 안전하지 않은 통신
- [ ] HTTPS 사용
- [ ] 인증서 피닝 (필요시)
- [ ] 네트워크 보안 설정 확인

### M4: 안전하지 않은 인증
- [ ] 세션 토큰 안전한 저장
- [ ] 토큰 만료 처리
- [ ] 로그아웃 시 토큰 삭제

### M5: 불충분한 암호화
- [ ] 적절한 암호화 알고리즘 사용
- [ ] 키 안전한 관리
- [ ] Android Keystore 사용

### M6: 안전하지 않은 권한 부여
- [ ] 불필요한 권한 요청 없음
- [ ] 런타임 권한 적절한 처리
- [ ] 권한 거부 시 대응

### M7: 클라이언트 코드 품질
- [ ] 입력값 검증
- [ ] SQL Injection 방지
- [ ] 버퍼 오버플로우 방지

```kotlin
// BAD - SQL Injection 취약
val query = "SELECT * FROM users WHERE name = '$input'"

// GOOD - Parameterized Query
@Query("SELECT * FROM users WHERE name = :name")
fun getUserByName(name: String): User
```

### M8: 코드 변조
- [ ] ProGuard/R8 난독화
- [ ] 디버그 빌드 구분
- [ ] 무결성 검사 (필요시)

### M9: 리버스 엔지니어링
- [ ] 민감한 로직 서버 사이드
- [ ] 난독화 적용
- [ ] 디버그 정보 제거 (릴리즈)

### M10: 숨겨진 기능
- [ ] 백도어 없음
- [ ] 테스트 코드 프로덕션 미포함
- [ ] 디버그 기능 릴리즈 미포함

## 추가 검토 항목

### WebView
- [ ] JavaScript 인터페이스 최소화
- [ ] 신뢰할 수 있는 URL만 로드
- [ ] XSS 방지

```kotlin
// BAD
webView.settings.javaScriptEnabled = true
webView.addJavascriptInterface(UnsafeInterface(), "Android")

// GOOD - 필요한 경우만, 검증된 URL로
if (isTrustedUrl(url)) {
    webView.settings.javaScriptEnabled = true
}
```

### Intent
- [ ] 명시적 Intent 사용
- [ ] 암시적 Intent 데이터 검증
- [ ] PendingIntent 플래그 확인

```kotlin
// FLAG_IMMUTABLE 사용 (Android 12+)
PendingIntent.getActivity(
    context,
    0,
    intent,
    PendingIntent.FLAG_IMMUTABLE
)
```

### 파일
- [ ] 내부 저장소 사용 우선
- [ ] 파일 권한 적절히 설정
- [ ] 임시 파일 삭제

### 로깅
- [ ] 릴리즈 빌드 로그 최소화
- [ ] 민감 정보 로깅 없음
- [ ] 스택 트레이스에 민감 정보 없음
