local core = require "core"
local common = require "core.common"
local command = require "core.command"

command.add(nil, {
  ["module:reload"] = function()
    core.command_view:enter("Reload Module", function(text, item)
      local text = item and item.text or text
      core.reload_module(text)
      core.log("Reloaded module %q", text)
    end, function(text)
      local items = {}
      for name in pairs(package.loaded) do
        table.insert(items, name)
      end
      return common.fuzzy_match(items, text)
    end)
  end,

  -- ["module:open-user-config"] = function()
  --   core.root_view:open_doc(core.open_doc(EXEDIR .. "/data/user/init.lua"))
  -- end,
})