vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- Tabs & Indentation
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- convert tabs to spaves
opt.autoindent = true -- copy indent from current line when starting a new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in search, assume case sensitive

opt.cursorline = true -- highlights current cursor line

-- turn on termguicolorcs
opt.termguicolors = true
opt.background = "dark" -- colorschemes will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windoes
opt.splitright = true -- split vertical to the right
opt.splitbelow = true -- split horizontal windows to the bottom

-- turn off swapfile
opt.swapfile = false
