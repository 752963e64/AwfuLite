local config = {}

config.debug = false

function config.dprint(message)
  if config.debug == true then
    print(message)
  end
end

config.dprint("config.lua -> loaded")

-- do not change config here
-- re-define inside data/user/init.lua instead

config.project = {}
config.project.scan_rate = 5
config.project.file_size_limit = 10
config.project.ignore_files = {}
--

config.window = {}
config.window.fps = 30
config.window.fullscreen = false
config.window.opacity = false
config.window.blink_period = 0.8
--

config.core = {}
config.core.max_log_items = 80
config.core.mouse_wheel_scroll = 50 * SCALE
config.core.mouse_x11_clipboard = true
config.core.symbol_pattern = "[%a_][%w_]*"
config.core.non_word_chars = " \t\n/\\()\"':,.;<>~!@#$%^&*|+=[]{}`?-"
config.core.undo_merge_timeout = 0.3
config.core.max_undos = 10000
config.core.highlight_current_line = true
config.core.line_height = 1.2
config.core.indent_size = 2
config.core.show_gutter = true
config.core.tab_type = "soft"
config.core.warn_mixed_tab = true
config.core.markers = true
config.core.line_limit = 80
config.core.show_spaces = true
config.core.show_block_rulers = true
--

config.commandview = {}
config.commandview.max_suggestions = 10
--

config.statusview = {}
config.statusview.message_timeout = 3
--

config.common = {}
config.common.default_split_size = 200 * SCALE


return config
