eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"
eval "$(/opt/homebrew/bin/brew shellenv)"


# pyenv install
eval "$(pyenv init -)"

# install thefuck
eval $(thefuck --alias fk)

if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

. "$HOME/.cargo/env"
