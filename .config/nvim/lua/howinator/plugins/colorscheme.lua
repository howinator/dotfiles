return {
  -- add dracula
  { 
    "Mofiqul/dracula.nvim",
    prirority = 100,
  },

  -- Configure LazyVim to load dracula
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
