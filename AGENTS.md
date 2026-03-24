# Dotfiles

Personal dotfiles managed with GNU Stow. Run `stow .` from the repo root to symlink everything into `$HOME`.

## Repo layout

- `.shell/` — Shell config split into `aliases.bash`, `functions.bash`, `variables.bash`, `evals.bash`, sourced by `.zshrc`
- `.config/tmux/` — Tmux config, hooks, and scripts
- `.config/nvim/` — Neovim (LazyVim-based) with custom plugins
- `.config/kitty/` — Kitty terminal config (Catppuccin Mocha theme)
- `.claude/` — Claude Code settings and notification hooks
- `Brewfile` — Homebrew packages, casks, and fonts

Secrets live in `~/.shell/secrets.bash` (gitignored, never committed).

## Git worktree system

The core workflow automation lives in `.shell/functions.bash`. Worktrees are stored at `~/.worktrees/{repo-name}-{branch}`.

### Commands

| Command | Purpose |
|---------|---------|
| `gwt <branch>` | Create/enter a git worktree. Symlinks `.claude/settings.local.json` from the main repo. |
| `tmuxwt <branch>` | `gwt` + creates a tmux window at the worktree. Runs `.tmux-window.sh` if present. |
| `cleanwt` | Destroy a worktree: runs `ondestroy` hook, merges Claude permissions back, removes worktree + branch. |
| `gwt-clean` | Legacy cleanup (no lifecycle hooks). Same permission merge + worktree/branch removal. |
| `wtfd <branch>` | Print the filesystem path of a worktree for a given branch. |
| `yolopr` | `gh pr create --fill && gh pr merge --auto --squash && gh pr view --web` |

### `.tmux-window.sh` lifecycle hooks

Repos can include a `.tmux-window.sh` at their root to hook into worktree creation and destruction. There are two formats:

**New format (recommended)** — define `oncreate` and `ondestroy` functions:

```bash
#!/usr/bin/env bash
oncreate() {
  local work_dir="$1"
  # Copy env files, set up panes, start dev servers, etc.
}

ondestroy() {
  local work_dir="$1"
  # Kill processes, clean up temp files, etc.
}

"$@"
```

`tmuxwt` calls `oncreate`, `cleanwt` calls `ondestroy`. The `"$@"` at the bottom dispatches to the right function.

**Old format** — a plain script that receives the worktree path as `$1`:

```bash
#!/usr/bin/env bash
WORK_DIR="${1:-$(tmux display-message -p '#{pane_current_path}')}"
# setup panes...
```

Both formats are auto-detected. If the script defines an `oncreate` function, it's treated as new format; otherwise old format. The tmux `after-new-window` hook (`.config/tmux/hooks/after-new-window.sh`) also runs `.tmux-window.sh` when a window is opened manually (not via `tmuxwt`), walking up the directory tree to find it.

### Claude permission merging

When a worktree's `.claude/settings.local.json` is a real file (not the original symlink), `cleanwt` and `gwt-clean` merge its `permissions.allow` entries back into the main repo's settings using `jq` before removing the worktree.

## Tmux

- Prefix: `C-Space`
- PR status dots appear in window tabs (via `.config/tmux/scripts/pr-status.sh`)
- Plugin manager: tpm. Plugins include vim-tmux-navigator, Dracula theme, resurrect, continuum.
- Sessions auto-restore on tmux start.

## Shell

- Zsh with zinit plugin manager, Powerlevel10k prompt
- `fd` + `fzf` + `bat` + `eza` + `ripgrep` + `zoxide` for file navigation
- Custom `cd` wraps zoxide, custom `gh` wrapper clears PR status cache on PR state changes
- `brew-install` auto-updates the Brewfile and commits

## Editing this repo

- Functions go in `.shell/functions.bash`, aliases in `.shell/aliases.bash`, env vars in `.shell/variables.bash`
- After adding a brew package, run `brew bundle dump --file=~/dotfiles/Brewfile -f` to update the Brewfile
- Tmux hooks go in `.config/tmux/hooks/`, scripts in `.config/tmux/scripts/`
- GPG signing is enabled for commits — the signing key is in `.gitconfig.local` (gitignored)
