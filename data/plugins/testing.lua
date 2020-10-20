local core = require "core"
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"


config.dprint("testing.lua -> loaded")


command.add(nil, {
  ["testing:toggle"] = function()
    renderer.draw_image("")
  end,
})

