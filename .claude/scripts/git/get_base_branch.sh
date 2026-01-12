#!/bin/bash
# PR base branch 자동 결정 스크립트

set -e

current_branch=$(git branch --show-current 2>/dev/null)

if [[ -z "$current_branch" ]]; then
    echo '{"success": false, "error": "Not a git repository or no branch checked out"}'
    exit 1
fi

# 패턴 매칭으로 base 결정
if [[ $current_branch =~ ^feature/([^/]+)/(pk-|PK-) ]]; then
    project="${BASH_REMATCH[1]}"
    base_branch="feature/${project}/main"

elif [[ $current_branch =~ ^feature/([^/]+)/main$ ]]; then
    # feature/*/main → 최신 freezing 브랜치 찾기
    freezing=$(git branch -r | grep -E "origin/feature/freezing-.*/main" | sort -V | tail -1 | tr -d ' ')
    if [[ -n "$freezing" ]]; then
        base_branch="${freezing#origin/}"
    else
        base_branch="develop"
    fi

elif [[ $current_branch =~ ^hotfix/ ]]; then
    base_branch="master"

elif [[ $current_branch =~ ^release/ ]]; then
    base_branch="master"

elif [[ $current_branch =~ ^bugfix/ ]]; then
    base_branch="develop"

else
    base_branch="develop"
fi

# base branch 존재 확인
if git show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
    echo "{\"success\": true, \"data\": {\"current\": \"$current_branch\", \"base\": \"$base_branch\"}}"
else
    # fallback to develop
    if git show-ref --verify --quiet "refs/remotes/origin/develop"; then
        echo "{\"success\": true, \"data\": {\"current\": \"$current_branch\", \"base\": \"develop\", \"warning\": \"$base_branch not found, using develop\"}}"
    else
        echo '{"success": false, "error": "No valid base branch found"}'
        exit 1
    fi
fi
