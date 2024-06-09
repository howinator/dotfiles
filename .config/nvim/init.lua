-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd([[
  autocmd bufwritepost ~/.config/kitty/kitty.conf :silent !kill -SIGUSR1 $(pgrep kitty)
]])
