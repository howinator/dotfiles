#!/bin/bash
LOCATION="$1"

if [[ "$LOCATION" =~ ^([^:]+):([0-9]+)\.([0-9]+)$ ]]; then
  SESSION="${BASH_REMATCH[1]}"
  WINDOW="${BASH_REMATCH[2]}"
  PANE="${BASH_REMATCH[3]}"

  tmux select-window -t "$SESSION:$WINDOW"
  tmux select-pane -t "$SESSION:$WINDOW.$PANE"
fi

# Bring Kitty to foreground
osascript -e 'tell application "kitty" to activate' 2>/dev/null
