local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"
local View = require "core.view"


config.dprint("statuview.lua -> loaded")


local StatusView = View:extend()
local last_yoffset = 0

StatusView.separator  = "      "
StatusView.separator2 = "   |   "


function StatusView:new()
  StatusView.super.new(self)
  self.message_timeout = 0
  self.message = {}
end


--function StatusView:on_mouse_pressed()
--  core.set_active_view(core.last_active_view)
--  if system.get_time() < self.message_timeout
--  and not core.active_view:is(LogView) then
--    command.perform "log:toggle"
--  end
--end


function StatusView:get_font()
  return style.xft.mono_regular
end

function StatusView:show_message(icon, icon_color, text)
  local font = self.get_font()
  local xsize = font:get_width(text)
  if xsize > (self.size.x/2) then
    while xsize > (self.size.x/2) do
      text = text:sub(1,-2)
      xsize = font:get_width(text)
    end
    text = text:sub(1,-5)
    text = text .. " …"
  end

  self.message = {
    icon_color, style.xft.icon, icon,
    style.dim, self.get_font(), StatusView.separator2, style.text, text
  }
  
  self.message_timeout = system.get_time() + config.statusview.message_timeout
end


function StatusView:update()
  self.size.y = self.get_font():get_height() + style.padding.y * 2

  if system.get_time() < self.message_timeout then
    self.scroll.to.y = self.size.y
  else
    self.scroll.to.y = 0
  end

  StatusView.super.update(self)
end


local function draw_items(self, items, x, y, draw_fn)
  local font = self.get_font()
  local color = style.text

  for _, item in ipairs(items) do
    if type(item) == "userdata" then
      font = item
    elseif type(item) == "table" then
      color = item
    else
      x = draw_fn(font, color, item, nil, x, y, 0, self.size.y)
    end
  end

  return x
end


local function text_width(font, _, text, _, x)
  return x + font:get_width(text)
end


function StatusView:draw_items(items, right_align, yoffset)
  local x, y = self:get_content_offset()
  y = y + (yoffset or 0)
  if right_align then
    x = x + self.size.x - self.right_width - style.padding.x
    draw_items(self, items, x, y, common.draw_text)
  else
    x = x + style.padding.x
    draw_items(self, items, x, y, common.draw_text)
  end
end


function StatusView:get_items()
  if getmetatable(core.active_view) == DocView then
    local dv = core.active_view
    local line, col = dv:rectify_column_position()
    local dirty = dv.doc:is_dirty()
    local node = core.root_view:get_active_node()
    local idx = node:get_view_idx(core.active_view)
    local xft = self.get_font()
    local tabtype = config.core.tab_type ~= "hard"
    local tabmixed = dv.doc.tab_mixed
    local tabindent = config.core.indent_size

    local is_multiple = #dv.doc.selection.c >= 1
    local scrollfeed = ""
    if dv.scroll.to.y > last_yoffset
    or dv.scroll.to.y < last_yoffset then
      scrollfeed = dv.scroll.to.y > last_yoffset
        and style.icons["sort-down"]
        or style.icons["sort-up"]
    end
    last_yoffset = dv.scroll.to.y

    return {
      dirty and style.accent2 or style.text,
      style.xft.icon, style.icons["code"],
      style.dim, xft, self.separator2,
      style.text, system.absolute_path(core.cwd).." - ",
      style.text, xft, #node.views .."/"..idx, style.text,
      style.dim, xft, self.separator2, style.text,
      dv.doc.filename and style.text or style.dim, dv.doc:get_name(),
      style.dim, xft, self.separator2, style.text,
      "line: ", is_multiple and "…" or line,
      style.dim, xft, " / ", style.text,
      -- col > config.core.line_limit and style.accent or
      style.text,
      "col: ", is_multiple and "…" or col,
      style.dim, xft, " / ", style.text,
      is_multiple and "…" or string.format("%d%%", line / #dv.doc.lines * 100),
    }, {
      style.dim, style.xft.icon, scrollfeed,
      xft, style.dim, self.separator2,
      style.xft.icon, style.icons["chart-line"],
      xft, style.dim, self.separator2, style.text,
      #dv.doc.lines, " lines",
      style.dim, xft, self.separator2, style.text,
      dv.doc.crlf and "CRLF" or "LF",
      style.dim, xft, self.separator2, tabmixed and style.accent2 or style.text,
      (tabtype and "space" or "tab"),
      style.text, ": "..tabindent
    }
  end

  return {}, {
    style.xft.icon, style.icons["chart-line"],
    self.get_font(), style.dim, self.separator2,
    #core.docs, style.text, " / ",
    #core.project_files, " files"
  }
end


function StatusView:draw()
  self:draw_background(style.background2)

  if self.message then
    self:draw_items(self.message, false, self.size.y)
  end

  local left, right = self:get_items()
  self.left_width = draw_items(self, left, 0, 0, text_width)
  self.right_width = draw_items(self, right, 0, 0, text_width)

  if self.left_width+self.right_width >= self.size.x then
    self:draw_items({ style.text, "…" })
    return
  end

  self:draw_items(left)
  self:draw_items(right, true)
end


return StatusView
