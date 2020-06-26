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

  -- plugins/bracket.lua
  ["ctrl+m"]                    = "bracket:move-to-matching",

  -- plugins/macro.lua
  ["ctrl+shift+;"]              = "macro:record",
  ["ctrl+;"]                    = "macro:play",

  -- plugins/project.lua
  ["f5"]                        = "project:refresh",
  ["ctrl+shift+f"]              = "project:find-text",
  ["up"]                        = "project:select-previous",
  ["down"]                      = "project:select-next",
  ["return"]                    = "project:open-selected",
  ["ctrl+p"]                    = "project:find-file",

  -- plugins/quote.lua
  ["ctrl+k"]                    = "quote:quote",

  -- plugins/reflow.lua
  ["ctrl+shift+r"]              = "reflow:reflow",

  -- plugins/treeview.lua
  ["ctrl+shift+t"]              = "treeview:toggle",
  ["ctrl+shift+l"]              = "treeview:larger",
  ["ctrl+shift+m"]              = "treeview:smaller",
}
