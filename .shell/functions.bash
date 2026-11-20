git_delete_remote_tag() {
  git tag -d "$1"
  git push origin ":refs/tags/$1"
}

git_rename_branch() {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$current_branch" == 'main' || "$current_branch" == 'develop' ]]; then
    echo "try not to delete an important branch next time"
    exit 1
  fi
  git branch -m "$1"
  git push origin :"$current_branch"
  git push origin "$1"
}

idea() {
  open -na "/Applications/IntelliJ IDEA.app" --args "$@"
}

brew-install() {
  echo "$@"
  brew install "$@" || return
  brew bundle dump --file=~/dotfiles/Brewfile -f
  git -C "$HOME/dotfiles" add Brewfile
  git -C "$HOME/dotfiles" commit -S -m "Add $1 to Brewfile"
  git -C "$HOME/dotfiles" push origin main
}

show-bat-themes() {
  local file=${1:-~/projects/detail/packages/replay/src/cli.ts}
  bat --list-themes | fzf --preview="bat --theme={} --color=always ${file}"
}

function frg {
  result=$(rg --no-ignore --hidden --ignore-case --color=always --line-number --no-heading "$@" 2>/dev/null |
    fzf --ansi \
      --color 'hl:-1:underline,hl+:-1:underline:reverse' \
      --delimiter ':' \
      --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
  file=${result%%:*}
  linenumber=$(echo "${result}" | cut -d: -f2)
  if [[ -n "$file" ]]; then
    $EDITOR +"${linenumber}" "$file"
  fi
}

function readme() {
  bat ~/dotfiles/README.md
}

function cheatmd() {
  cheat "$1" | mdcat
}

function relpath() {
  source=$1
  target=$2

  common_part=$source
  back=
  while [ "${target#$common_part}" = "${target}" ]; do
    common_part=$(dirname $common_part)
    back="../${back}"
  done

  echo ${back}${target#$common_part/}
}

function gd() {
  local commit=${1:-HEAD}
  git diff "$commit" -- \
    ':(top,exclude)*package-lock.json' \
    ':(top,exclude)*yarn.lock' \
    ':(top,exclude)*pnpm-lock.yaml'
}

psql() {
  if [[ -f ".env" ]]; then
    local conn_string=$(sed -n 's/^PG_CONNECTION_STRING=//p' .env | sed 's/^"\(.*\)"$/\1/')
    if [[ -n "$conn_string" ]]; then
      echo "INFO: Using connection string from .env file in $(pwd)"
      command psql "$conn_string"
    else
      command psql "$@"
    fi
  else
    command psql "$@"
  fi
}

function re_pair() {
  trackpad_id=$(blueutil --paired | grep "Howie.*Trackpad" | grep -Eo '[a-z0-9]{2}(-[a-z0-9]{2}){5}')
  trackpad_name=$(blueutil --paired | grep "Howie.*Trackpad" | grep -Eo 'name: ".*"')

  keyboard_id=$(blueutil --paired | grep "Howie.*Keyboard" | grep -Eo '[a-z0-9]{2}(-[a-z0-9]{2}){5}')
  keyboard_name=$(blueutil --paired | grep "Howie.*Keyboard" | grep -Eo 'name: ".*"')

  echo "unpairing trackpad BT device $trackpad_id, $trackpad_name"
  blueutil --unpair "$trackpad_id"
  echo "unpairing keyboard BT device $keyboard_id, $keyboard_name"
  blueutil --unpair "$keyboard_id"

  echo "unpaired, waiting a few seconds for trackpad and keyboard to go to pairable state"
  sleep 10
  echo "pairing trackpad with BT device $trackpad_id, $trackpad_name"
  blueutil --pair "$trackpad_id" "0000"
  echo "trackpad paired"
  blueutil --connect "$trackpad_id"
  echo "trackpad connected"
  sleep 2

  echo "pairing keyboard with BT device $keyboard_id, $keyboard_name"
  blueutil --pair "$keyboard_id" "0000"
  echo "keyboard paired"
  blueutil --connect "$keyboard_id"
  echo "keyboard connected"
}

function gwt() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: gwt <branch-name>"
    return 1
  fi
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not a git repository"
    return 1
  }
  # Use the main worktree so calling gwt from inside a linked worktree still
  # resolves paths against the original repo.
  local repo_root
  repo_root=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
  local repo_name=$(basename "$repo_root")
  local worktree_path="$HOME/.worktrees/${repo_name}-${branch}"
  if [[ -d "$worktree_path" ]]; then
    cd "$worktree_path"
  elif git show-ref --verify --quiet "refs/heads/${branch}"; then
    git worktree add "$worktree_path" "$branch" && cd "$worktree_path"
  else
    git worktree add -b "$branch" "$worktree_path" && cd "$worktree_path"
  fi

  # Symlink .claude/settings.local.json so permissions carry over
  if [[ -f "$repo_root/.claude/settings.local.json" && ! -e "$worktree_path/.claude/settings.local.json" ]]; then
    mkdir -p "$worktree_path/.claude"
    ln -sf "$repo_root/.claude/settings.local.json" "$worktree_path/.claude/settings.local.json"
  fi

  # Copy .tmux-window.sh (gitignored, so it isn't checked out) so tmuxwt/cleanwt
  # can be run from inside this worktree to spawn/tear down further worktrees.
  if [[ -f "$repo_root/.tmux-window.sh" && ! -e "$worktree_path/.tmux-window.sh" ]]; then
    cp "$repo_root/.tmux-window.sh" "$worktree_path/.tmux-window.sh"
  fi
}

