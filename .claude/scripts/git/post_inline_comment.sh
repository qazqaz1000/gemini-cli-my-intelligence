#!/bin/bash
# GitHub PR 인라인 코멘트 작성 함수

# 사용법:
# post_inline_comment <PR_NUMBER> <FILE_PATH> <LINE_NUMBER> <COMMENT_BODY>

set -e

PR_NUMBER=$1
FILE_PATH=$2
LINE_NUMBER=$3
COMMENT_BODY=$4

if [[ -z "$PR_NUMBER" ]] || [[ -z "$FILE_PATH" ]] || [[ -z "$LINE_NUMBER" ]] || [[ -z "$COMMENT_BODY" ]]; then
    echo "Usage: post_inline_comment.sh <PR_NUMBER> <FILE_PATH> <LINE_NUMBER> <COMMENT_BODY>"
    exit 1
fi

# GitHub repo 정보 가져오기
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

# PR의 최신 commit SHA 가져오기
COMMIT_SHA=$(gh pr view "$PR_NUMBER" --json headRefOid --jq .headRefOid)

if [[ -z "$COMMIT_SHA" ]]; then
    echo "❌ Failed to get commit SHA for PR #$PR_NUMBER"
    exit 1
fi

# 인라인 코멘트 작성
gh api "repos/$REPO/pulls/$PR_NUMBER/comments" \
    --method POST \
    -f body="$COMMENT_BODY" \
    -f commit_id="$COMMIT_SHA" \
    -f path="$FILE_PATH" \
    -f line="$LINE_NUMBER" \
    > /dev/null 2>&1

if [[ $? -eq 0 ]]; then
    echo "✅ Inline comment posted: $FILE_PATH:$LINE_NUMBER"
else
    echo "⚠️  Failed to post inline comment: $FILE_PATH:$LINE_NUMBER"
    echo "   (파일이 PR diff에 없거나 라인 번호가 변경되었을 수 있습니다)"
fi
