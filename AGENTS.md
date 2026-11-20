# Dotfiles

Personal dotfiles managed with GNU Stow. Run `stow .` from the repo root to link each tracked file into `$HOME` (`.stowrc` sets `--no-folding`).

## Repo layout

- `.shell/` — Shell config split into `aliases.bash`, `functions.bash`, `variables.bash`, `evals.bash`, sourced by `.zshrc`
- `.config/tmux/` — Tmux config, hooks, and scripts
- `.config/nvim/` — Neovim (LazyVim-based) with custom plugins
- `.config/kitty/` — Kitty terminal config (Catppuccin Mocha theme)
- `.config/rex/` — Rex config (`init.lua`): tmux-style keys on a `Ctrl+Space` prefix, vim-aware `Ctrl+h/j/k/l`, and an "Apply Dotfiles Settings" palette action for the Ghostty-like look. Run `rex config reload` after edits.
- `.claude/` — Claude Code base layers (`settings.base.json`, `mcp.base.json`) and notification hooks. `~/.claude/settings.json` and the MCP list in `~/.claude.json` are built, not stowed (see below).
- `scripts/` — Standalone scripts, on PATH as `~/dotfiles/scripts` (`cleanwt`, `clean-worktrees`, `claude-config-build`, `claude-statusline.sh`, `stow-unfold`)
- `Brewfile` — Homebrew packages, casks, and fonts

Secrets live in `~/.shell/secrets.bash` (gitignored, never committed).

## Public repo + work layer

This repo is **public** and is shared by a personal laptop and a work laptop. Work-only and confidential config lives in the private repo `~/dotfiles-work`, stowed only on the work laptop:

```sh
cd ~/dotfiles && stow .
cd ~/dotfiles-work && stow .   # work laptop only
claude-config-build            # after a .claude layer changes
```

- **No folding.** Both repos have a `.stowrc` with `--no-folding`, so stow links files, never whole folders. `~/.config`, `~/.local`, `~/.shell` etc. are real folders; tool data and secrets written there stay out of the repo. Do not remove `.stowrc`.
- **Compatibility links.** Some installs (gcloud, uv Python, mason, nvm, zinit) have the old path `~/dotfiles/.local/...` or `~/dotfiles/.config/...` built in. The repo keeps links at `.local/share`, `.local/state`, `.local/bin/google-cloud-sdk`, `.config/gcloud` and `.config/nvm` that point back to the real folders in `$HOME`. They are gitignored and stow-ignored. Delete one only after the tools under it are reinstalled.
- **Shell:** `.zshrc` sources `~/.shell-work.bash` last, when it exists.
- **Claude Code:** `claude-config-build` merges `~/.claude/<name>.{base,work,machine}.json` (base from this repo, work from dotfiles-work, machine from no repo) for two targets: `settings.*` -> `~/.claude/settings.json`, and `mcp.*` (`{"mcpServers": {...}}`) -> the `mcpServers` key of `~/.claude.json` (the rest of that file is Claude Code state; leave it). Objects merge recursively; arrays in a later layer replace earlier ones. Claude Code also writes these targets (`/config`, `/plugin`, `claude mcp add -s user`); the script refuses to overwrite such changes and shows a diff. Move the change into a layer, then run `claude-config-build --force`. `--check` shows drift.
- **Codex:** `~/.codex/config.toml` lives in dotfiles-work (Codex rewrites it; if the link becomes a file, run `stow --adopt .` there). `.codex/hooks.json` stays here.
- **opencode:** `cli.json` is here; `opencode.jsonc` (Datadog MCPs) is in dotfiles-work. `~/.config/opencode/AGENTS.md` is a local link to `~/.agents/AGENTS.md`.

Before committing here, never commit tokens, keys, internal hostnames, bucket names, or employer repo details. Put them in dotfiles-work, a `*.machine.json` layer, or a gitignored file.

## Git worktree system

The core workflow automation lives in `.shell/functions.bash`. Worktrees are stored at `~/.worktrees/{repo-name}-{branch}`.

### Commands

| Command | Purpose |
|---------|---------|
| `gwt <branch>` | Create/enter a git worktree. Symlinks `.claude/settings.local.json` from the main repo. |
| `tmuxwt <branch>` | `gwt` + creates a tmux window at the worktree. Runs `.tmux-window.sh` if present. |
| `cleanwt [path]` | Destroy a worktree: runs `ondestroy` hook, merges Claude permissions back, removes worktree + branch. Lives in `scripts/cleanwt`; the shell function wraps it and cd's to the main repo. |
| `clean-worktrees` | Remove stale entries under `~/.worktrees` (default older than 90 days) via `cleanwt`. `-n` dry run, `-d N` days, `-f` force, `-j N` jobs. |
| `gwt-clean` | Legacy cleanup (no lifecycle hooks). Same permission merge + worktree/branch removal. |
| `fetch_for_review <branch>` | Fetch `origin/<branch>` and force a local `<branch>` (tracking origin) to it, ready for `tmuxwt <branch>`. Does not touch the current checkout. |
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

## Cheatsheets

When the user asks how to do something in neovim, update `nvim-cheatsheet.md` at the repo root with the answer (keymap, command, or workflow). `cheat/cheatsheets/personal/nvim` is a symlink to that file, so `cheat nvim` will pick up the change automatically.
