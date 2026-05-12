# Completion plugins (loaded before compinit)
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

## eza completions
zinit ice as"completion" depth=1 pick"completions/zsh/_eza"; zinit light eza-community/eza

## Poetry/rust completions live here. Must come before compinit
fpath+=~/.zfunc

## Docker completions
zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

## Cheat fzf integration
#### :TODO: this is not currently working?
zinit ice as"completion" depth=1 pick"scripts/cheat.zsh"
zinit light cheat/cheat

# Initialize completion system
autoload -U compinit && compinit
## Make zinit go fast?
zinit cdreplay -q

# Completion styling
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

# gcloud shell command completion
if [ -f '/Users/howie/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/howie/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# graphite completion
if command -v gt &>/dev/null; then
  eval "$(gt completion)"
fi
