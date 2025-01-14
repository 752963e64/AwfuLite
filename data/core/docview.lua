local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local keymap = require "core.keymap"
local translate = require "core.doc.translate"
local View = require "core.view"


config.dprint("docview.lua -> loaded")


local DocView = View:extend()


local function move_to_line_offset(dv, line, col, offset)
  local xo = dv.last_x_offset
  if xo.line ~= line or xo.col ~= col then
    xo.offset = dv:get_col_x_offset(line, col)
  end
  xo.line = line + offset
  xo.col = dv:get_x_offset_col(line + offset, xo.offset)
  return xo.line, xo.col
end


DocView.translate = {
  ["previous_page"] = function(doc, line, col, dv)
    local min, max = dv:get_visible_line_range()
    return line - (max - min), 1
  end,

  ["next_page"] = function(doc, line, col, dv)
    local min, max = dv:get_visible_line_range()
    return line + (max - min), 1
  end,

  ["previous_line"] = function(doc, line, col, dv)
    if line == 1 then
      return 1, 1
    end
    return move_to_line_offset(dv, line, col, -1)
  end,

  ["next_line"] = function(doc, line, col, dv)
    if line == #doc.lines then
      return #doc.lines, math.huge
    end
    return move_to_line_offset(dv, line, col, 1)
  end,
}

local blink_period = config.window.blink_period


function DocView:new(doc)
  DocView.super.new(self)
  self.cursor = "ibeam"
  self.scrollable = true
  self.doc = assert(doc)
  self.last_x_offset = {}
  self.blink_timer = 0
end


function DocView:try_close(do_close)
  if self.doc:is_dirty()
  and #core.get_views_referencing_doc(self.doc) == 1 then
    core.command_view:enter("Unsaved Changes; Confirm Close", function(_, item)
      if item.text:match("^[cC]") then
        do_close()
      elseif item.text:match("^[sS]") then
        self.doc:save()
        do_close()
      end
    end, function(text)
      local items = {}
      if not text:find("^[^cC]") then table.insert(items, "Close Without Saving") end
      if not text:find("^[^sS]") then table.insert(items, "Save And Close") end
      return items
    end)
  else
    do_close()
  end
end


function DocView:get_name()
  local post = self.doc:is_dirty() and "*" or ""
  local name = self.doc:get_name()
  return name:match("[^/%\\]*$") .. post
end


