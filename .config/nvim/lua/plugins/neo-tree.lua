return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        -- Grep inside the node under the cursor (parent dir if it's a file).
        ["<leader>/"] = "grep_in_node",
      },
    },
    commands = {
      grep_in_node = function(state)
        local node = state.tree:get_node()
        local path = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
        require("fzf-lua").live_grep({ cwd = path })
      end,
    },
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
