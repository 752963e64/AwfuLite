local core = require "core"
local Object = require "core.object"
local Highlighter = require "core.doc.highlighter"
local syntax = require "core.syntax"
local config = require "core.config"
local common = require "core.common"


local Doc = Object:extend()

-- markers
local function shift_lines(doc, at, diff)
  if diff == 0 then return end
  local t = {}
  for line in pairs(doc.markers) do
    line = line >= at and line + diff or line
    t[line] = true
  end
  doc.markers = t
end


local function split_lines(text)
  local res = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    table.insert(res, line)
  end
  return res
end


local function splice(t, at, remove, insert)
  insert = insert or {}
  local offset = #insert - remove
  local old_len = #t
  if offset < 0 then
    for i = at - offset, old_len - offset do
      t[i + offset] = t[i]
    end
  elseif offset > 0 then
    for i = old_len, at, -1 do
      t[i + offset] = t[i]
    end
  end
  for i, item in ipairs(insert) do
    t[at + i - 1] = item
  end
end


function Doc:new(filename)
  self:reset()
  if filename then
    self:load(filename)
  end
end


function Doc:reset()
  self.editable = true
  self.tab_mixed = false
  self.lines = { "\n" }
  self.selection = {
    a = { line=1, col=1 },
    b = { line=1, col=1 },
    c = {}, mode = "single" }
  self.undo_stack = { idx = 1 }
  self.redo_stack = { idx = 1 }
  self.clean_change_id = 1
  self.markers = {}
  self.highlighter = Highlighter(self)
  self:reset_syntax()
end


function Doc:reset_syntax()
  local syn = syntax.get(self.filename or "")
  if self.syntax ~= syn then
    self.syntax = syn
    self.highlighter:reset()
  end
end


function Doc:load(filename)
  self.filename = filename
  local fp = assert( io.open(filename, "rb") )
  local sane = true
  for c in fp:lines(1) do
    if c:byte() == 0 then
      sane = false
      break
    end
  end
  if sane then
    fp:seek("set")
  else
    fp:close()
    fp = assert( io.popen( "hexdump -C " .. filename ) )
    self.editable = false
  end
  self:reset()
  self.lines = {}
  for line in fp:lines() do
    if line:byte(-1) == 13 then
      line = line:sub(1, -2)
      self.crlf = true
    end
    table.insert(self.lines, line .. "\n")
  end
  if #self.lines == 0 then
    table.insert(self.lines, "\n")
  end
  fp:close()
  self:reset_syntax()
end


function Doc:save(filename)
  if not self.editable then
    core.log("Can't save hexdump report. use hexdump from your terminal.")
    return
  end
  filename = filename or assert(self.filename, "no filename set to default to")
  local fp = assert( io.open(filename, "wb") )
  for _, line in ipairs(self.lines) do
    if self.crlf then line = line:gsub("\n", "\r\n") end
    fp:write(line)
  end
  fp:close()
  self.filename = filename or self.filename
  self:reset_syntax()
  self:clean()
  core.log("Saved \"%s\"", self.filename)
end


function Doc:get_name()
  return self.filename or "unsaved"
end


function Doc:is_dirty()
  return self.clean_change_id ~= self:get_change_id()
end


function Doc:clean()
  self.clean_change_id = self:get_change_id()
end


function Doc:get_change_id()
  return self.undo_stack.idx
end


function Doc:set_nodup_selections(line1, col1, line2, col2)
  line1, col1 = self:sanitize_position(line1, col1)
  line2, col2 = self:sanitize_position(line2 or line1, col2 or col1)
  for i, d in ipairs(self.selection.c) do
    local l1, c1, l2, c2 = table.unpack(d)
    if l1 == line1 then
      line1 = nil
      break
    end
  end
  if line1 then
    table.insert(self.selection.c, { line1, col1, line2, col2 })
  end
end


function Doc:set_selection_mode(mode)
  if mode and mode ~= self.selection.mode then
    self.selection.mode = mode
  end
end


function Doc:get_selection_mode(mode)
  if mode then
    return self.selection.mode == mode
  else
    return self.selection.mode
  end
end


