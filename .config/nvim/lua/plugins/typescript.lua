return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Turn off the node-based tsserver in favor of the TS7 native (Go) LSP.
        vtsls = { enabled = false },
        -- TypeScript 7 native (Go) LSP: ~half the RAM of node tsserver, and the
        -- old maxTsServerMemory V8 knob no longer applies. Still one server per
        -- worktree root (no cross-process sharing), just much lighter each.
        -- Preview quality -- flip vtsls back on if feature gaps bite.
        tsgo = {
          -- Use the global `tsgo` on PATH; don't let mason install/manage it
          -- (mason knows tsgo, which otherwise suppresses vim.lsp.enable).
          mason = false,
          cmd = { "tsgo", "--lsp", "-stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        },
      },
    },
  },
}
