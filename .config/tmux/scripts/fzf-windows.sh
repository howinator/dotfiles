#!/usr/bin/env bash
# Fuzzy-pick a window from ALL sessions, grouped by session like choose-tree.
# Bound in tmux.conf to a full-size display-popup.

current=$(tmux display-message -p '#S:#I')
width=$(tmux list-sessions -F '#{session_name}' | awk '{ if (length > m) m = length } END { print m }')

target=$(
  tmux list-windows -a -F "#{session_name}:#{window_index}	#{session_name}	#{window_index}	#{window_name}" |
    awk -F'\t' -v cur="$current" -v w="$width" '
      {
        # Session name bright on its first window, dim on the rest -> reads like a tree.
        color = ($2 != last) ? "\033[1;35m" : "\033[38;5;240m"
        last = $2
        mark = ($1 == cur) ? "\033[1;32m●\033[0m" : " "
        printf "%s\t%s%-*s\033[0m │ %s %2s  %s\n", $1, color, w, $2, mark, $3, $4
      }' |
    fzf --ansi --reverse --no-sort --tiebreak=index \
      --delimiter=$'\t' --with-nth=2.. \
      --prompt='window> ' --info=inline \
      --preview 'tmux capture-pane -ep -t {1}' \
      --preview-window='right,50%,follow' |
    cut -f1
)

[ -n "$target" ] && tmux switch-client -t "$target"
