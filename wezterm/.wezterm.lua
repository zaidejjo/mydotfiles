-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.colors = {
	foreground = "#CDD6F4",
	background = "#1E1E2E",
	cursor_bg = "#F5E0DC",
	cursor_border = "#F5E0DC",
	cursor_fg = "#1E1E2E",
	selection_bg = "#585B70",
	selection_fg = "#CDD6F4",
	ansi = {
		"#45475A", -- black
		"#F38BA8", -- red
		"#A6E3A1", -- green
		"#F9E2AF", -- yellow
		"#89B4FA", -- blue
		"#F5C2E7", -- magenta
		"#94E2D5", -- cyan
		"#BAC2DE", -- white
	},
	brights = {
		"#585B70", -- bright black
		"#F38BA8", -- bright red
		"#A6E3A1", -- bright green
		"#F9E2AF", -- bright yellow
		"#89B4FA", -- bright blue
		"#F5C2E7", -- bright magenta
		"#94E2D5", -- bright cyan
		"#A6ADC8", -- bright white
	},
}

-- color_scheme = 'Catppuccin Mocha',

-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#011423",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	cursor_fg = "#011423",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
-- 	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }
--
-- config.font = wezterm.font("MesloLGS Nerd Font Mono")
-- config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.font = wezterm.font_with_fallback({
	"CaskaydiaCove Nerd Font", -- خطك المفضل للإنجليزي
	"IBM Plex Sans Arabic", -- أفضل خط عربي للتيرمينال (يجب تنصيبه على جهازك)
	"Arial", -- كخيار احتياطي أخير
})
config.font_size = 12
config.bidi_enabled = true
config.enable_tab_bar = false

config.window_background_opacity = 0.85
config.macos_window_background_blur = 20 -- لمستخدمي الماك
config.win32_system_backdrop = "Acrylic" -- لمستخدمي ويندوز (يعطي تأثير زجاجي)

config.window_decorations = "RESIZE"
config.window_padding = {
	left = 15,
	right = 15,
	top = 15,
	bottom = 15,
}

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

config.keys = {
	-- تقسيم الشاشة بالعرض (Horizontal Split)
	{ key = "d", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- تقسيم الشاشة بالطول (Vertical Split)
	{ key = "e", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- غلق الـ Pane الحالي
	{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{
		key = "z",
		mods = "CTRL|SHIFT",
		action = wezterm.action.TogglePaneZoomState,
	},	
}

config.front_end = "WebGpu"
-- config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 10

-- and finally, return the configuration to wezterm
return config
