local core = require "core"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local Object = require "core.object"

config.dprint("view.lua -> loaded")


local View = Object:extend()


function View:new()
  self.position = { x = 0, y = 0 }
  self.size = { x = 0, y = 0 }
  self.scroll = { x = 0, y = 0, to = { x = 0, y = 0 } }
  self.mouse = { x = 0, y = 0 }
  self.cursor = "arrow"
  self.scrollable = false
end


function View:move_towards(t, k, dest, rate)
  if type(t) ~= "table" then
    return self:move_towards(self, t, k, dest, rate)
  end
  local val = t[k]
  if math.abs(val - dest) < 0.5 then
    t[k] = dest
  else
    t[k] = common.lerp(val, dest, rate or 0.5)
  end
  if val ~= dest then
    core.redraw = true
  end
end


function View:try_close(do_close)
  do_close()
end


function View:get_name()
  return "---"
end


function View:get_scrollable_size()
  --no-op
  return math.huge
end


function View:get_scrollbar_rect()
  local sz = self:get_scrollable_size()
  if sz <= self.size.y or sz == math.huge then
    return 0, 0, 0, 0
  end
  local h = math.max(20, self.size.y * self.size.y / sz)
  return
    self.position.x + self.size.x - style.scrollbar_size,
    self.position.y + self.scroll.y * (self.size.y - h) / (sz - self.size.y),
    style.scrollbar_size,
    h
end


function View:scrollbar_overlaps_point(x, y)
  local sx, sy, sw, sh = self:get_scrollbar_rect()
  return x >= sx - sw * 3 and x < sx + sw and y >= sy and y < sy + sh
end


function View:resolve_mouse_position()
  local x, y = self.mouse.x, self.mouse.y
  x = config.core.show_gutter and x-self:get_gutter_width() or x-style.padding.x
  x = config.treeview.visible and x-config.treeview.size or x

  return x, y
end


function View:on_mouse_pressed(button, x, y, clicks)
  if button == "left" and self.hovered_scrollbar then
    self.hold_scrollbar = true
    return
  end
end


function View:on_mouse_released(button, x, y)
  if button == "left" then
    if self.hold_scrollbar then
      self.hold_scrollbar = false
      if self.cursor ~= "ibeam" then
        self.cursor = "ibeam"
      end
    end
  end
end


function View:on_mouse_moved(x, y, dx, dy)
  self.mouse.x, self.mouse.y = x, y
  if self.hovered_scrollbar or self.hold_scrollbar then
    if self.cursor ~= "arrow" then
      self.cursor = "arrow"
    end
    if self.hold_scrollbar then
      local delta = self:get_scrollable_size() / self.size.y * dy
      self.scroll.to.y = self.scroll.to.y + delta
      return true
    end
  end
  self.hovered_scrollbar = self:scrollbar_overlaps_point(x, y)
end


function View:on_text_input(text)
  -- no-op
end


function View:on_mouse_wheel(y)
  if self.scrollable then
    self.scroll.to.y = self.scroll.to.y + y * -config.core.mouse_wheel_scroll
  end
end


function View:get_content_bounds()
  local x = self.scroll.x
  local y = self.scroll.y
  return x, y, x + self.size.x, y + self.size.y
end


function View:get_content_offset()
  local x = common.round(self.position.x - self.scroll.x)
  local y = common.round(self.position.y - self.scroll.y)
  return x, y
end


function View:clamp_scroll_position()
  local max = self:get_scrollable_size() - self.size.y
  self.scroll.to.y = common.clamp(self.scroll.to.y, 0, max)
end


function View:has_x11_clipboard()
  return config.core.mouse_x11_clipboard
end


function View:window_has_focus()
  return core.active_view == self and system.window_has_focus()
end


function View:is_active_view()
  return self == core.active_view
end


function View:update()
  self:clamp_scroll_position()
  self:move_towards(self.scroll, "x", self.scroll.to.x, 0.3)
  self:move_towards(self.scroll, "y", self.scroll.to.y, 0.3)
end


function View:draw_background(color)
  local x, y = self.position.x, self.position.y
  local w, h = self.size.x, self.size.y
  renderer.draw_rect(x, y, w + x % 1, h + y % 1, color)
end


function View:draw_scrollbar()
  local x, y, w, h = self:get_scrollbar_rect()
  local highlight = self.hovered_scrollbar or self.dragging_scrollbar
  local color = highlight and style.scrollbar2 or style.scrollbar
  renderer.draw_rect(x, y, w, h, color)
end


function View:draw()
  -- no-op
end


return View
