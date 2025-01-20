# Setup
1. Clone the repo
2. Create a `~/.shell/secrets.bash` file
3. Create a GPG key and get the signing key
4. Create a `~/.gitconfig.local` file
  a. Add the following to .gitconfig.local
```
[user]
	signingkey = [KEY_ID]
```
5. Run `brew bundle install --file=Brewfile`
6. Run `stow .`

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
- I am currently using Catpuccin Mocha

# Resources
- Lots of youtube videos and this [repo](https://github.com/johnalanwoods/maintained-modern-unix)


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
- Consider switching to cappucin tmux theme. I decided not to add it since I kind of like the dracula theme for tmux
- Make nvim not use the clipboard register all the time

# Resources

- [0 to LSP from The Primeagen](https://www.youtube.com/watch?v=w7i4amO_zaE)

