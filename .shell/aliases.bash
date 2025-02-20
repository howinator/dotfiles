alias dc='docker-compose'
alias cat='bat'

# Git aliases
alias g=git
alias ga='git add'
alias gaa='git add -A'
alias gam='git commit --amend --no-edit'
alias gc='git commit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gch='git checkout'
alias gl='git pull'
alias grb='git rebase -S'
alias gchm='git checkout-pull origin main'
alias k=kubectl
alias cddet='cd ~/projects/detail'
alias nv="nvim"

# eza commands
# alias ld='eza -lhD --icons --no-filesize --no-user --no-permissions --git' # list only directories
alias ld='eza -D -T --level=2 --ignore-glob="node_modules"' # list only directories. todo: make this so it shows level=1 for node_modules, but 2 for everything else
alias lf="eza -lhF --icons --no-user --no-permissions --git --color=always | awk '!/\x1b\[0?1;36m/'" # list only files
alias lh='eza -dhl --icons --no-user --no-permissions --git .* --group-directories-first' # list only hidden files
alias ll='eza -ahl --icons --no-user --no-permissions --git --group-directories-first' # list everything with directories first
alias lb="eza -alhF --icons --no-user --no-permissions --git --color=always --sort=size -r | awk '!/\x1b\[0?1;36m/'" # list files sorted by size
alias la="eza -a --icons --color=always"
alias lt='eza -alh --ignore-glob="node_modules" --icons --no-user --no-permissions --git --sort=modified' # list everything sorted by last modified
alias ls="eza '--icons' '--color=always'" # :TRICKY: tab autocomplete breaks without single quoting options. idk why 
alias lst="eza -aT --ignore-glob='node_modules' --color=always --icons --level=2"

alias realpath=grealpath

alias rgi='rg --hidden --no-ignore'