function cleanwt() {
  # Thin wrapper around scripts/cleanwt (on PATH via ~/dotfiles/scripts) so the
  # shell ends up in the main worktree after the current one is destroyed.
  local main_worktree
  main_worktree=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  command cleanwt "$@" || return $?
  [[ -n "$main_worktree" ]] && cd "$main_worktree"
}

function gwt-clean() {
  local worktree_path
  worktree_path=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Not a git repository"
    return 1
  }
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
    echo "Could not determine branch"
    return 1
  }
  if [[ "$worktree_path" != "$HOME/.worktrees/"* ]]; then
    echo "Not in a worktree managed by gwt"
    return 1
  fi
  local main_worktree
  main_worktree=$(git worktree list --porcelain | head -1 | sed 's/worktree //')

  # Merge worktree permissions into main repo's settings.local.json
  local wt_settings="$worktree_path/.claude/settings.local.json"
  local main_settings="$main_worktree/.claude/settings.local.json"
  if [[ -f "$wt_settings" && ! -L "$wt_settings" ]]; then
    if [[ -f "$main_settings" ]]; then
      local merged
      merged=$(jq -s '
        (.[0].permissions.allow // []) as $main |
        (.[1].permissions.allow // []) as $wt |
        .[0] * { permissions: { allow: ($main + ($wt - $main)) } }
      ' "$main_settings" "$wt_settings") && echo "$merged" >"$main_settings"
    else
      mkdir -p "$main_worktree/.claude"
      cp "$wt_settings" "$main_settings"
    fi
    echo "Merged worktree permissions into $main_settings"
  fi

  cd "$main_worktree"
  if ! git worktree remove --force "$worktree_path"; then
    echo "Failed to remove worktree at $worktree_path"
    return 1
  fi
  if ! git branch -d "$branch" 2>/dev/null; then
    # git branch -d doesn't detect squash-merges. Instead, check if the
    # remote branch was deleted (GitHub removes it after merge).
    if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
      echo "Branch '$branch' still exists on remote and is not merged. Use 'git branch -D $branch' to force delete."
    else
      git branch -D "$branch"
    fi
  fi
}

function yolopr() {
  gh pr create --fill && gh pr merge --auto --squash && gh pr view --web
}

function wtfd() {
  git worktree list --porcelain | grep -B2 "branch refs/heads/$1" | grep "^worktree " | cut -d' ' -f2
}

function gh() {
  command gh "$@"
  local rc=$?
  if [[ $rc -eq 0 && "$1" == "pr" && ("$2" == "create" || "$2" == "merge" || "$2" == "close" || "$2" == "reopen") ]]; then
    local repo_root branch cache_key
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$repo_root" && -n "$branch" ]]; then
      cache_key=$(printf '%s:%s' "$repo_root" "$branch" | md5 -q)
      rm -f "/tmp/tmux-pr-status/$cache_key" 2>/dev/null
    fi
  fi
  return $rc
}

function tmuxwt() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: tmuxwt <branch-name>"
    return 1
  fi

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not a git repository"
    return 1
  }
  # Resolve the main worktree so tmuxwt works correctly when called from inside
  # an existing linked worktree.
  local repo_root
  repo_root=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
  local repo_name=$(basename "$repo_root")
  local worktree_path="$HOME/.worktrees/${repo_name}-${branch}"

  # Create worktree + symlink claude settings (subshell so calling shell stays put)
  (gwt "$branch") || return 1

  # Window name: first 24 chars of branch, stripping the `howie/` user prefix
  local display_branch="${branch#howie/}"
  local window_name="${display_branch:0:24}"

  # Create the new tmux window and capture its ID so we can pass it to the
  # script for explicit -t targeting (no racing on "active window").
  local window_id
  window_id=$(tmux new-window -P -F '#{window_id}' -c "$worktree_path" -n "$window_name") || return 1

  # Resolve which .tmux-window.sh to run, preferring the worktree's own copy
  # and falling back to the main repo (mirrors cleanwt). The worktree may not
  # have the file if it isn't committed on that branch.
  local tmux_script=""
  if [[ -f "$worktree_path/.tmux-window.sh" ]]; then
    tmux_script="$worktree_path/.tmux-window.sh"
  elif [[ -f "$repo_root/.tmux-window.sh" ]]; then
    tmux_script="$repo_root/.tmux-window.sh"
  fi

  if [[ -n "$tmux_script" ]]; then
    # Background so tmuxwt returns immediately; slow filesystem prep inside
    # the script (rsync etc.) doesn't block the calling shell.
    if grep -qE '^(function )?oncreate[[:space:]]*\(' "$tmux_script"; then
      bash "$tmux_script" oncreate "$worktree_path" "$window_id" &
    else
      bash "$tmux_script" "$worktree_path" "$window_id" &
    fi
    disown 2>/dev/null
  fi
}

