#!/usr/bin/env bash
# Outputs a colored emoji dot representing PR status for a given directory.
# Called per-window via #() in window-status-format.
# Usage: pr-status.sh /path/to/repo

pane_path="$1"

# Bail if not a git repo
if ! git -C "$pane_path" rev-parse --git-dir &>/dev/null; then
  exit 0
fi

branch=$(git -C "$pane_path" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ -z "$branch" || "$branch" == "HEAD" ]]; then
  exit 0
fi

# Main/master branches get a neutral grey dot
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  printf '⚪'
  exit 0
fi

# Cache to avoid hammering the GitHub API every status-interval
cache_dir="/tmp/tmux-pr-status"
mkdir -p "$cache_dir"
cache_key=$(printf '%s:%s' "$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null)" "$branch" | md5 -q)
cache_file="$cache_dir/$cache_key"

if [[ -f "$cache_file" ]]; then
  cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file") ))
  if [[ $cache_age -lt 60 ]]; then
    cat "$cache_file"
    exit 0
  fi
fi

# Query GitHub for PR state
repo_root=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null)
pr_state=$(cd "$repo_root" && gh pr view "$branch" --json state -q '.state' 2>/dev/null)

case "$pr_state" in
  OPEN)    result="🟢" ;;
  MERGED)  result="🟣" ;;
  CLOSED)  result="🔴" ;;
  *)       result="🟡" ;;
esac

printf '%s' "$result" > "$cache_file"
cat "$cache_file"
