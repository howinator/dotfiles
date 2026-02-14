#!/bin/bash
# Rollback script for improved tmux notifications
# Undoes all changes made by the notification enhancement plan

set -e

echo "Rolling back tmux notification changes..."

# 1. Remove monitor-bell and window-status-bell-style lines from tmux.conf
TMUX_CONF="$HOME/.config/tmux/tmux.conf"
if [ -f "$TMUX_CONF" ]; then
  sed -i '' '/^# Bell style for Claude Code notifications$/d' "$TMUX_CONF"
  sed -i '' '/^set-window-option -g monitor-bell on$/d' "$TMUX_CONF"
  sed -i '' "/^set-window-option -g window-status-bell-style 'fg=white,bg=red,bold'$/d" "$TMUX_CONF"
  echo "  Removed bell style lines from tmux.conf"
fi

# 2. Remove TMUX_LOCATION/TMUX_WINDOW_NAME block from .zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
  sed -i '' '/^# Capture tmux pane location for Claude Code hooks$/d' "$ZSHRC"
  sed -i '' '/^if \[ -n "\$TMUX" \] && \[ -z "\$TMUX_LOCATION" \]; then$/,/^fi$/{ /TMUX_LOCATION\|TMUX_WINDOW_NAME/d; /^if \[ -n "\$TMUX" \] && \[ -z "\$TMUX_LOCATION" \]; then$/d; /^fi$/d; }' "$ZSHRC"
  echo "  Removed TMUX_LOCATION block from .zshrc"
fi

# 3. Restore notify.sh to pre-change version
cat > "$HOME/.claude/hooks/notify.sh" << 'NOTIFY_EOF'
#!/bin/bash
# Send bell to the tmux pane's TTY (tmux picks this up via monitor-bell)
if [ -n "$TMUX_PANE" ]; then
  PANE_TTY=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}')
  printf '\a' > "$PANE_TTY" 2>/dev/null
fi

# Read hook input for the notification message
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude Code needs your input"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')

# Send macOS notification
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null

exit 0
NOTIFY_EOF
chmod +x "$HOME/.claude/hooks/notify.sh"
echo "  Restored notify.sh to original version"

# 4. Delete go-tmux.sh
if [ -f "$HOME/.claude/hooks/go-tmux.sh" ]; then
  rm "$HOME/.claude/hooks/go-tmux.sh"
  echo "  Deleted go-tmux.sh"
fi

# 5. Uninstall terminal-notifier
if command -v terminal-notifier &>/dev/null; then
  brew uninstall terminal-notifier 2>/dev/null || true
  echo "  Uninstalled terminal-notifier"
fi

# 6. Reload tmux config
if [ -n "$TMUX" ]; then
  tmux source-file "$TMUX_CONF" 2>/dev/null || true
  echo "  Reloaded tmux config"
fi

echo "Rollback complete. Open a new shell to pick up .zshrc changes."
