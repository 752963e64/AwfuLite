local core = require "core"
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"


if config.debug then
  print("testing.lua -> loaded")
end

command.add(nil, {
  ["testing:toggle"] = function()
    renderer.draw_image("")
  end,
})

