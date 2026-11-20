-- Ctrl+h/j/k/l moves between nvim splits, then into the next tmux or Rex pane.
-- In tmux, vim-tmux-navigator does it. In Rex (REX_SESSION set, not inside
-- tmux), move between splits and run `rex focus <dir>` at the edge.

local function in_rex()
  return vim.env.REX_SESSION ~= nil and vim.env.TMUX == nil
end

local REX_DIRECTIONS = { h = "left", j = "down", k = "up", l = "right" }

local function navigate(wincmd, tmux_cmd)
  return function()
    if not in_rex() then
      vim.cmd(tmux_cmd)
      return
    end
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. wincmd)
    if vim.api.nvim_get_current_win() == win and REX_DIRECTIONS[wincmd] then
      vim.system({ "rex", "focus", REX_DIRECTIONS[wincmd], "-s", vim.env.REX_SESSION })
    end
  end
end

return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", navigate("h", "TmuxNavigateLeft") },
    { "<c-j>", navigate("j", "TmuxNavigateDown") },
    { "<c-k>", navigate("k", "TmuxNavigateUp") },
    { "<c-l>", navigate("l", "TmuxNavigateRight") },
    { "<c-\\>", navigate("p", "TmuxNavigatePrevious") },
  },
}
