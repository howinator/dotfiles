# keymaps
jk <ESC> will exit insert mode

# directory tree (neo-tree)
- ^w+h will switch to tree
- <SPACE>ee to open file tree
- <SPACE>fs to grep in cwd
- <SPACE>ff to find files in cwd

## inside neo-tree
- a   add file (end name with `/` to make a directory)
- A   add directory directly
- d   delete
- r   rename
- m   move
- c / x / p   copy / cut / paste
- y   copy filename
- Y   copy relative path

# LSP code navigation
- gR           show references
- gD           go to declaration
- gd           show definition
- gi           show implementation
- gt           show type definition
- <SPACE>rn    smart rename
- <SPACE>ss    document symbols (current file)
- <SPACE>sS    workspace symbols (project-wide, via LSP)

# yanking paths
- <SPACE>yp    yank relative path of current file (custom, in lua/config/keymaps.lua)

# git / github
- <SPACE>gY    yank GitHub URL for current line/file (visual mode = line range)
- <SPACE>gB    open GitHub URL for current line/file in browser
- <SPACE>h     gitsigns menu (hunks, blame, etc.)

# Load config of current file
:source %

# See option explanation
:h <option>

# Formatting
- <SPACE>mp format file

# Treesitter
- :Inspect       show highlight groups under cursor
- :InspectTree   show parsed syntax tree
- :EditQuery     open Live Query Editor

# window management
- <SPACE>sv  split vertically
- <SPACE>sh  split horizontally
- <SPACE>se  split windows equal size
- <SPACE>sx  close current split

- <SPACE>to  open new tab
- <SPACE>tx  close tab
- <SPACE>tn  go to next tab
- <SPACE>tp  go to previous tab
- <SPACE>tf  open current buffer in new tab
