local core = require "core"
local config = require "core.config"
local command = require "core.command"
local LogView = require "core.logview"

-- init static bottom-logview
local view = LogView()
local node = core.root_view:get_active_node()
node:split("down", view, true)

function view:update(...)
  local dest = config.log.visible and config.common.default_split_size or 0
  self:move_towards(self.size, "y", dest)
  LogView.update(self, ...)
end

command.add(nil, {
  -- toggle builtin logview
  ["log:toggle"] = function()
    config.log.visible = not config.log.visible
  end,
  ["log:open"] = function()
    local node = core.root_view:get_active_node()
    node:add_view(LogView())
  end,
})
