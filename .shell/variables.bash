export XDG_CONFIG_HOME="$HOME/.config"
export AWS_DEFAULT_PROFILE=engineer
export EDITOR=nvim
export BAT_THEME=CatppuccinMocha
export CHEAT_USE_FZF=true
export PKG_CONFIG_PATH="/usr/local/opt/glib/lib/pkgconfig:$PKG_CONFIG_PATH"

# pyenv install
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

### PATH STUFF ###
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/Users/howiebenefiel/.local/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$PATH:/Users/howiebenefiel/Library/Application Support/JetBrains/Toolbox/scripts"
export PATH="$PATH:/Users/howiebenefiel/.local/bin" # for pipx
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin
source ~/.shell/secrets.bash
