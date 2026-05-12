#!/usr/bin/env bash
# dotfiles tmux window layout:
#   +------------------------------+
#   |        claude code           |  pane 1
#   +------------------------------+
#   |          shell               |  pane 2
#   +------------------------------+

oncreate() {
  local WORK_DIR="$1"
  local W="$2"  # tmux window ID — use for all -t targeting (see README)

  # Create bottom pane (40% height)
  tmux split-window -t "$W.1" -v -c "$WORK_DIR" -p 40

  # Pane 1: claude code
  tmux select-pane -t "$W.1"
  tmux send-keys -t "$W.1" "claude 'The ticket number is in the branch name. Read the ticket using the linear MCP and then write a plan for the fix'" Enter
}

ondestroy() {
  :
}

"$@"
