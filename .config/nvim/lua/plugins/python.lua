local function find_venv(start)
  local found = vim.fs.find(".venv", { path = start, upward = true, type = "directory", limit = 1 })
  return found[1]
end

local function venv_settings(start)
  local venv = find_venv(start)
  if not venv then
    return nil
  end
  local python = venv .. "/bin/python"
  if vim.fn.executable(python) ~= 1 then
    return nil
  end
  return {
    python = {
      pythonPath = python,
      venvPath = vim.fs.dirname(venv),
      venv = vim.fs.basename(venv),
    },
  }
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          root_markers = {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "pyrightconfig.json",
            ".git",
          },
          on_init = function(client)
            local bufname = vim.api.nvim_buf_get_name(0)
            local start = bufname ~= "" and bufname or client.config.root_dir
            local extra = venv_settings(start)
            if not extra then
              return
            end
            client.settings = vim.tbl_deep_extend("force", client.settings or {}, extra)
            client:notify("workspace/didChangeConfiguration", { settings = nil })
          end,
        },
      },
    },
  },
}
