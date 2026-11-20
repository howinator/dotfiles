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

  # Pane indices are renumbered by each split, so capture the stable pane ID
  # (%N) before splitting and target by ID thereafter.
  local top
  top=$(tmux list-panes -t "$W" -F '#{pane_id}' | head -1)

  # Bottom pane (40% height)
  tmux split-window -t "$top" -v -c "$WORK_DIR" -p 40

  # Name the claude pane so sibling panes can target it. The pane title
  # (select-pane -T) is human-visible but programs can overwrite it via OSC
  # title escapes, so also pin a pane user option that nothing else touches.
  tmux select-pane -t "$top" -T 'main-agent-session'
  tmux set -pt "$top" @pane_name 'main-agent-session'

  tmux select-pane -t "$top"
  tmux send-keys -t "$top" "claude 'The ticket number is in the branch name. Read the ticket using the linear MCP and then write a plan for the fix'" Enter
}

ondestroy() {
  :
}

"$@"
