local style = require "core.style"
local View = require "core.view"
local keymap = require "core.keymap"
local config = require "core.config"

config.dprint("emptyview.lua -> loaded")

local EmptyView = View:extend()

local function draw_text(x, y, color)
  local th = style.xft.logo:get_height()
  local dh = th + style.padding.y * 2
  x = renderer.draw_text(style.xft.logo, "AwFuLiTe", x, y + (dh - th) / 2, color)
  x = x + style.padding.x
  renderer.draw_rect(x, y, math.ceil(1 * SCALE), dh, color)
  local lines = {
    { fmt = "%s to run a command", cmd = "core:find-command" },
    { fmt = "%s to open an existing file", cmd = "core:open-file" },
    { fmt = "%s to open a new file", cmd = "core:new-file" },
  }
  th = style.xft.mono_bold:get_height()
  y = y + (dh - th * 2 - style.padding.y) / 2
  local w = 0
  for _, line in ipairs(lines) do
    local text = string.format(line.fmt, keymap.get_binding(line.cmd))
    w = math.max(w, renderer.draw_text(style.xft.mono_bold, text, x + style.padding.x, y-12, color))
    y = y + th + style.padding.y
  end
  return w, dh
end


function EmptyView:draw()
  if self.cursor ~= "arrow" then self.cursor = "arrow" end
  self:draw_background(style.background)
  local w, h = draw_text(0, 0, { 0, 0, 0, 0 })
  local x = self.position.x + math.max(style.padding.x, (self.size.x - w) / 2)
  local y = self.position.y + (self.size.y - h) / 2
  draw_text(x, y, style.dim)
end


return EmptyView
