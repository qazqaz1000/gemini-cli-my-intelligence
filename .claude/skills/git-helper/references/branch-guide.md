# 브랜치 가이드

## 브랜치 네이밍

```
feature/PK-XXXXX/short-description
fix/PK-XXXXX/bug-description
hotfix/PK-XXXXX/critical-fix
```

### 예시
- `feature/PK-12345/album-delete`
- `fix/PK-12346/crash-on-login`
- `hotfix/PK-12347/payment-error`

## 브랜치 생성

### 새 브랜치 생성 및 전환
```bash
# develop에서 새 브랜치
git checkout develop
git pull origin develop
git checkout -b feature/PK-12345/new-feature

# 또는 한 줄로
git checkout -b feature/PK-12345/new-feature develop
```

### 원격 브랜치 체크아웃
```bash
git fetch origin
git checkout -b local-name origin/remote-branch
```

## 브랜치 관리

### 목록 조회
```bash
git branch              # 로컬 브랜치
git branch -r           # 원격 브랜치
git branch -a           # 전체
git branch -vv          # 업스트림 정보 포함
```

### 삭제
```bash
git branch -d branch-name       # 머지된 브랜치 삭제
git branch -D branch-name       # 강제 삭제
git push origin --delete branch # 원격 브랜치 삭제
```

### 이름 변경
```bash
git branch -m old-name new-name
```

## Rebase

### develop 최신화 반영
```bash
git checkout feature/PK-12345/my-feature
git fetch origin
git rebase origin/develop
```

### 충돌 해결
```bash
# 1. 충돌 파일 수정
# 2. 스테이징
git add <resolved-files>
# 3. rebase 계속
git rebase --continue
# 또는 중단
git rebase --abort
```

### Interactive Rebase (로컬 커밋 정리)
```bash
git rebase -i HEAD~3    # 최근 3개 커밋 정리
```

## Merge

### Feature → develop
```bash
git checkout develop
git merge feature/PK-12345/my-feature
```

### Merge 전략
- **merge commit**: 히스토리 보존 (기본)
- **squash**: 하나의 커밋으로 합침
- **rebase**: 선형 히스토리

## 주의사항

- `main`, `master`, `develop` 직접 푸시 금지
- rebase는 로컬 커밋에만 사용
- force push는 개인 브랜치에서만 (확인 후)

```bash
# force push가 필요한 경우 (rebase 후)
git push --force-with-lease origin my-branch
```

## gh CLI 브랜치 작업

```bash
# PR과 연결된 브랜치 체크아웃
gh pr checkout <number>

# 현재 브랜치의 PR 보기
gh pr view
```
