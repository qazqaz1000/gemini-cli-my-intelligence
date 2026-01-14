#!/bin/bash
# GitHub PR 전체 리뷰 요약 작성

# 사용법:
# post_review_summary.sh <PR_NUMBER> <SUMMARY_FILE>

set -e

PR_NUMBER=$1
SUMMARY_FILE=$2

if [[ -z "$PR_NUMBER" ]] || [[ -z "$SUMMARY_FILE" ]]; then
    echo "Usage: post_review_summary.sh <PR_NUMBER> <SUMMARY_FILE>"
    exit 1
fi

if [[ ! -f "$SUMMARY_FILE" ]]; then
    echo "❌ Summary file not found: $SUMMARY_FILE"
    exit 1
fi

# PR 전체 코멘트 작성
gh pr review "$PR_NUMBER" --comment --body-file "$SUMMARY_FILE"

if [[ $? -eq 0 ]]; then
    echo "✅ Review summary posted to PR #$PR_NUMBER"
else
    echo "❌ Failed to post review summary"
    exit 1
fi
