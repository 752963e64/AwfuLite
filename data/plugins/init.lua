local core = require "core"
local config = require "core.config"
local style = require "core.style"
local keymap = require "core.keymap"
local command = require "core.command"


-- re-define default conf
-- config.project.ignore_files = { "^%.", "^lite$", "%.zip$", "%.ttf$", "%.png$" }

-- renderer.show_debug(true)

-- plugins/treeview.lua
config.treeview = {}
config.treeview.size = config.common.default_split_size
config.treeview.visible = false
config.treeview.font = "font"


-- plugins/console.lua
config.console = {}
config.console.size = config.common.default_split_size
config.console.max_lines = 200
config.console.visible = false


-- plugins/log.lua
config.log = {}
config.log.size = config.common.default_split_size
config.log.visible = false


config.plugins = { 
  "plugins.treeview",
  "plugins.console",
  "plugins.log",
  "plugins.testing"
}


for _, plugin in ipairs(config.plugins) do
  core.try(require, plugin)
  core.log_quiet("Loaded %q", plugin)
end



-- key binding:
keymap.add {
  -- plugins/console.lua
  ["ctrl+:"]                    = "console:toggle",
  ["ctrl+shift+:"]              = "console:run",

  -- plugins/log.lua
  ["ctrl+!"]                    = "log:toggle",

  -- plugins/treeview.lua
  ["ctrl+shift+t"]              = "treeview:toggle",
  ["ctrl+shift+l"]              = "treeview:larger",
  ["ctrl+shift+m"]              = "treeview:smaller",
}

-- light theme:
-- require "colors.summer"


-- key binding:
-- keymap.add {
--   -- plugins/console.lua
--   ["ctrl+:"]                    = "console:toggle",
--   ["ctrl+shift+:"]              = "console:run",
-- 
--   -- plugins/log.lua
--   ["ctrl+!"]                    = "log:toggle",
-- 
--   -- plugins/autocomplete.lua
--   ["tab"]                       = "autocomplete:complete",
--   ["up"]                        = "autocomplete:previous",
--   ["down"]                      = "autocomplete:next",
--   ["escape"]                    = "autocomplete:cancel",
-- 
--   -- plugins/bracket.lua
--   ["ctrl+m"]                    = "bracket:move-to-matching",
-- 
--   -- plugins/macro.lua
--   ["ctrl+shift+;"]              = "macro:record",
--   ["ctrl+;"]                    = "macro:play",
-- 
--   -- plugins/project.lua
--   ["f5"]                        = "project:refresh",
--   ["ctrl+shift+f"]              = "project:find-text",
--   ["up"]                        = "project:select-previous",
--   ["down"]                      = "project:select-next",
--   ["return"]                    = "project:open-selected",
--   ["ctrl+p"]                    = "project:find-file",
-- 
--   -- plugins/quote.lua
--   ["ctrl+k"]                    = "quote:quote",
-- 
--   -- plugins/reflow.lua
--   ["ctrl+shift+r"]              = "reflow:reflow",
-- 
--   -- plugins/treeview.lua
--   ["ctrl+shift+t"]              = "treeview:toggle",
--   ["ctrl+shift+l"]              = "treeview:larger",
--   ["ctrl+shift+m"]              = "treeview:smaller",
-- }
-- 

