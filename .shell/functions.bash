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


  echo "pairing keyboard with BT device $keyboard_id, $keyboard_name"
  blueutil --pair "$keyboard_id" "0000"
  echo "keyboard paired"
  blueutil --connect "$keyboard_id"
  echo "keyboard connected"
}
