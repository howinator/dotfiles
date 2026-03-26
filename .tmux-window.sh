#!/usr/bin/env bash
# dotfiles tmux window layout:
#   +------------------------------+
#   |        claude code           |  pane 1
#   +------------------------------+
#   |          shell               |  pane 2
#   +------------------------------+

oncreate() {
  local WORK_DIR="$1"

  # Create bottom pane (40% height)
  tmux split-window -v -c "$WORK_DIR" -p 40

  # Pane 1: claude code
  tmux select-pane -t :.1
  tmux send-keys -t :.1 "claude 'The ticket number is in the branch name. Read the ticket using the linear MCP and then write a plan for the fix'" Enter
}

ondestroy() {
  :
}

"$@"
