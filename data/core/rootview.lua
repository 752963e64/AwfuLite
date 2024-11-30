local core = require "core"
local View = require "core.view"
local DocView = require "core.docview"
local Node = require "core.node"
local common = require "core.common"
local config = require "core.config"


config.dprint("rootview.lua -> loaded")


local RootView = View:extend()


function RootView:new()
  RootView.super.new(self)
  self.root_node = Node()
  self.deferred_draws = {}
  self.last_node = nil
end


function RootView:defer_draw(fn, ...)
  table.insert(self.deferred_draws, 1, { fn = fn, ... })
end


function RootView:get_active_node()
  if core.active_view then
    return self.root_node:get_node_for_view(core.active_view)
  end
end


function RootView:open_doc(doc)
  local node = self:get_active_node()
  if node and node.locked and core.last_active_view then
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
  if button == "left" then
    -- test if we are hover a node divider
    local div = self.root_node:get_divider_overlapping_point(x, y)
    if div then
      self.dragged_divider = div
      return -- do not forward when grabing divider
    end
  end
  local node = self.root_node:get_child_overlapping_point(x, y)
  if node then
    if node.active_view ~= core.active_view then
      core.set_active_view(node.active_view)
    end
    node.active_view:on_mouse_pressed(button, x, y, clicks)
  end
end


function RootView:on_mouse_released(button, x, y, clicks)
  if button == "left" then
    if self.dragged_divider then
      self.dragged_divider = nil
      return -- do not forward when grabing divider
    end
  end
  local node = self.root_node:get_child_overlapping_point(x, y)
  if node then
    node.active_view:on_mouse_released(button, x, y, clicks)
  end
  system.set_cursor(node.active_view.cursor)
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
    return -- doesn't forward mouse event when handling divider
  end
  
  local node = self.root_node:get_child_overlapping_point(x, y)
  local div = self.root_node:get_divider_overlapping_point(x, y)
  -- self.root_node:on_mouse_moved(x, y, dx, dy)
  if node then
    -- make a call to the last_node if there is...
    -- it permits to update its state & refresh things that need to be refresh... 
    if self.last_node ~= nil and node ~= self.last_node then
      self.last_node:on_mouse_moved(x, y, dx, dy)
    end
    node.active_view:on_mouse_moved(x, y, dx, dy)
    self.last_node = node
  end
  if div then
    node.active_view.cursor = (div.type == "hsplit" and "sizeh" or "sizev")
  end
  system.set_cursor(node.active_view.cursor)
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
