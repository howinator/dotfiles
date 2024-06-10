local mocha = require("catppuccin.palettes").get_palette("mocha")
return {

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        custom_highlights = {
          LineNr = { fg = mocha.subtext0 },
          CursorLineNr = { fg = mocha.green },
        },
      })
    end,
    opts = {
      term_colors = true,
      transparent_background = false,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
