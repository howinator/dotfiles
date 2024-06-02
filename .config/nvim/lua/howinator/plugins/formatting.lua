return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "EslintFixAll" },
        typescript = { "EslintFixAll" },
        javascriptreact = { "EslintFixAll" },
        typescriptreact = { "EslintFixAll" },
        svelte = { "EslintFixAll" },
        css = { "EslintFixAll" },
        html = { "EslintFixAll" },
        json = { "EslintFixAll" },
        yaml = { "EslintFixAll" },
        markdown = { "EslintFixAll" },
        graphql = { "EslintFixAll" },
        liquid = { "EslintFixAll" },
        lua = { "stylua" },
        python = { "isort", "black", "ruff" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
