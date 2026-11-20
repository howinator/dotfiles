export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export BAT_THEME="Catppuccin Mocha"
export CHEAT_USE_FZF=true
export PKG_CONFIG_PATH="/usr/local/opt/glib/lib/pkgconfig:$PKG_CONFIG_PATH"

export CLASK_MODEL="anthropic/claude-haiku-4.5"

# pyenv install
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

[[ -f ~/.shell/secrets.bash ]] && source ~/.shell/secrets.bash

### PATH STUFF ###
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin
export PATH="$HOME/dotfiles/scripts:$PATH"
export PATH="/Users/howie/Library/pnpm/bin:$PATH"
export PATH="/Users/howie/.sli/bin:$PATH"
# opencode
export PATH=/Users/howie/.opencode/bin:$PATH
export PATH="$PATH:$HOME/bin"
export PATH="/Users/howie/.duckdb/cli/latest:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/howie/.local/bin/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/howie/.local/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/howie/.local/bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/howie/.local/bin/google-cloud-sdk/completion.zsh.inc'; fi
export OPENROUTER_URL=https://us.openrouter.ai/api/v1
