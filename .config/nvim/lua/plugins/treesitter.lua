return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "HiPhish/rainbow-delimiters.nvim" },
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "rust",
      },
      rainbow = {
        enable = true,
      },
    },
  },
}
