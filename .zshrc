# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Install Zinit

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Use prompt
#zinit ice as"command" from"gh-r" \
#          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
#         atpull"%atclone" src"init.zsh"
#zinit light starship/starship
zinit ice depth"1"; zinit light romkatv/powerlevel10k

# Use plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

## OMZ Plugins
zinit snippet OMZP::git
#zinit snippet OMZP::poetry

## Custom-ish plugins
zinit ice as"completion" depth=1 pick"completions/zsh/_eza"; zinit light eza-community/eza
## Load direnv (faster) https://zdharma-continuum.github.io/zinit/wiki/Direnv-explanation/
zinit from"gh-r" as"program" mv"direnv* -> direnv" \
    atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
    pick"direnv" src="zhook.zsh" for \
        direnv/direnv

# Load completions
autoload -U compinit && compinit
## Make zinit go fast?
zinit cdreplay -q

# Enable emacs key bindings
bindkey -e
## Namespaces search to command typed out. Without "curl" ^p might return an echo command.
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Shell history
## Most of this is just getting rid of dupes
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUPE=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

## Allows case-insensitive matching in auto-completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no # disable default menu when using fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons -1 $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons -1 $realpath'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load all aliases, evals, functions, etc.
source ./.shell/variables
## evals must be after compinit for zoxide to work
source ./.shell/evals
source ./.shell/aliases
source ./.shell/functions
