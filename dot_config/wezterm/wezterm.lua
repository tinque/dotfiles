local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ============================================
-- APPEARANCE
-- ============================================
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
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- ===== CURSOR =====
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- ===== WINDOW BACKGROUND (blur + transparency macOS) =====
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20

-- ===== TAB BAR (disabled but styled fallback) =====
config.use_fancy_tab_bar = false

-- ============================================
-- PERFORMANCE (macOS optimizations)
-- ============================================
config.front_end = 'WebGpu'  -- Best rendering on macOS
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 120
config.animation_fps = 60

-- ============================================
-- SCROLLBACK (essential for AI responses)
-- ============================================
config.scrollback_lines = 100000  -- Default is 3500, AI outputs are long
config.enable_scroll_bar = false

-- ============================================
-- HYPERLINKS (clickable URLs and file paths)
-- ============================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add file:line:col pattern for compiler errors and stack traces
table.insert(config.hyperlink_rules, {
  regex = [[((?:~|/)[^\s:]+):(\d+)(?::(\d+))?]],
  format = 'vscode://file/$1:$2:$3',
})

-- Add localhost URLs
table.insert(config.hyperlink_rules, {
  regex = [[\b(localhost|127\.0\.0\.1):(\d+)\b]],
  format = 'http://$1:$2',
})

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
-- macOS Option key for accented characters
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

config.keys = {
{
  key = "LeftArrow",
  mods = "CMD",
  action = act.SendKey({ key = "a", mods = "CTRL" }),
},
{
  key = "RightArrow",
  mods = "CMD",
  action = act.SendKey({ key = "e", mods = "CTRL" }),
},
}

-- ============================================
-- QUICK SELECT PATTERNS (for copying)
-- ============================================
config.quick_select_patterns = {
  -- Git hashes (short and long)
  '[0-9a-f]{7,40}',
  -- UUIDs
  '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
  -- IP addresses
  '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',
  -- File paths
  '(?:/[\\w.-]+)+',
}

-- ============================================
-- COPY/PASTE BEHAVIOR
-- ============================================
config.selection_word_boundary = ' \t\n{}[]()\"\':;,.<>~!@#$%^&*|+=\\/?-'
-- Copy on select (like iTerm2)
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  -- Open link with Cmd+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ============================================
-- TERMINAL FEATURES
-- ============================================
-- Better mouse reporting (useful with tmux/vim)
config.bypass_mouse_reporting_modifiers = 'SHIFT'

-- Bell notification
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}

-- Better compatibility with tmux
config.term = "xterm-256color"


return config
