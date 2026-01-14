# PR(Pull Request) 가이드

## Base Branch 결정

PR 생성 시 올바른 base branch를 자동으로 결정합니다.

### 결정 로직

**1단계: Git 히스토리에서 분기 지점 추적 (우선)**
```bash
# 현재 브랜치가 어디서 분기했는지 확인
git log --first-parent --oneline | grep -E "(Merge|branch)" | head -1
git branch -r --contains HEAD | grep -v "$(git branch --show-current)"

# 또는 최근 공통 조상 찾기
git merge-base --fork-point origin/develop HEAD  # develop에서 분기한 경우
git merge-base --fork-point origin/feature/*/main HEAD  # feature main에서 분기한 경우
```

**2단계: 브랜치 이름 패턴 매칭 (보조)**

| 현재 브랜치 패턴 | Base Branch | 설명 |
|---|---|---|
| `feature/{project}/pk-*` | `feature/{project}/main` | 프로젝트 내 작업 브랜치 |
| `feature/{project}/main` | `feature/freezing-*/main` | 프로젝트 메인 → 스프린트 |
| `hotfix/*` | `master` 또는 hotfix 전용 | 핫픽스 브랜치 |
| `release/*` | `master` | 릴리즈 브랜치 |
| `bugfix/*` | `develop` | 버그 수정 브랜치 |
| 기타 | `develop` | 기본값 |

### 자동 탐지 스크립트

```bash
# 현재 브랜치 이름 추출
current_branch=$(git branch --show-current)

# 패턴 매칭으로 base 결정
if [[ $current_branch =~ ^feature/([^/]+)/(pk-|PK-) ]]; then
  # feature/{project}/pk-* → feature/{project}/main
  project="${BASH_REMATCH[1]}"
  base_branch="feature/${project}/main"

elif [[ $current_branch =~ ^hotfix/ ]]; then
  # hotfix/* → master
  base_branch="master"

elif [[ $current_branch =~ ^release/ ]]; then
  # release/* → master
  base_branch="master"

elif [[ $current_branch =~ ^bugfix/ ]]; then
  # bugfix/* → develop
  base_branch="develop"

else
  # 기본값: develop
  base_branch="develop"
fi

# base branch 존재 확인
if git show-ref --verify --quiet refs/remotes/origin/$base_branch; then
  echo "Base branch: $base_branch"
else
  echo "Warning: $base_branch does not exist. Falling back to develop"
  base_branch="develop"
fi
```

## PR 생성 전 확인

```bash
# 1. Base branch 결정 (위 로직 사용)

# 2. 현재 브랜치 상태
git status

# 3. 베이스 브랜치와 차이
git log <base-branch>..HEAD --oneline
git diff <base-branch>...HEAD

# 4. 원격 동기화 확인
git fetch origin
git status  # "Your branch is ahead" 확인
```

## PR 제목 규칙

```
커밋: [PK-XXXXX] type(scope) : 설명
PR:   [PK-XXXXX] 전체 작업 요약        ← type(scope) 없음
```

**작성 순서**: Jira 티켓 조회 → 실제 작업 내용과 종합 → 요약

**예시**: `[PK-12345] 소셜 로그인 추가 및 에러 처리 개선`

## PR 생성

### 프로젝트 템플릿 자동 인식

PR 생성 시 프로젝트에 정의된 템플릿을 자동으로 사용합니다.

**탐색 순서** (우선순위):
1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `docs/pull_request_template.md`
4. `PULL_REQUEST_TEMPLATE.md`

템플릿이 없으면 기본 포맷을 사용합니다.

### 기본 명령
```bash
# 템플릿 자동 감지 및 적용
template_paths=(
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/pull_request_template.md"
  "docs/pull_request_template.md"
  "PULL_REQUEST_TEMPLATE.md"
)

template_body=""
for path in "${template_paths[@]}"; do
  if [[ -f "$path" ]]; then
    template_body=$(cat "$path")
    echo "✓ 템플릿 사용: $path"
    break
  fi
done

# 템플릿이 없으면 기본 포맷
if [[ -z "$template_body" ]]; then
  template_body="## Summary
- 주요 변경사항 1
- 주요 변경사항 2

## Test plan
- [ ] 기능 테스트 완료
- [ ] UI 확인
- [ ] 엣지 케이스 테스트"
fi

gh pr create --assignee @me --title "[PK-XXXXX] 전체 작업 요약" --body "$template_body"
```

### 베이스 브랜치 지정
```bash
gh pr create --base develop --title "..." --body "..."
```

### Draft PR
```bash
gh pr create --draft --title "..." --body "..."
```

## PR 템플릿

### 기본 템플릿 (Default)
프로젝트에 템플릿이 없을 때 사용하는 기본 포맷입니다.

```markdown
## Summary
- 이 PR이 해결하는 문제 또는 추가하는 기능
- 주요 변경사항 bullet points

## Test plan
- [ ] 단위 테스트 통과
- [ ] 기능 동작 확인
- [ ] 리그레션 테스트

## Related
- Jira: [PK-XXXXX](https://kidsnote.atlassian.net/browse/PK-XXXXX)
```

### 프로젝트별 커스터마이징

각 프로젝트는 `.github/PULL_REQUEST_TEMPLATE.md`에 자체 템플릿을 정의할 수 있습니다.

**예시: KidsNote Android**
- 작업 내용 (지라 티켓, 기획서, 피그마)
- 테스트 시나리오 (최소/최신 버전, 해상도)
- 변경 사항 요약
- 리뷰 노트
- 스크린샷 (수정전/수정후)

PR 생성 시 이러한 프로젝트별 템플릿이 자동으로 적용됩니다.

## PR 관리

### 조회
```bash
gh pr list                      # 전체 목록
gh pr list --author @me         # 내가 만든 PR
gh pr view <number>             # 상세 보기
gh pr view <number> --web       # 브라우저에서 열기
```

### 리뷰 요청
```bash
gh pr edit <number> --add-reviewer user1,user2
```

### 머지
```bash
gh pr merge <number>                    # 기본 (merge commit)
gh pr merge <number> --squash           # squash merge
gh pr merge <number> --rebase           # rebase merge
gh pr merge <number> --delete-branch    # 머지 후 브랜치 삭제
```

### 체크 상태 확인
```bash
gh pr checks <number>
```

## 주의사항

- PR 제목에 Jira 티켓 번호 포함
- 변경 범위가 크면 여러 PR로 분리
- 리뷰어 피드백 반영 후 re-request review
