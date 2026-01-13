#!/bin/bash
# Claude Code Status Line
# Shows: Model | Directory | Git Branch | Context Usage

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')
USAGE=$(echo "$input" | jq '.context_window.current_usage')

# Git branch
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 $BRANCH"
    fi
fi

# Context usage
CONTEXT_INFO=""
if [ "$USAGE" != "null" ] && [ "$USAGE" != "" ]; then
    CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    if [ "$CURRENT_TOKENS" != "null" ] && [ "$CURRENT_TOKENS" -gt 0 ]; then
        PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
        CONTEXT_INFO=" | 📊 ${PERCENT_USED}%"
    fi
fi

# Session cost
COST_INFO=""
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
if [ "$COST" != "0" ] && [ "$COST" != "null" ]; then
    # Round to 2 decimal places
    COST_ROUNDED=$(printf "%.2f" "$COST")
    COST_INFO=" | 💰 \$${COST_ROUNDED}"
fi

echo "🤖 $MODEL  📁 ${CURRENT_DIR##*/}$GIT_BRANCH$CONTEXT_INFO$COST_INFO"
