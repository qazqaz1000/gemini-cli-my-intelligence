# 커밋 가이드

## 커밋 전 확인사항

```bash
# 1. 상태 확인
git status

# 2. 변경 내용 확인
git diff                    # unstaged 변경
git diff --staged           # staged 변경

# 3. 최근 커밋 스타일 확인
git log --oneline -5
```

## 커밋 메시지 형식

```
[PK-XXXXX] type(scope) : 한국어 설명

본문 (선택사항)
- 변경 이유
- 주요 변경 내용
```

### Type 상세

| Type | 설명 | 예시 |
|------|------|------|
| `feat` | 새로운 기능 추가 | 로그인 화면 추가 |
| `fix` | 버그 수정 | 크래시 수정 |
| `refactor` | 코드 개선 (기능 변경 없음) | 함수 분리 |
| `docs` | 문서 수정 | README 업데이트 |
| `test` | 테스트 추가/수정 | 단위 테스트 추가 |
| `chore` | 빌드, 설정 등 기타 | Gradle 버전 업 |
| `style` | 코드 포맷팅 | ktlint 적용 |
| `perf` | 성능 개선 | 쿼리 최적화 |

### Scope 예시
- `login`, `home`, `album`, `notice` 등 기능/화면 단위
- 생략 가능

## 커밋 명령어

### 기본 커밋
```bash
git add <files>
git commit -m "$(cat <<'EOF'
[PK-12345] feat(album) : 앨범 삭제 기능 추가
EOF
)"
```

### 파일별 스테이징
```bash
git add -p                  # 부분 스테이징 (인터랙티브)
git add src/main/*.kt       # 패턴 매칭
git add .                   # 전체 (주의)
```

### 커밋 수정 (푸시 전만)
```bash
# 메시지 수정
git commit --amend -m "새 메시지"

# 파일 추가 후 수정
git add forgotten_file.kt
git commit --amend --no-edit
```

## 주의사항

- **절대 금지**: 이미 푸시된 커밋 amend
- **금지 파일**: `.env`, `credentials.json`, API 키 포함 파일
- **권장**: 작은 단위로 자주 커밋