function DocView:get_scrollable_size()
  return self:get_line_height() * (#self.doc.lines + 1) -- + self.size.y
end


function DocView:get_font()
  return style.xft.mono_bold
end


function DocView:get_line_height()
  return math.floor(self:get_font():get_height() * config.core.line_height)
end


function DocView:get_gutter_width()
  return self:get_font():get_width(#self.doc.lines) + style.padding.x * 2
end


function DocView:get_line_screen_position(idx)
  local x, y = self:get_content_offset()
  local lh = self:get_line_height()
  local gw = config.core.show_gutter and self:get_gutter_width() or style.padding.x
  return x + gw, y + (idx-1) * lh + style.padding.y
end


function DocView:get_line_text_y_offset()
  local lh = self:get_line_height()
  local th = self:get_font():get_height()
  return (lh - th) / 2
end


function DocView:get_visible_line_range()
  local x, y, x2, y2 = self:get_content_bounds()
  local lh = self:get_line_height()
  local minline = math.max(1, math.floor(y / lh))
  local maxline = math.min(#self.doc.lines, math.floor(y2 / lh) + 1)
  return minline, maxline
end


function DocView:get_col_x_offset(line, col)
  local text = self.doc.lines[line]
  if not text then return 0 end
  return self:get_font():get_width(text:sub(1, col - 1))
end


function DocView:get_x_offset_col(line, x)
  local text = self.doc.lines[line]

  local xoffset, last_i, i = 0, 1, 1
  for char in common.utf8_chars(text) do
    local w = self:get_font():get_width(char)
    if xoffset >= x then
      return (xoffset - x > w / 2) and last_i or i
    end
    xoffset = xoffset + w
    last_i = i
    i = i + #char
  end

  return #text
end


function DocView:rectify_column_position()
  local line, col = "…", "…"
  if #self.doc.selection.c < 1 then
    line, col = self.doc:get_selection()
    for i = col,1,-1 do -- rectify column over unicode
      if common.is_utf8_cont(self.doc:get_char(line, i)) then
        col = col -1
      end
    end
  end
  return line, col
end


function DocView:resolve_screen_position(x, y)
  if not x then x, y = self:resolve_mouse_position() end
  
  local ox, oy = self:get_line_screen_position(1)
  local line = math.floor((y - oy) / self:get_line_height()) + 1
  line = common.clamp(line, 1, #self.doc.lines)
  local col = self:get_x_offset_col(line, x - ox)
  return line, col
end


function DocView:scroll_to_line(line, ignore_if_visible, instant)
  local min, max = self:get_visible_line_range()
  if not (ignore_if_visible and line > min and line < max) then
    local lh = self:get_line_height()
    self.scroll.to.y = math.max(0, lh * (line - 1) - self.size.y / 2)
    if instant then
      self.scroll.y = self.scroll.to.y
    end
  end
end


function DocView:scroll_to_make_visible(line, col)
  if not core.active_view == self then
    return
  end
  local min = self:get_line_height() * (line - 1)
  local max = self:get_line_height() * (line + 2) - self.size.y
  self.scroll.to.y = math.min(self.scroll.to.y, min)
  self.scroll.to.y = math.max(self.scroll.to.y, max)
  local gw = self:get_gutter_width()
  local xoffset = self:get_col_x_offset(line, col)
  local max = xoffset - self.size.x + gw + self.size.x / 5
  self.scroll.to.x = math.max(0, max)
end


function DocView:autoscroll(line)
  local min,max = self:get_visible_line_range()
  self.mouse_autoscroll = nil

  if max < #self.doc.lines
  and line >= max-2 then
    self.mouse_autoscroll = "down"
  elseif min > 1 and line <= min+2 then
    self.mouse_autoscroll = "up"
  end
end


function DocView:update_shift_selections(line1, col1)
  if self.update_shift then return end
  self.update_shift = true
  local selections = #self.doc.selection.c > 1
  local x, _ = self:resolve_mouse_position()

  -- ending selection
  local el1, ec1 = self.doc:get_last_selections()
  -- primary selection
  local pl1, pc1, _, pc2 = self.doc:get_first_selections()

  if not self.doc:has_selection() and
    pc1 == 1 and pc1 == pc2 and
    not self.primary_col then
    if self:get_x_offset_col(line1, x) > 1 then
      self.primary_col = self:get_x_offset_col(line1, x)
    end
  end

  local lline, lcol = el1, ec1

  if line1 ~= el1 then
    while lline < self.add_cursor or lline > self.add_cursor do
      if #self.doc.selection.c > 1 and self.add_cursor ~= 0 then
        self.doc:remove_last_selections()
      else
        break
      end
      lline, lcol = self.doc:get_last_selections()
    end
  end

  -- update selection's column based on mouse position
  for n,d in ipairs(self.doc.selection.c) do
    local l1, c1, l2, c2 = table.unpack(d)
    local nc = self:get_x_offset_col(l1, x)
    if nc ~= c1 then
      self.doc.selection.c[n] = { l1, nc, l2, c2 }
    end
    if c2 > 1 and c2 < pc2 then
      self.doc.selection.c[n] = { l1, nc, l2, c2 }
    end
  end

  -- add cursors while keeping first selections as pivot
  if line1 ~= el1 then
    while self.add_cursor ~= line1 do
      if self.add_cursor == pl1 then
        self.doc.selection.c = { { pl1, pc1, pl1, pc2 } }
      end
      self.add_cursor = line1 >= self.add_cursor
        and self.add_cursor+1
        or self.add_cursor-1
      if self.add_cursor == 0 then
        return
      end
      if self.primary_col then
        pc2 = self.primary_col
      end
      self.doc:set_nodup_selections(self.add_cursor, pc1, self.add_cursor, pc2)
    end
  end
  self.update_shift = false

  self:autoscroll(line1)
end


function DocView:on_mouse_pressed(button, x, y, clicks)
  -- reset multi selection
  local selections = #self.doc.selection.c >= 1
  if selections then
    if self.doc:get_selection_mode("shift") or
    not keymap.modkeys["ctrl"] then
      self.doc:set_selection_mode("single")
      self.doc.selection.c = {}
    end
  end

  local line, col = self:resolve_screen_position(x, y)
  if not line then return end

  if button == "left" then
    if clicks == 2 then -- select word after 2 clicks
      local line1, col1 = translate.start_of_word(self.doc, line, col)
      local line2, col2 = translate.end_of_word(self.doc, line, col)
      self.doc:set_selection(line2, col2, line1, col1)
    elseif clicks == 3 then -- select entire line after 3 clicks
      if line == #self.doc.lines then
        self.doc:insert(math.huge, math.huge, "\n")
      end
      self.doc:set_selection(line + 1, 1, line, 1)
    else
      local line2, col2
      if keymap.modkeys["ctrl"] then
        -- save previous cursor to selections
        self.doc:set_selection_mode("ctrl")
        if not selections then
          local pl1, cl1, pl2, cl2 = self.doc:get_selection()
          self.doc:set_selections(pl2, cl2, pl1, cl1)
        end
        -- add current line
        self.doc:set_selections(line, col)
        -- self.add_cursor = line
      elseif keymap.modkeys["shift"] then
        line2, col2 = select(3, self.doc:get_selection())
      end
      self.doc:set_selection(line, col, line2, col2)
      self.mouse_selecting = true
    end
  end

  if button == "right" then
    -- popup menu?
    if keymap.modkeys["shift"] then
      self.doc:set_selection_mode("shift")
      self.doc:set_selections(line, col)
      self.add_cursor = line
    end
  end

  self.blink_timer = 0
end


function DocView:on_mouse_moved(x, y, dx, dy)
  DocView.super.on_mouse_moved(self, x, y, dx, dy)

  local line1, col1 = self:resolve_screen_position(x+dx, y+dy)
  if self.hovered_scrollbar or self.hold_scrollbar then
    return
  end 
  if self.cursor ~= "ibeam" then
    self.cursor = "ibeam"
  end
  local selections = #self.doc.selection.c >= 1

  -- handle single|ctrl selection(s)
  if self.mouse_selecting then
    local line2, col2 = select(3, self.doc:get_selection())
    -- setup selection(s)
    if selections then
      self.doc:set_selections(line2, col2, line1, col1, nil, #self.doc.selection.c)
    else
      self.doc:set_selection(line1, col1, line2, col2)
    end

    -- autoscroll over single cursor selection
    if not keymap.modkeys["ctrl"] then
      self:autoscroll(line1)
    end
  end

  -- handle shift selections
  if self.add_cursor and not self.mouse_autoscroll then
    if keymap.modkeys["shift"] then
      -- setup shift selections which handles autoscroll
      self:update_shift_selections(line1, col1)
    end
  end
end


local function copy_selection(self)
  if self:has_x11_clipboard() then
    local text, e = "", ""
    if #self.doc.selection.c >= 1 then
      for i, d in ipairs(self.doc:get_selections()) do
        if self.doc:get_selection_mode("shift") then
          e = i == #self.doc.selection.c and "" or "\n"
        end
        text = text .. self.doc:get_text(table.unpack(d)) .. e
      end
    else
      text = self.doc:get_text(self.doc:get_selection())
    end
    if #text > 0 then
      system.set_selection_clipboard(text)
      core.log("Copy \"%d\" ßytes", #text)
    end
  end
end


function DocView:on_mouse_released(button, x, y)
  DocView.super.on_mouse_released(self, button, x, y)

  local selections = #self.doc.selection.c >= 1
  local do_copy = nil

  if button == "left" then
    if selections then
      local l1, c1, l2, c2 = self.doc:get_last_selections()
      if self.doc:has_selection(l1, c1, l2, c2) then
        do_copy = true
      end
    else
      if self.doc:has_selection() then
        do_copy = true
      end
    end
  end

  if button == "right" then
    if self.doc:has_selection() and
      self.doc:get_selection_mode("shift") then
      do_copy = true
    end
  end

  if do_copy then copy_selection(self) end

  if button == "middle" and self:has_x11_clipboard() then
    local text = system.get_selection_clipboard()
    if #text > 0 then
      local line, col = self:resolve_screen_position(x, y)
      if line and col then
        -- joy of loop...
        local node = core.root_view:get_active_node()
        local av = node.active_view
        if av.doc == self.doc then
          av.doc:insert(line, col, text)
          self.doc:set_selection(line, #text+col, line, #text+col)
          core.log("Paste \"%d\" ßytes", #text)
        end
      end
    end
  end

  self.add_cursor = nil
  self.mouse_selecting = nil
  self.mouse_autoscroll = nil
end


function DocView:on_text_input(text)
  self.doc:text_input(text)
end


function DocView:update()
  if self:is_active_view() then
    local line1, col1, line2, col2
    local selections = #self.doc.selection.c >= 1

    local line, col = self:resolve_screen_position()

    if selections then
      line1, col1, line2, col2 = self.doc:get_last_selections()
    else
      line1, col1, line2, col2 = self.doc:get_selection()
    end

    -- scroll to make caret visible and reset blink timer if it moved
    if (line1 ~= self.last_line or col1 ~= self.last_col) and self.size.x > 0 then
      if not selections then self:scroll_to_make_visible(line1, col1) end
      self.blink_timer = 0
      self.last_line, self.last_col = line1, col1
    end

    -- update blink timer
    local n = blink_period / 2
    local prev = self.blink_timer
    self.blink_timer = (self.blink_timer + 1 / config.window.fps) % blink_period
    if (self.blink_timer > n) ~= (prev > n) then
      core.redraw = true
    end
    
    -- update autoscroll
    if self.mouse_autoscroll then
      if self.mouse_autoscroll == "down" then
        if line1 < #self.doc.lines and line1 >= self.last_line then
          line1 = line1+1
        end
      elseif self.mouse_autoscroll == "up" then
        if line1 > 1 and line1 <= self.last_line then
          line1 = line1-1
        end
      end
      self:scroll_to_make_visible(line1, col1)

      if selections then
        self:update_shift_selections(line1, col1)
      else
        if line1 == #self.doc.lines or line1 == 1 then
          self.mouse_autoscroll = nil
          if line1 == #self.doc.lines then
            local x, _ = self:resolve_mouse_position()
            col1 = self:get_x_offset_col(line1, x)
          else col1 = 1 end
        end
        self.doc:set_selection(line1, col1, line2, col2)
      end
      self:autoscroll(line)
    end
  end -- self == core.active_view
  DocView.super.update(self)
end


function DocView:draw_line_highlight(x, y)
  if config.core.highlight_current_line
  and core.active_view == self then
    local lh = self:get_line_height()
    renderer.draw_rect(x, y, self.size.x, lh, style.line_highlight)
  end
end


function DocView:draw_line_text(idx, x, y)
  local tx, ty = x, y + self:get_line_text_y_offset()
  local font = self:get_font()
  local lh = self:get_line_height()
  local tw = font:get_width("\t")
  local sw = font:get_width(" ")
  local w = math.ceil(1 * SCALE)
  local tab_type = config.core.tab_type ~= "hard" and "space" or "tab"

  for n, type, text in self.doc.highlighter:each_token(idx) do
    local color = style.syntax[type]
    if type == "space" or type == "tab" then

      if config.core.warn_mixed_tab and tab_type ~= type then
        if not self.doc.tab_mixed then
          self.doc.tab_mixed = true
        end
      end

      if config.core.show_block_rulers and n == 1 then
        local indent_size = config.core.indent_size
        local text_size = type == "tab" and #text or #text-1
        local color = style.guide or style.selection
        for i = 0, text_size, indent_size do
          renderer.draw_rect(x + sw * i, y, w, lh, color)
        end
      end

      if config.core.show_spaces then
        if type == "space" then
          local v = "·"
          text = v:rep(#text)
        else
          local rx = tx
          for i = #text, 1, -1 do
            renderer.draw_rect(rx+(tw/3), ty+(lh/2), tw/2, w, color)
            rx = rx+tw
          end
        end
      end
    end

    tx = renderer.draw_text(font, text, tx, ty, color)
  end
end


function DocView:draw_selection(idx, x, y, line1, col1, line2, col2)
  if line1 and idx >= line1 and idx <= line2 then
    if not self.doc:get_selection_mode("shift") then
      local text = self.doc.lines[idx]
      if line1 ~= idx then col1 = 1 end
      if line2 ~= idx then col2 = #text + 1 end
    end
    local x1 = x + self:get_col_x_offset(idx, col1)
    local x2 = x + self:get_col_x_offset(idx, col2)
    local lh = self:get_line_height()
    renderer.draw_rect(x1, y, x2 - x1, lh, style.selection)
  end
end


function DocView:draw_caret(idx, x, y, col)
  if self.blink_timer < blink_period / 2 then
    local lh = self:get_line_height()
    local x1 = x + self:get_col_x_offset(idx, col)
    renderer.draw_rect(x1, y, style.caret_width, lh, style.caret)
  end
end


function DocView:draw_line_body(idx, x, y, selections)
  local line, col = self.doc:get_selection()
  
  -- draw selection(s) and or line highlight if it overlaps this line
  if self:is_active_view() then
    if #selections >= 1 then
      for i, l in ipairs(selections) do
        local l1, c1, l2, c2 = common.sort_positions(table.unpack(l))
        self:draw_selection(idx, x, y, l1, c1, l2, c2)

        if l1 == idx then
          if ( self.doc:get_selection_mode("shift") and not self.doc:has_selection() ) or
           ( self.doc:get_selection_mode("ctrl") and not self.doc:has_selection(l1, c1, l2, c2) ) then
            self:draw_line_highlight(x + self.scroll.x, y)
          end
          -- if self.doc:get_selection_mode("ctrl") and not self.doc:has_selection(l1, c1, l2, c2) then
          --   self:draw_line_highlight(x + self.scroll.x, y)
          -- end
        end
      end
    else
      local line1, col1, line2, col2 = self.doc:get_selection(true)
      self:draw_selection(idx, x, y, line1, col1, line2, col2)
      if line == idx and not self.doc:has_selection() then
        self:draw_line_highlight(x + self.scroll.x, y)
      end
    end
  end

  -- draw line's text
  self:draw_line_text(idx, x, y)

  -- draw caret(s) if it overlaps this line
  if self:window_has_focus() then
    if #selections >= 1 then
      for i, l in ipairs(selections) do
        local l1, c1, l2, c2 = table.unpack(l)
        if l2 == idx then
          if self.doc:get_selection_mode("shift") then
            if c1 ~= c2 or ( not self.doc:has_selection() and c1 == c2 ) then
              self:draw_caret(idx, x, y, c1)
            end
          else
            self:draw_caret(idx, x, y, c2)
          end
        end
      end
    elseif line == idx then
      self:draw_caret(idx, x, y, col)
    end
  end
end


function DocView:draw_line_gutter(idx, x, y, selections)
  if #self.doc.markers >= 1 and self.doc.markers[idx] then
    local h = self:get_line_height()
    renderer.draw_rect(x, y, style.padding.x * 0.4, h, style.selection)
  end
  
  local yoffset = self:get_line_text_y_offset()
  local color = style.line_number
  x = x + style.padding.x
  if not self:is_active_view() then
    return renderer.draw_text(self:get_font(), idx, x, y + yoffset, color)
  end

  if #selections < 1 then
    local line1, _, line2, _ = self.doc:get_selection(true)
    if idx >= line1 and idx <= line2 then
      color = style.line_number2
    end
  else
    for i, d in ipairs(selections) do
      local line1, _, line2, _ = common.sort_positions(table.unpack(d))
      if idx >= line1 and idx <= line2 then
        color = style.line_number2
        break
      end
    end
  end
  renderer.draw_text(self:get_font(), idx, x, y + yoffset, color)
end


function DocView:draw()
  self:draw_background(style.background)

  local font = self:get_font()
  font:set_tab_width(font:get_width(" ") * config.core.indent_size)

  local minline, maxline = self:get_visible_line_range()
  local lh = self:get_line_height()

  local range = self.doc:get_range_selections(minline, maxline)

  if config.core.show_gutter then
    local _, y = self:get_line_screen_position(minline)
    local x = self.position.x
    local rid = 1
    for i = minline, maxline do
      -- too much op(s) unsatisfied as suffering hell...
      self:draw_line_gutter(i, x, y, range)
      y, rid = y + lh, rid +1
    end
  end

  local x, y = self:get_line_screen_position(minline)
  local gw = config.core.show_gutter and self:get_gutter_width() or 0
  local pos = self.position
  
  core.push_clip_rect(pos.x + gw, pos.y, self.size.x, self.size.y)

  for i = minline, maxline do
    self:draw_line_body(i, x, y, range)
    y = y + lh
  end
  
  core.pop_clip_rect()

  self:draw_scrollbar()
end


return DocView
