git_delete_remote_tag() {
  git tag -d "$1"
  git push origin ":refs/tags/$1"
}

git_rename_branch() {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$current_ branch" == 'master' ||  "$current_branch" == 'develop' || "$current_branch" == 'heapjs-develop' ]]; then
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

brew-install () {
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

funcion readme() {
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
  commit=${1:-head}
  git diff "$commit" -- ':!package-lock.json' ':!yarn.lock'
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
  trackpad_id=`blueutil --paired | grep "Howie.*Trackpad" | grep -Eo '[a-z0-9]{2}(-[a-z0-9]{2}){5}'`
  trackpad_name=`blueutil --paired | grep "Howie.*Trackpad" | grep -Eo 'name: ".*"'`

  keyboard_id=`blueutil --paired | grep "Howie.*Keyboard" | grep -Eo '[a-z0-9]{2}(-[a-z0-9]{2}){5}'`
  keyboard_name=`blueutil --paired | grep "Howie.*Keyboard" | grep -Eo 'name: ".*"'`

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
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not a git repository"; return 1; }
  local repo_name=$(basename "$repo_root")
  local worktree_path="$HOME/.worktrees/${repo_name}-${branch}"
  if [[ -d "$worktree_path" ]]; then
    cd "$worktree_path"
  elif git show-ref --verify --quiet "refs/heads/${branch}"; then
    git worktree add "$worktree_path" "$branch" && cd "$worktree_path"
  else
    git worktree add -b "$branch" "$worktree_path" && cd "$worktree_path"
  fi
}

function gwt-clean() {
  local worktree_path
  worktree_path=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not a git repository"; return 1; }
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || { echo "Could not determine branch"; return 1; }
  if [[ "$worktree_path" != "$HOME/.worktrees/"* ]]; then
    echo "Not in a worktree managed by gwt"
    return 1
  fi
  local main_worktree
  main_worktree=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
  cd "$main_worktree"
  git worktree remove "$worktree_path"
  git branch -d "$branch"
}

function yolopr() {
  gh pr create --fill && gh pr merge --auto --squash && gh pr view --web
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

  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not a git repository"; return 1; }
  local repo_name=$(basename "$repo_root")
  local worktree_path="$HOME/.worktrees/${repo_name}-${branch}"

  # Create worktree if needed (same logic as gwt)
  if [[ ! -d "$worktree_path" ]]; then
    if git show-ref --verify --quiet "refs/heads/${branch}"; then
      git worktree add "$worktree_path" "$branch" || return 1
    else
      git worktree add -b "$branch" "$worktree_path" || return 1
    fi
  fi

  # Window name: first 16 chars of branch
  local window_name="${branch:0:16}"

  # Create tmux window at worktree path
  tmux new-window -c "$worktree_path" -n "$window_name"

  # Mark window so the after-new-window hook doesn't double-run
  tmux set-option -w @tmux-window-scripted 1

  # Run repo-specific tmux script if it exists
  local tmux_script=""
  if [[ -f "$worktree_path/.tmux-window.sh" ]]; then
    tmux_script="$worktree_path/.tmux-window.sh"
  elif [[ -f "$repo_root/.tmux-window.sh" ]]; then
    tmux_script="$repo_root/.tmux-window.sh"
  fi

  if [[ -n "$tmux_script" ]]; then
    tmux run-shell -b "bash '$tmux_script' '$worktree_path'"
  fi
}

# this is for claude code
function cd() {
  if declare -f __zoxide_z &>/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}
