#!/usr/bin/env bash
# Dispatcher: runs a repo's .tmux-window.sh when a new tmux window is created.
# Skips if tmuxwt already handled the setup.

# Avoid double-running if tmuxwt already set up this window
if [[ "$(tmux show-options -wv @tmux-window-scripted 2>/dev/null)" == "1" ]]; then
  exit 0
fi

pane_path=$(tmux display-message -p '#{pane_current_path}')

# Walk up directories looking for .tmux-window.sh
dir="$pane_path"
while [[ "$dir" != "/" ]]; do
  if [[ -f "$dir/.tmux-window.sh" ]]; then
    tmux set-option -w @tmux-window-scripted 1
    bash "$dir/.tmux-window.sh" "$pane_path"
    exit 0
  fi
  dir=$(dirname "$dir")
done
