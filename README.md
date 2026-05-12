# Setup
1. Clone the repo
2. Create a `~/.shell/secrets.bash` file
3. Create a GPG key and get the signing key
4. Create a `~/.gitconfig.local` file
  a. Add the following to .gitconfig.local
```
[user]
	signingkey = [KEY_ID]
```
5. Run `brew bundle install --file=Brewfile`
6. Run `stow .`

# Basic nav
- ^R will open recent commands in fzf
- cd ^p will cycle through 
- ^P or ^N will cycle through previous commands of the same type

# fzf
- cd <TAB> will open fzf
- kill -9 <TAB> will fzf
- unalias <TAB>
- `frg` will use rg to fuzzy find files that have string then open editor to that position

# Git
- ^GH = fzf git commits
- ^GB to checkout a branch

# bat
- To show themes for bat, run `show-bat-themes $file" with $file optional
- To install bat themes, first do `mkdir -p $(bat --config-dir)/themes`
  - Then `cd` into that dir and install
  - Then do `bat cache --build`
  - Finally, edit `export BAT_THEME=<whatever>` in variables

# Theme
- I am currently using Catpuccin Mocha

# Resources
- Lots of youtube videos and this [repo](https://github.com/johnalanwoods/maintained-modern-unix)


# tmuxwt + .tmux-window.sh

`tmuxwt <branch>` creates a git worktree at `~/.worktrees/<repo>-<branch>` and opens a new tmux window in it. If the repo has a `.tmux-window.sh` at its root, tmuxwt invokes it to lay out the new window.

The script is invoked from the *parent* shell (the one that ran `tmuxwt`) immediately after `tmux new-window` returns the new window's ID — there is no tmux hook involved. This means the script is never racing against user keypresses for "which window is active."

## Contract

The script is called as:

    bash .tmux-window.sh oncreate <work_dir> <window_id>

if it defines an `oncreate()` function, or otherwise:

    bash .tmux-window.sh <work_dir> <window_id>

Arguments:
- `<work_dir>` — the worktree's absolute path. Use this for `-c` flags and any `cd`/path operations.
- `<window_id>` — the tmux window ID (e.g. `@7`). **All `tmux` commands in the script must target this window explicitly** via `-t "$W"` (for the window) or `-t "$W.N"` (for pane N). Do *not* use `:.N`, `tmux display-message`, or any other "current window" lookup — the user may have switched tmux focus before your script runs, and you'd split the wrong window.

The script may also define `ondestroy()`, which `cleanwt` invokes when tearing down the worktree.

tmuxwt searches first for `<worktree>/.tmux-window.sh`, then falls back to `<main-repo>/.tmux-window.sh` (since a fresh branch may not have the file committed). The script is run in the background so `tmuxwt` returns immediately.

## Example

```bash
oncreate() {
  local WORK_DIR="$1"
  local W="$2"

  # Layout: bottom row (30%), then split bottom horizontally
  tmux split-window -t "$W.1" -v -c "$WORK_DIR" -p 30
  tmux split-window -t "$W.2" -h -c "$WORK_DIR"

  tmux send-keys -t "$W.1" "claude" Enter
  tmux send-keys -t "$W.2" "pnpm install" Enter
}

ondestroy() {
  local WORK_DIR="$1"
  # Stop long-running services, etc.
}

"$@"
```

# TODOs
- Find better theme for bat and the terminal. 
  I'd love tokyo hack but I can't find it in .tmTheme
- tab completions for docker
- Make cheat completion work
- ~Make fzf search starting from home by default~
  - This might be done. I changed to this behavior (maybe) in this commit
  - One thing I'd like to change maybe is have fd ignore respecting .gitignore, but use fd's .config/ignore file
    - Right now, it's respecting the .gitignore which means `bat **` is not showing some files I might care about
- Add a dracula/tmux plugin which shows current playing spotify artist
- Consider switching to cappucin tmux theme. I decided not to add it since I kind of like the dracula theme for tmux
- Make nvim not use the clipboard register all the time

# Resources

- [0 to LSP from The Primeagen](https://www.youtube.com/watch?v=w7i4amO_zaE)

