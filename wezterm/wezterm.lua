local wezterm = require('wezterm')
local act = wezterm.action

local config = wezterm.config_builder()

-- Appearance: match the iTerm2 dotfiles profile
config.font = wezterm.font('MesloLGS NF')
config.font_size = 13.0
config.colors = {
  background = '#1f1f24',
  foreground = '#d9d9d9',
}
config.window_decorations = 'RESIZE'
config.window_background_opacity = 1.0
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }

-- Scrollback comparable to iTerm2 defaults
config.scrollback_lines = 10000

-- iTerm2-style split bindings. Keep WezTerm's default pane navigation.
config.keys = {
  -- Cmd-D: vertical split (new pane to the right), like iTerm2
  { key = 'd', mods = 'CMD',       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Cmd-Shift-D: horizontal split (new pane below), like iTerm2
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  -- Cmd-W: close the active pane (iTerm2 closes pane, falling through to tab/window)
  { key = 'w', mods = 'CMD',       action = act.CloseCurrentPane { confirm = true } },
}

return config
