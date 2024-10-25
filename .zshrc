#source <(/opt/homebrew/bin/fzf --zsh)
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

## Custom-ish plugins

### eza completions
zinit ice as"completion" depth=1 pick"completions/zsh/_eza"; zinit light eza-community/eza
### Load direnv (faster) https://zdharma-continuum.github.io/zinit/wiki/Direnv-explanation/
zinit from"gh-r" as"program" mv"direnv* -> direnv" \
    atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
    pick"direnv" src="zhook.zsh" for \
        direnv/direnv
### This is specifically for poetry. shell completions were put here. Must come before compinit
fpath+=~/.zfunc
### Install fzf git
zinit ice depth=1 pick"fzf-git.sh"; zinit light junegunn/fzf-git.sh
### Get docker completions
zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker
### Cheat fzf integration
#### :TODO: this is not currently working?
zinit ice as"completion" depth=1 pick"scripts/cheat.zsh"
zinit light cheat/cheat


# Load completions
autoload -U compinit && compinit
## Make zinit go fast?
zinit cdreplay -q

# Enable emacs key bindings
bindkey -e
## Namespaces search to command typed out. Without "curl" ^p might return an echo command.
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
## Show completions for command
#zle -N _complete_debug_generic _complete_help_generic
#bindkey '^xc' _complete_debug_generic

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

# zstyle stuff
## Allows case-insensitive matching in auto-completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no # disable default menu when using fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons -1 $realpath' # use fzf with eza for cd autocomplete
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons -1 $realpath'
## Allow docker "option stacking" e.g. docker run -it will work
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
#zstyle ':completion:*:*:cheat:*'  # try to make cheat completion work


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load all aliases, evals, functions, etc.
source $HOME/.shell/variables
## evals must be after compinit for zoxide to work
source $HOME/.shell/evals
source $HOME/.shell/aliases
source $HOME/.shell/functions

# Configure fzf
## Make fzf use fd
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --exclude .git . $HOME"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$HOME"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git "$HOME"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

## Setup fzf theme
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
