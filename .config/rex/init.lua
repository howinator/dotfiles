-- Rex configuration (stowed to ~/.config/rex/init.lua).
--
-- Mirrors the old tmux + Ghostty setup:
--   * Prefix is Ctrl+Space, with tmux-style keys after it.
--   * Ctrl+h/j/k/l moves between panes, but goes to (n)vim when it has focus
--     (vim-tmux-navigator).
--   * Alt+Shift+h/l moves to the previous/next tab.
--
-- After you edit this file:   rex config reload
-- To check it without loading: rex config check
--
-- Appearance (font, theme, padding, Option as Alt, ...) is an app setting, not
-- a config-file setting. Run "Apply Dotfiles Settings" from the command palette
-- (shift+cmd+p) once on each Mac to apply the Ghostty-like look.

local HOME = os.getenv("HOME")
local P = "ctrl+space>" -- tmux prefix

local function bind_prefix(key, action, args)
  rex.bind(P .. key, action, args)
end

---------------------------------------------------------------------------
-- Appearance (from the old Ghostty config)
---------------------------------------------------------------------------

local THEME_NAME = "Catppuccin Mocha"
local THEME_FILE = HOME .. "/.config/rex/themes/Catppuccin Mocha"

rex.action{
  name = "apply_dotfiles_settings",
  title = "Apply Dotfiles Settings",
  description = "Apply the font, theme, padding, and keyboard settings from ~/dotfiles to this app.",
  category = "Dotfiles",
  keywords = "ghostty theme font catppuccin settings appearance",
  run = function(ctx, args)
    local q = rex.client.queue
    -- Font: JetBrainsMono Nerd Font Mono, size 10
    q("client.setting.terminal.typography.font", { value = "JetBrainsMono Nerd Font Mono" })
    q("client.setting.terminal.typography.size", { value = 10 })
    -- Window padding 10 x 10
    q("client.setting.interface.pane_padding.horizontal", { value = 10 })
    q("client.setting.interface.pane_padding.vertical", { value = 10 })
    -- Block cursor
    q("client.setting.terminal.cursor.style", { value = "block" })
    -- macos-option-as-alt = true
    q("client.setting.terminal.keyboard.option", { value = "sends_alt" })
    -- Copy on mouse select (tmux mouse + tmux-yank behavior)
    q("client.setting.terminal.selection.copy_on_select", { value = true })
    -- Translucent, blurred background (background-opacity / blur-radius)
    q("client.setting.interface.appearance.style", { value = "glass" })
    q("client.setting.interface.appearance.glass", { value = true })
    -- Show which keys can follow the prefix
    q("client.setting.terminal.keyboard.sequence_hints", { value = true })
    -- Theme: Catppuccin Mocha, always dark
    q("client.setting.interface.appearance.scheme", { value = "dark" })
    q("client.theme.import", { path = THEME_FILE })
    q("client.theme.change", { name = THEME_NAME })
  end,
}

---------------------------------------------------------------------------
-- Prefix: Ctrl+Space
---------------------------------------------------------------------------

