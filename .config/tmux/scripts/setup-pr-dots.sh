#!/usr/bin/env bash
# Runs after tpm/Dracula to prepend PR status dots to window tabs.
# Captures Dracula's window-status-format and prepends the pr-status emoji.

fmt=$(tmux show -gv window-status-format)
cfmt=$(tmux show -gv window-status-current-format)

tmux set -g window-status-format "#(~/.config/tmux/scripts/pr-status.sh #{pane_current_path})${fmt}"
tmux set -g window-status-current-format "#(~/.config/tmux/scripts/pr-status.sh #{pane_current_path})${cfmt}"
