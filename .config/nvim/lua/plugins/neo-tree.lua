return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          ".git",
          "node_modules",

          ".DS_Store",
          -- 'thumbs.db',
        },
        never_show = {
          ".git",
          "node_modules",
          ".DS_Store",
        },
      },
    },
  },
}