# Fetch a remote branch and point a local branch of the same name at it, so
# `tmuxwt <branch>` can check it out for review. Only moves refs; the current
# checkout and working tree are not touched.
function fetch_for_review() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: fetch_for_review <remote-branch-name>"
    return 1
  fi
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not a git repository"
    return 1
  }

  git fetch origin "$branch" || return 1

  # git refuses to move a branch that is checked out in some worktree.
  local existing
  existing=$(git worktree list --porcelain | awk -v ref="branch refs/heads/$branch" \
    '/^worktree / { wt = substr($0, 10) } $0 == ref { print wt }')
  if [[ -n "$existing" ]]; then
    echo "$branch is checked out at $existing; run 'git pull' there instead"
    return 1
  fi

  git branch -f --track "$branch" "origin/$branch" || return 1
  echo "Ready: tmuxwt $branch"
}

# this is for claude code
function cd() {
  if declare -f __zoxide_z &>/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

codex() {
  local codex_tmux="${TMUX-}" codex_pane="${TMUX_PANE-}"
  codex_tmux="${codex_tmux//\\/\\\\}"
  codex_tmux="${codex_tmux//\"/\\\"}"
  codex_pane="${codex_pane//\\/\\\\}"
  codex_pane="${codex_pane//\"/\\\"}"
  command codex \
    -c "shell_environment_policy.set.TMUX=\"$codex_tmux\"" \
    -c "shell_environment_policy.set.TMUX_PANE=\"$codex_pane\"" \
    "$@"
}
