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
- I am currently using Dracula
  - TODO: I think the comments are a little light


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
