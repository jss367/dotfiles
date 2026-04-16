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

config.window_close_confirmation = 'NeverPrompt'

config.enable_kitty_keyboard = true

-- iTerm2-style split bindings. Keep WezTerm's default pane navigation.
-- On Linux the Super/Windows key is grabbed by the DE, so use CTRL|SHIFT instead.
local is_mac = wezterm.target_triple:find('darwin') ~= nil
local mod = is_mac and 'CMD' or 'CTRL|SHIFT'
local mod_shift = is_mac and 'CMD|SHIFT' or 'CTRL|SHIFT|ALT'

config.keys = {
  { key = 'd', mods = mod,       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = mod_shift, action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = mod,       action = act.CloseCurrentPane { confirm = false } },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString('\n') },
}

-- Color SSH tabs distinctly (pairs with ssh() wrapper in dotfiles/shell/rc.d/ssh-colors.zsh)
wezterm.on('format-tab-title', function(tab)
    local title = tab.active_pane.title
    local is_ssh = title:match('^ssh:')
    return {
        { Background = { Color = is_ssh and '#5c1a1a' or '#2a2a30' } },
        { Foreground = { Color = '#ffffff' } },
        { Text = ' ' .. title .. ' ' },
    }
end)

return config
