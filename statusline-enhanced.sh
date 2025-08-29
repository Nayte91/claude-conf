#!/bin/bash

# Read Claude Code session data
input=$(cat)

# Extract session data
session_start=$(echo "$input" | jq -r '.session_id' | cut -d'-' -f1)
current_time=$(date +%s)

# Calculate block time remaining (5 hours = 18000 seconds)
if [[ "$session_start" =~ ^[0-9]+$ ]]; then
    elapsed=$((current_time - session_start))
    remaining=$((18000 - elapsed))
    
    if [ $remaining -gt 0 ]; then
        hours=$((remaining / 3600))
        minutes=$(((remaining % 3600) / 60))
        if [ $hours -gt 0 ]; then
            timer_display="${hours}h${minutes}m"
        else
            timer_display="${minutes}m"
        fi
    else
        timer_display="0m"
    fi
else
    timer_display="--"
fi

# Get current working directory
pwd_display="$(pwd)"

# Get git branch with error handling
git_branch="$(git -c core.abbrev=40 branch --show-current 2>/dev/null || echo 'no-git')"

# Get git lines added/removed (last 24 hours, author-filtered)
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Get current user's email for filtering
    git_user=$(git config user.email 2>/dev/null || echo "")
    
    if [ -n "$git_user" ]; then
        # Get stats for commits by current user in last 24 hours
        since_date=$(date -d "1 day ago" +%Y-%m-%d)
        stats=$(git log --author="$git_user" --since="$since_date" --numstat --pretty=format: 2>/dev/null | \
                awk '{added += $1; deleted += $2} END {printf "+%d/-%d", added+0, deleted+0}')
    else
        # Fallback: get stats for all recent commits
        since_date=$(date -d "1 day ago" +%Y-%m-%d)
        stats=$(git log --since="$since_date" --numstat --pretty=format: 2>/dev/null | \
                awk '{added += $1; deleted += $2} END {printf "+%d/-%d", added+0, deleted+0}')
    fi
    
    # If no stats found, show zeros
    if [ "$stats" = "+0/-0" ] || [ -z "$stats" ]; then
        stats="+0/-0"
    fi
else
    stats="+0/-0"
fi

# Output the enhanced statusline
# Colors: Blue for directory, Yellow for git branch, Cyan for timer, Green for stats
printf '\033[01;34m%s\033[00m | \033[01;33m%s\033[00m | \033[01;36m⏱️ %s\033[00m | \033[01;32m%s\033[00m' \
    "$pwd_display" \
    "$git_branch" \
    "$timer_display" \
    "$stats"