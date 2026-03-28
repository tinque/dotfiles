local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ── Appearance ─────────────────────────────────────────
config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font',
  'Symbols Nerd Font',
  'Apple Color Emoji',
}
config.font_size = 14.0
config.line_height = 1.1
config.color_scheme = 'Tokyo Night'
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = false
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- ── Cursor ─────────────────────────────────────────────
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- ── Window background (blur + transparency macOS) ─────
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20

-- ── Tab bar (hidden — tmux handles it) ────────────────
config.use_fancy_tab_bar = false

-- ── Performance (macOS) ───────────────────────────────
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 120
config.animation_fps = 60

-- ── Scrollback ─────────────────────────────────────────
config.scrollback_lines = 100000
config.enable_scroll_bar = false

-- ── Hyperlinks ─────────────────────────────────────────
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
  regex = [[((?:~|/)[^\s:]+):(\d+)(?::(\d+))?]],
  format = 'vscode://file/$1:$2:$3',
})

table.insert(config.hyperlink_rules, {
  regex = [[\b(localhost|127\.0\.0\.1):(\d+)\b]],
  format = 'http://$1:$2',
})

-- ── Tmux auto-launch ──────────────────────────────────
config.default_prog = { '/opt/homebrew/bin/tmux', 'new-session', '-A', '-s', 'main' }

-- ── Keyboard ──────────────────────────────────────────
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

local tmux_prefix = { key = 'a', mods = 'CTRL' }

local function tmux(key, mods)
  return act.Multiple {
    act.SendKey(tmux_prefix),
    act.SendKey { key = key, mods = mods or 'NONE' },
  }
end

config.keys = {
  -- macOS line navigation
  { key = 'LeftArrow',  mods = 'CMD',       action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'RightArrow', mods = 'CMD',       action = act.SendKey { key = 'e', mods = 'CTRL' } },

  -- Cmd → tmux windows
  { key = 't',          mods = 'CMD',       action = tmux('c') },
  { key = 'w',          mods = 'CMD',       action = tmux('x') },
  { key = ',',          mods = 'CMD',       action = tmux(',') },
  { key = '1',          mods = 'CMD',       action = tmux('1') },
  { key = '2',          mods = 'CMD',       action = tmux('2') },
  { key = '3',          mods = 'CMD',       action = tmux('3') },
  { key = '4',          mods = 'CMD',       action = tmux('4') },
  { key = '5',          mods = 'CMD',       action = tmux('5') },
  { key = '6',          mods = 'CMD',       action = tmux('6') },
  { key = '7',          mods = 'CMD',       action = tmux('7') },
  { key = '8',          mods = 'CMD',       action = tmux('8') },
  { key = '9',          mods = 'CMD',       action = tmux('9') },

  -- Cmd → tmux splits
  { key = 'd',          mods = 'CMD',       action = tmux('v') },
  { key = 'd',          mods = 'CMD|SHIFT', action = tmux('s') },

  -- Cmd → tmux pane navigation
  { key = 'LeftArrow',  mods = 'CMD|ALT',   action = tmux('h') },
  { key = 'DownArrow',  mods = 'CMD|ALT',   action = tmux('j') },
  { key = 'UpArrow',    mods = 'CMD|ALT',   action = tmux('k') },
  { key = 'RightArrow', mods = 'CMD|ALT',   action = tmux('l') },

  -- Cmd+Z → tmux zoom pane
  { key = 'z',          mods = 'CMD',       action = tmux('z') },

  -- Wezterm native
  { key = 'f',          mods = 'CMD',       action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'k',          mods = 'CMD',       action = act.ClearScrollback 'ScrollbackAndViewport' },
}

-- ── Quick select patterns ─────────────────────────────
config.quick_select_patterns = {
  '[0-9a-f]{7,40}',
  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
  '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',
  '(?:/[\\w.-]+)+',
}

-- ── Copy/paste ────────────────────────────────────────
config.selection_word_boundary = ' \t\n{}[]()\"\':;,.<>~!@#$%^&*|+=\\/?-'
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ── Terminal features ─────────────────────────────────
config.bypass_mouse_reporting_modifiers = 'SHIFT'
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
config.term = 'xterm-256color'

return config
