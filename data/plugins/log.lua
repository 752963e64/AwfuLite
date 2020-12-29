local core = require "core"
local config = require "core.config"
local style = require "core.style"
local command = require "core.command"
local keymap = require "core.keymap"
local View = require "core.view"


config.dprint("log.lua -> loaded")


local LogView = View:extend()


function LogView:new()
  LogView.super.new(self)
  self.last_item = core.log_items[#core.log_items]
  self.scrollable = true
  self.focusable = false
  self.visible = config.log.visible
  self.height = config.log.size
end


function LogView:get_name()
  return "---"
end


function LogView:get_font()
  return style.xft.mono_regular
end


function LogView:update(...)
  local item = core.log_items[#core.log_items]
  if self.last_item ~= item then
    self.last_item = item
  end

  local dest = self.visible and self.height or 0
  self:move_towards(self.size, "y", dest)

  LogView.super.update(self)
end


function LogView:get_item_height()
  return self.get_font():get_height() + style.padding.y
end


function LogView:get_scrollable_size()
  if self.visible then
    return self:get_item_height() * (#core.log_items + 1)
  end
  return 0
end


local function draw_text_multiline(font, text, x, y, color)
  local th = font:get_height()
  local resx, resy = x, y
  for line in text:gmatch("[^\n]+") do
    resy = y
    resx = renderer.draw_text(font, line, x, y, color)
    y = y + th
  end
  
  return resx, resy
end


function LogView:draw()
  self:draw_background(style.background)

  local ox, oy = self:get_content_offset()
  local xft = self.get_font()
  local th = xft:get_height()
  local y = oy + style.padding.y + 0

  for i = #core.log_items, 1, -1 do
    local x = ox + style.padding.x
    local item = core.log_items[i]
    local time = os.date(nil, item.time)
    x = renderer.draw_text(xft, time, x, y, style.dim)
    x = x + style.padding.x
    local subx = x
    x, y = draw_text_multiline(xft, item.text, x, y, style.text)
    renderer.draw_text(xft, " at " .. item.at, x, y, style.dim)
    y = y + th
    if item.info then
      subx, y = draw_text_multiline(xft, item.info, subx, y, style.dim)
      y = y + th
    end
    y = y + style.padding.y
  end
end


local view = LogView()
local node = core.root_view:get_active_node()
node:split("down", view, true)

command.add(nil, {
  ["log:toggle"] = function()
    view.visible = not view.visible
  end,
})

