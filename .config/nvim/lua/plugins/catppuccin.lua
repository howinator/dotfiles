return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      term_colors = true,
      transparent_background = false,
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.subtext0 },
          CursorLineNr = { fg = colors.green },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
