#!/bin/bash
# Read hook input for the notification message
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude Code needs your input"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')

# Build subtitle with tmux window name and position
SUBTITLE=""
if [ -n "$TMUX_WINDOW_NAME" ] && [ -n "$TMUX_LOCATION" ]; then
  SUBTITLE="$TMUX_WINDOW_NAME ($TMUX_LOCATION)"
elif [ -n "$TMUX_WINDOW_NAME" ]; then
  SUBTITLE="$TMUX_WINDOW_NAME"
fi

# Pull session summary from cc-live state.db
DB="$HOME/.cc-live/state.db"
SESSION_SUMMARY=""
if [ -f "$DB" ] && command -v sqlite3 &>/dev/null; then
  SESSION_SUMMARY=$(sqlite3 "$DB" \
    "SELECT ss.summary FROM sessions s
     JOIN session_stats ss ON s.session_id = ss.session_id
     WHERE s.cwd = '$(printf '%s' "$PWD" | sed "s/'/''/g")'
     ORDER BY ss.updated_at DESC LIMIT 1;" 2>/dev/null)
fi

# Append summary to message if we got one
if [ -n "$SESSION_SUMMARY" ]; then
  MESSAGE="$MESSAGE
$SESSION_SUMMARY"
fi

# Send macOS notification
if command -v terminal-notifier &>/dev/null; then
  ARGS=(
    -title "$TITLE"
    -message "$MESSAGE"
  )

  # Add subtitle with window location
  if [ -n "$SUBTITLE" ]; then
    ARGS+=(-subtitle "$SUBTITLE")
  fi

  # Click-to-navigate if we know the tmux location
  if [ -n "$TMUX_LOCATION" ]; then
    ARGS+=(-execute "$HOME/.claude/hooks/go-tmux.sh '$TMUX_LOCATION'")
    ARGS+=(-group "claude-$TMUX_LOCATION")
  fi

  terminal-notifier "${ARGS[@]}" 2>/dev/null
else
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
fi

exit 0
