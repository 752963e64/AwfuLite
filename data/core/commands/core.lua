local core = require "core"
local common = require "core.common"
local config = require "core.config"
local keymap = require "core.keymap"
local command = require "core.command"
local LogView = require "core.logview"


command.add(nil, {
  ["core:quit"] = function()
    core.quit()
  end,

  ["core:force-quit"] = function()
    core.quit(true)
  end,

  ["core:toggle-fullscreen"] = function()
    config.window.fullscreen = not config.window.fullscreen
    system.set_window_mode(config.window.fullscreen and "fullscreen" or "normal")
  end,

  ["core:toggle-opacity"] = function()
    config.window.opacity = not config.window.opacity
    if config.window.opacity then
      system.set_window_opacity(0.8)
    else
      system.set_window_opacity(1)
    end
  end,

  ["core:find-command"] = function()
    local commands = command.get_all_valid()
    core.command_view:enter("Do Command", function(text, item)
      if item then
        command.perform(item.command)
      end
    end, function(text)
      local res = common.fuzzy_match(commands, text)
      for i, name in ipairs(res) do
        res[i] = {
          text = command.prettify_name(name),
          info = keymap.get_binding(name),
          command = name,
        }
      end
      return res
    end)
  end,

  --  ["core:open-log"] = function()
  --    local node = core.root_view:get_active_node()
  --    node:add_view(LogView())
  --  end,
})
