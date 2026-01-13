---
name: git-helper
description: |
  Git과 GitHub(gh CLI) 작업. 커밋, PR, 브랜치 관리 지원.
  트리거: "커밋", "PR 생성", "브랜치"
---

# Git Helper

Git과 GitHub CLI(gh)를 사용한 버전 관리.

## 커밋 메시지 형식

```
[PK-XXXXX] type(scope) : 한국어 설명

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Type**: feat, fix, refactor, docs, test, chore

## 주요 워크플로우

### 커밋
```bash
git status && git diff
git add <files>
git commit -m "$(cat <<'EOF'
[PK-12345] feat(login) : 소셜 로그인 추가

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### PR 생성
```bash
# 1. Base branch 자동 결정
~/.claude/scripts/git/get_base_branch.sh

# 2. 프로젝트 템플릿 확인 (우선순위 순)
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
- 변경사항

## Test plan
- [ ] 테스트 항목

🤖 Generated with Claude Code"
fi

# 3. 푸시 및 PR 생성
git push -u origin $(git branch --show-current)
gh pr create --base <base> --assignee @me --title "[PK-XXXXX] 요약" --body "$template_body"
```

### 브랜치
```bash
git checkout -b feature/service-YYMMDD/PK-XXXXX
git rebase origin/develop
```

## 안전 규칙

- `--force` 금지 (main/develop)
- `--no-verify` 금지
- 커밋 전 diff 확인 필수