-- Press the prefix twice to send Ctrl+Space to the program (send-prefix).
bind_prefix("ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Tabs (tmux windows). Tabs are numbered from 1, like base-index 1.
bind_prefix("c", "client.tab.new")
bind_prefix("n", "client.tab.next")
bind_prefix("p", "client.tab.previous")
bind_prefix("ctrl+n", "client.tab.next")     -- tmux-sensible
bind_prefix("ctrl+p", "client.tab.previous") -- tmux-sensible
bind_prefix("l", "client.tab.recent.in_session") -- last-window
bind_prefix(",", "client.tab.rename")
bind_prefix("shift+7", "client.tab.close") -- &
for i = 1, 9 do
  bind_prefix(tostring(i), "client.tab.goto", { index = i })
end

-- Sessions
bind_prefix("s", "session.switch")
bind_prefix("w", "session.switch")
bind_prefix("shift+4", "session.rename")   -- $
bind_prefix("shift+9", "session.previous") -- (
bind_prefix("shift+0", "session.next")     -- )
bind_prefix("shift+l", "session.recent")   -- L: last session

-- Fuzzy-find a tab/pane across all sessions (was prefix+f with fzf-windows.sh)
bind_prefix("f", "pane.go_to")

-- Panes. New panes open in the current directory.
bind_prefix("shift+'", "pane.split", { direction = "down" })  -- "
bind_prefix("shift+5", "pane.split", { direction = "right" }) -- %
bind_prefix("x", "pane.close")
bind_prefix("z", "pane.zoom")
bind_prefix("o", "pane.focus_next")
bind_prefix(";", "pane.focus_recent.in_tab")
bind_prefix("shift+1", "pane.move_to_new_tab") -- ! (break-pane)
bind_prefix("space", "pane.balance")
bind_prefix("left", "pane.focus", { direction = "left" })
bind_prefix("right", "pane.focus", { direction = "right" })
bind_prefix("up", "pane.focus", { direction = "up" })
bind_prefix("down", "pane.focus", { direction = "down" })

-- Copy mode (vi keys are the default: v, shift+v, ctrl+v, y, /, n)
bind_prefix("[", "pane.copy_mode.enter")
bind_prefix("]", "pane.paste")

-- Misc
bind_prefix("shift+r", "client.config.reload") -- tmux-sensible
bind_prefix("shift+/", "client.palette.toggle") -- ?
bind_prefix("shift+;", "client.palette.toggle") -- :

---------------------------------------------------------------------------
-- Resize: prefix + Ctrl+arrow resizes and then stays in resize mode, so
-- more arrows (or h/j/k/l) keep resizing, like tmux "bind -r".
-- Escape or Enter leaves the mode.
---------------------------------------------------------------------------

rex.action{
  name = "resize_and_repeat",
  title = "Resize Pane (Repeatable)",
  category = "Dotfiles",
  args = { direction = "string", amount = "integer?" },
  run = function(ctx, args)
    rex.client.queue("pane.resize", { direction = args.direction, amount = args.amount })
    rex.client.queue("client.mode.enter", { name = "resize" })
  end,
}

rex.mode("resize", { exclusive = true })

local RESIZE_KEYS = {
  left = { "left", "h" },
  down = { "down", "j" },
  up = { "up", "k" },
  right = { "right", "l" },
}
for direction, keys in pairs(RESIZE_KEYS) do
  bind_prefix("ctrl+" .. keys[1], "resize_and_repeat", { direction = direction })
  bind_prefix("alt+" .. keys[1], "resize_and_repeat", { direction = direction, amount = 5 })
  for _, key in ipairs(keys) do
    rex.bind("resize/" .. key, "pane.resize", { direction = direction })
    rex.bind("resize/ctrl+" .. key, "pane.resize", { direction = direction })
    rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 5 })
  end
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

---------------------------------------------------------------------------
-- Tabs without the prefix: Alt+Shift+h / Alt+Shift+l (tmux M-H / M-L)
---------------------------------------------------------------------------

rex.bind("alt+shift+h", "client.tab.previous")
rex.bind("alt+shift+l", "client.tab.next")

---------------------------------------------------------------------------
-- vim-tmux-navigator: Ctrl+h/j/k/l
--
-- If (n)vim or fzf has focus, send the key to it. Neovim moves between its own
-- splits and, at the edge, runs `rex focus <dir>` (see
-- .config/nvim/lua/plugins/vim-tmux-navigator.lua). Otherwise move to the
-- Rex pane in that direction.
---------------------------------------------------------------------------

local TERMINAL = "com.superlogical.terminal"

-- Same programs that vim-tmux-navigator treats as vim.
local VIM_PROGRAMS = {
  vi = true, vim = true, nvim = true, vimx = true, lvim = true,
  view = true, gvim = true, gview = true,
  vimdiff = true, nvimdiff = true, fzf = true,
}

local function basename(path)
  return path and path:match("([^/]+)$") or nil
end

local function vim_has_focus(block_id)
  local ok, proc = pcall(rex.block.call, TERMINAL, "process", { block_id = block_id })
  if not ok or type(proc) ~= "table" or type(proc.foreground) ~= "table" then
    return false
  end
  local fg = proc.foreground
  for _, name in ipairs({ fg.name, basename(fg.argv0), basename(fg.invoked_path) }) do
    if name and VIM_PROGRAMS[name:gsub("^-", "")] then
      return true
    end
  end
  return false
end

local NAV_KEYS = { left = "ctrl+h", down = "ctrl+j", up = "ctrl+k", right = "ctrl+l" }

rex.action{
  name = "navigate",
  title = "Focus Pane or Send to Vim",
  description = "Send the key to (n)vim when it has focus; else focus the pane in that direction.",
  category = "Dotfiles",
  args = { direction = "string" },
  run = function(ctx, args)
    if vim_has_focus(ctx.block_id) then
      rex.client.queue("pane.send_key", { key = NAV_KEYS[args.direction] })
    else
      rex.client.queue("pane.focus", { direction = args.direction })
    end
  end,
}

for direction, key in pairs(NAV_KEYS) do
  rex.bind(key, "navigate", { direction = direction })
end