function Doc:set_selections(line1, col1, line2, col2, swap, idx)
  assert(not line2 == not col2, "expected 2 or 4 arguments")
  if swap then line1, col1, line2, col2 = line2, col2, line1, col1 end
  line1, col1 = self:sanitize_position(line1, col1)
  line2, col2 = self:sanitize_position(line2 or line1, col2 or col1)
  if idx then self.selection.c[idx] = { line1, col1, line2, col2 } else
  table.insert(self.selection.c, { line1, col1, line2, col2 }) end
end


function Doc:set_selection(line1, col1, line2, col2, swap)
  assert(not line2 == not col2, "expected 2 or 4 arguments")
  if swap then line1, col1, line2, col2 = line2, col2, line1, col1 end
  line1, col1 = self:sanitize_position(line1, col1)
  line2, col2 = self:sanitize_position(line2 or line1, col2 or col1)
  self.selection.a.line, self.selection.a.col = line1, col1
  self.selection.b.line, self.selection.b.col = line2, col2
end


function Doc:remove_last_selections()
  self.selection.c[#self.selection.c] = nil
end

-- o = { }
-- 6 1 6 1
-- 8 1 8 1
-- 13  2 13  2
-- 21  7 21  7
-- 23  8 23  16
-- 23  20  23  29
-- 24  16  24  20
-- 25  10  28  6
-- 31  13  31  13
-- 30  11  30  5
-- 35  9 35  13
-- 2 4 2 4
function Doc:get_range_selections(minline, maxline)
  local range = {}
  if #self.selection.c >= 1 then
    for i, s in ipairs(self:get_selections()) do
      if ( s[1] >= minline and s[1] <= maxline ) or
        ( s[3] >= minline and s[3] <= maxline ) then
        table.insert(range, { s[1], s[2], s[3], s[4] })
      end
    end
  end
  return range
end


function Doc:get_last_selections(sort)
  local s = #self.selection.c
  local line, col, line1, col1 = table.unpack(self.selection.c[s])
  if sort then
    line, col, line1, col1 = common.sort_positions(line, col, line2, col2)
  end
  return line, col, line1, col1
end


function Doc:get_first_selections(sort)
  local line, col, line1, col1 = table.unpack(self.selection.c[1])
  if sort then
    line, col, line1, col1 = common.sort_positions(line, col, line2, col2)
  end

  return line, col, line1, col1
end


function Doc:get_selections(sort)
  if sort then
    local selections = {}
    for i, d in ipairs(self.selection.c) do
      local line1, col1, line2, col2 = table.unpack(d)
      table.insert(selections, { common.sort_positions(line1, col1, line2, col2) })
    end
    return selections
  end
  return self.selection.c
end


function Doc:get_selection(sort)
  local a, b = self.selection.a, self.selection.b
  if sort then
    return common.sort_positions(a.line, a.col, b.line, b.col)
  end
  return a.line, a.col, b.line, b.col
end


function Doc:has_selection(l1, c1, l2, c2)
  if l1 then -- used for multiselection
    return not (l1 == l2 and c1 == c2)
  end
  
  if self.selection.mode == "ctrl" or
    self.selection.mode == "shift" then
    for i,t in ipairs(self.selection.c) do
      if not (t[1] == t[3] and t[2] == t[4]) then
        return true
      end
    end
  end

  local a, b = self.selection.a, self.selection.b
  return not (a.line == b.line and a.col == b.col)
end


function Doc:sanitize_selection()
  if #self.selection.c < 1 then
    self:set_selection(self:get_selection())
  end
end


function Doc:sanitize_position(line, col)
  line = common.clamp(line, 1, #self.lines)
  col = common.clamp(col, 1, #self.lines[line])
  return line, col
end


local function position_offset_func(self, line, col, fn, ...)
  line, col = self:sanitize_position(line, col)
  return fn(self, line, col, ...)
end


local function position_offset_byte(self, line, col, offset)
  line, col = self:sanitize_position(line, col)
  col = col + offset
  while line > 1 and col < 1 do
    line = line - 1
    col = col + #self.lines[line]
  end
  while line < #self.lines and col > #self.lines[line] do
    col = col - #self.lines[line]
    line = line + 1
  end
  return self:sanitize_position(line, col)
end


local function position_offset_linecol(self, line, col, lineoffset, coloffset)
  return self:sanitize_position(line + lineoffset, col + coloffset)
end


function Doc:position_offset(line, col, ...)
  if type(...) ~= "number" then
    return position_offset_func(self, line, col, ...)
  elseif select("#", ...) == 1 then
    return position_offset_byte(self, line, col, ...)
  elseif select("#", ...) == 2 then
    return position_offset_linecol(self, line, col, ...)
  else
    error("bad number of arguments")
  end
end


function Doc:get_text(line1, col1, line2, col2)
  line1, col1 = self:sanitize_position(line1, col1)
  line2, col2 = self:sanitize_position(line2, col2)
  line1, col1, line2, col2 = common.sort_positions(line1, col1, line2, col2)
  if line1 == line2 then
    return self.lines[line1]:sub(col1, col2 - 1)
  end
  local lines = { self.lines[line1]:sub(col1) }
  for i = line1 + 1, line2 - 1 do
    table.insert(lines, self.lines[i])
  end
  table.insert(lines, self.lines[line2]:sub(1, col2 - 1))
  return table.concat(lines)
end

-- is this unicode resistant?
function Doc:get_char(line, col)
  line, col = self:sanitize_position(line, col)
  return self.lines[line]:sub(col, col)
end


local function push_undo(undo_stack, time, type, ...)
  undo_stack[undo_stack.idx] = { type = type, time = time, ... }
  undo_stack[undo_stack.idx - config.core.max_undos] = nil
  undo_stack.idx = undo_stack.idx + 1
end


local function pop_undo(self, undo_stack, redo_stack)
  -- pop command
  local cmd = undo_stack[undo_stack.idx - 1]
  if not cmd then return end
  undo_stack.idx = undo_stack.idx - 1

  -- handle command
  if cmd.type == "insert" then
    local line, col, text = table.unpack(cmd)
    self:raw_insert(line, col, text, redo_stack, cmd.time)
  elseif cmd.type == "remove" then
    local line1, col1, line2, col2 = table.unpack(cmd)
    self:raw_remove(line1, col1, line2, col2, redo_stack, cmd.time)
  elseif cmd.type == "selection" then
    if #self.selection.c >= 1 then
      for i, d in ipairs(self.selection.c) do
        local line = table.unpack(d)
        if line == cmd[1] then
          self.selection.c[i] = { cmd[1], cmd[2], cmd[3], cmd[4] }
        end
      end
    else
      self.selection.a.line, self.selection.a.col = cmd[1], cmd[2]
      self.selection.b.line, self.selection.b.col = cmd[3], cmd[4]
    end
  end

  -- if next undo command is within the merge timeout then treat as a single
  -- command and continue to execute it
  local next = undo_stack[undo_stack.idx - 1]
  if next and math.abs(cmd.time - next.time) < config.core.undo_merge_timeout then
    return pop_undo(self, undo_stack, redo_stack)
  end
end


function Doc:raw_insert(line, col, text, undo_stack, time)
  -- split text into lines and merge with line at insertion point
  local lines = split_lines(text)
  local before = self.lines[line]:sub(1, col - 1)
  local after = self.lines[line]:sub(col)
  for i = 1, #lines - 1 do
    lines[i] = lines[i] .. "\n"
  end
  lines[1] = before .. lines[1]
  lines[#lines] = lines[#lines] .. after

  -- splice lines into line array
  splice(self.lines, line, 1, lines)

  -- push undo
  local line2, col2 = self:position_offset(line, col, #text)
  push_undo(undo_stack, time, "selection", line, col, line, col)
  push_undo(undo_stack, time, "remove", line, col, line2, col2)

  -- update highlighter and assure selection is in bounds
  self.highlighter:invalidate(line)
  self:sanitize_selection()

  -- markers
  local line_count = 0
  for _ in text:gmatch("\n") do
    line_count = line_count + 1
  end
  shift_lines(self, line, line_count)
end


function Doc:raw_remove(line1, col1, line2, col2, undo_stack, time)
  -- push undo
  local text = self:get_text(line1, col1, line2, col2)

  push_undo(undo_stack, time, "selection", line1, col1, line1, col1)
  push_undo(undo_stack, time, "insert", line1, col1, text)

  -- get line content before/after removed text
  local before = self.lines[line1]:sub(1, col1 - 1)
  local after = self.lines[line2]:sub(col2)

  -- splice line into line array
  splice(self.lines, line1, line2 - line1 + 1, { before .. after })

  -- update highlighter and assure selection is in bounds
  self.highlighter:invalidate(line1)
  -- if #self.selection.c == 0 then self:sanitize_selection() end

  -- markers
  shift_lines(self, line2, line1 - line2)
end


function Doc:insert(line, col, text)
  if not self.editable then
    return
  end
  self.redo_stack = { idx = 1 }
  line, col = self:sanitize_position(line, col)
  self:raw_insert(line, col, text, self.undo_stack, system.get_time())
end


function Doc:remove(line1, col1, line2, col2)
  self.redo_stack = { idx = 1 }
  line1, col1 = self:sanitize_position(line1, col1)
  line2, col2 = self:sanitize_position(line2, col2)
  line1, col1, line2, col2 = common.sort_positions(line1, col1, line2, col2)
  self:raw_remove(line1, col1, line2, col2, self.undo_stack, system.get_time())
end


function Doc:undo()
  pop_undo(self, self.undo_stack, self.redo_stack)
end


function Doc:redo()
  pop_undo(self, self.redo_stack, self.undo_stack)
end


function Doc:text_input(text)
  if not self.editable then
    return
  end
  if self:has_selection() then
    self:delete_to()
  end
  if #self.selection.c >= 1 then
    for i = #self.selection.c, 1, -1 do
      local line1, col1 = table.unpack(self.selection.c[i])
      self:insert(line1, col1, text)
      if text == "\n" then
        line1 = line1+i
        self.selection.c[i] = { line1, 1, line1, 1 }
      else
        self.selection.c[i] = { line1, col1+#text, line1, col1+#text }
      end
    end
  else
    local line, col = self:get_selection()
    self:insert(line, col, text)
    self:move_to(#text)
  end
end


function Doc:replace(fn)
  local line1, col1, line2, col2, swap
  local had_selection = self:has_selection()
  if had_selection then
    line1, col1, line2, col2, swap = self:get_selection(true)
  else
    line1, col1, line2, col2 = 1, 1, #self.lines, #self.lines[#self.lines]
  end
  local old_text = self:get_text(line1, col1, line2, col2)
  local new_text, n = fn(old_text)
  if old_text ~= new_text then
    self:insert(line2, col2, new_text)
    self:remove(line1, col1, line2, col2)
    if had_selection then
      line2, col2 = self:position_offset(line1, col1, #new_text)
      self:set_selection(line1, col1, line2, col2, swap)
    end
  end
  return n
end


function Doc:delete_to(...)
  if #self.selection.c >= 1 then
      --local line2, col2 = self:position_offset(...)
    self:remove(...)
      --local line,col = common.sort_positions(...)
      --self:set_selections(line, col)
    -- end
  else
    local line, col = self:get_selection(true)
    if self:has_selection() then
      self:remove(self:get_selection())
    else
      local line2, col2 = self:position_offset(line, col, ...)
      self:remove(line, col, line2, col2)
      line, col = common.sort_positions(line, col, line2, col2)
    end
    self:set_selection(line, col)
  end
end


function Doc:move_to(...)
  if #self.selection.c < 1 then
    local line, col = self:get_selection()
    self:set_selection(self:position_offset(line, col, ...))
  else
    local lines = self:get_selections()
    self.selection.c = {}
    for i, d in ipairs(lines) do
      local line, col = table.unpack(d)
      self:set_selections(self:position_offset(line, col, ...))
    end
  end
end


function Doc:select_to(...)
  local line, col, line2, col2 = self:get_selection()
  line, col = self:position_offset(line, col, ...)
  self:set_selection(line, col, line2, col2)
end


return Doc
