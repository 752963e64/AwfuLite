-- put user settings here
-- this module will be loaded after everything else when the application starts

local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"


-- plugins config
-- plugins/console.lua
config.console = {}
config.console.max_lines = 200
config.console.visible = false

-- plugins/log.lua
config.log = {}
config.log.visible = false

-- plugins/treeview.lua
config.treeview = {}
config.treeview.size = 230 * SCALE

-- re-define default conf
config.project.ignore_files = { "^%.", "^lite$", "%.zip$", "%.ttf$", "%.png$" }

-- light theme:
-- require "user.colors.summer"

-- key binding:
keymap.add {
  -- plugins/console.lua
  ["ctrl+:"]                    = "console:toggle",
  ["ctrl+shift+:"]              = "console:run",

  -- plugins/autocomplete.lua
  ["tab"]                       = "autocomplete:complete",
  ["up"]                        = "autocomplete:previous",
  ["down"]                      = "autocomplete:next",
  ["escape"]                    = "autocomplete:cancel",

  -- plugins/bracket_match.lua
  ["ctrl+m"]                    = "bracket-match:move-to-matching",

  -- plugins/macro.lua
  ["ctrl+shift+;"]              = "macro:record",
  ["ctrl+;"]                    = "macro:play",

  -- plugins/project_search.lua
  ["f5"]                        = "project-search:refresh",
  ["ctrl+shift+f"]              = "project-search:find",
  ["up"]                        = "project-search:select-previous",
  ["down"]                      = "project-search:select-next",
  ["return"]                    = "project-search:open-selected",

  -- plugins/quote.lua
  ["ctrl+'"]                    = "quote:quote",

  -- plugins/reflow.lua
  ["ctrl+shift+q"]              = "reflow:reflow",

  -- plugins/treeview.lua
  ["ctrl+shift+t"]              = "treeview:toggle",
  ["ctrl+shift+l"]              = "treeview:larger",
  ["ctrl+shift+m"]              = "treeview:smaller",
}
