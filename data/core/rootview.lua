local core = require "core"
local View = require "core.view"
local DocView = require "core.docview"
local Node = require "core.node"
local EmptyView = require "core.emptyview"
local common = require "core.common"
local config = require "core.config"


config.dprint("rootview.lua -> loaded")


local RootView = View:extend()


function RootView:new()
  RootView.super.new(self)
  self.root_node = Node()
  self.deferred_draws = {}
  self.mouse = { x = 0, y = 0 }
end


function RootView:defer_draw(fn, ...)
  table.insert(self.deferred_draws, 1, { fn = fn, ... })
end


function RootView:get_active_node()
  return self.root_node:get_node_for_view(core.active_view)
end


function RootView:open_doc(doc)
  local node = self:get_active_node()
  if node.locked and core.last_active_view then
    core.set_active_view(core.last_active_view)
    node = self:get_active_node()
  end
  assert(not node.locked, "Cannot open doc on locked node")
  local views = core.root_view.root_node:get_children()
  for i, view in ipairs(views) do
    if view.doc == doc then
      node = self.root_node:get_node_for_view(view)
      node:set_active_view(view)
      return view
    end
  end
  local view = DocView(doc)
  node:add_view(view)
  self.root_node:update_layout()
  view:scroll_to_line(view.doc:get_selection(), true, true)
  return view
end


function RootView:on_mouse_pressed(button, x, y, clicks)
  local node = self.root_node:get_child_overlapping_point(x, y)

  if button == "left" then
    local div = self.root_node:get_divider_overlapping_point(x, y)
    if div then
      self.dragged_divider = div
      return
    end
  end  -- do not forward when grabing divider
  if node then
    if node.active_view ~= core.active_view then
      core.set_active_view(node.active_view)
    end
    node.active_view:on_mouse_pressed(button, x, y, clicks)
  end
end


function RootView:on_mouse_released(button, x, y, clicks)
  local node = self.root_node:get_child_overlapping_point(x, y)
  if button == "left" then
    if self.dragged_divider then
      self.dragged_divider = nil
      return
    end -- do not forward when grabing divider
  end
  if node then
    if y > (self.size.y-core.status_view.size.y) or x < 1 then
      core.active_view:on_mouse_released(button, x, y, clicks)
    else
      node:on_mouse_released(button, x, y, clicks)
    end
  end
  -- self.root_node:on_mouse_released(button, x, y, clicks)
end


function RootView:on_mouse_moved(x, y, dx, dy)
  self.mouse.x, self.mouse.y = x, y

  if self.dragged_divider then
    local node = self.dragged_divider
    if node.type == "hsplit" then
      node.divider = node.divider + dx / node.size.x
    else
      node.divider = node.divider + dy / node.size.y
    end
    node.divider = common.clamp(node.divider, 0.01, 0.99)
    return
  end
  
  local node = self.root_node:get_child_overlapping_point(x, y)
  local div = self.root_node:get_divider_overlapping_point(x, y)
  if node then self.root_node:on_mouse_moved(x, y, dx, dy) end
  if div then
    system.set_cursor(div.type == "hsplit" and "sizeh" or "sizev")
  -- elseif node:get_tab_overlapping_point(x, y) then
  --  system.set_cursor("arrow")
  else
    system.set_cursor(node.active_view.cursor)
  end
end


function RootView:on_mouse_wheel(...)
  local x, y = self.mouse.x, self.mouse.y
  local node = self.root_node:get_child_overlapping_point(x, y)
  if node then node.active_view:on_mouse_wheel(...) end
end


function RootView:on_text_input(...)
  core.active_view:on_text_input(...)
end


function RootView:update()
  common.copy_position_and_size(self.root_node, self)
  self.root_node:update()
  self.root_node:update_layout()
end


function RootView:draw()
  self.root_node:draw()
  while #self.deferred_draws > 0 do
    local t = table.remove(self.deferred_draws)
    t.fn(table.unpack(t))
  end
end


return RootView
