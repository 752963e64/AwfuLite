local core = require "core"
local keymap = require "core.keymap"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local View = require "core.view"

config.dprint("console.lua -> loaded")


local uid = os.tmpname():gsub("%W", "")


local files = {
  script   = EXEDIR .. "/.lite_console_" .. uid .. "_script",
  script2  = EXEDIR .. "/.lite_console_" .. uid .. "_script2",
  output   = EXEDIR .. "/.lite_console_" .. uid .. "_output",
  complete = EXEDIR .. "/.lite_console_" .. uid .. "_complete",
}


local function clean_up()
  for _, file in pairs(files) do
    os.remove(file)
  end
end
clean_up()


local exit = os.exit
os.exit = function(...) clean_up() return exit(...) end


local console = {}


-- local views = {}
local pending_threads = {}
local thread_active = false
local output = { { text = "", time = os.time() } }
local output_id = 0


local function read_file(filename, offset)
  local fp = io.open(filename, "rb")
  fp:seek("set", offset or 0)
  local res = fp:read("*a")
  fp:close()
  return res
end


local function write_file(filename, text)
  local fp = io.open(filename, "w")
  fp:write(text)
  fp:close()
end


local function lines(text)
  return (text .. "\n"):gmatch("(.-)\n")
end


local function push_output(str, opt)
  local first = true
  for line in lines(str) do
    if first then
      line = table.remove(output).text .. line
    end
    line = line:gsub("\x1b%[[%d;]+m", "") -- strip ANSI colors
    table.insert(output, {
      text = line,
      time = os.time(),
      icon = line:find(opt.error_pattern) and style.icons["attention"]
          or line:find(opt.warning_pattern) and style.icons["info-circled"],
      file_pattern = opt.file_pattern,
    })
    if #output > config.console.max_lines then
      table.remove(output, 1)
    end
    first = false
  end
  output_id = output_id + 1
  core.redraw = true
end


local function init_opt(opt)
  local res = {
    command = "",
    file_pattern = "[^?:%s]+%.[^?:%s]+",
    error_pattern = "error",
    warning_pattern = "warning",
    on_complete = function() end,
  }
  for k, v in pairs(res) do
    res[k] = opt[k] or v
  end
  return res
end


function console.run(opt)
  opt = init_opt(opt)

  local function thread()
    -- init script file(s)
    write_file(files.script, string.format([[
      %s
      touch %q
    ]], opt.command, files.complete))
    os.execute(string.format("sh %q >%q 2>&1 &", files.script, files.output))

    -- checks output file for change and reads
    local last_size = 0
    local function check_output_file()
      local info = system.get_file_info(files.output)
      if info and info.size > last_size then
        local text = read_file(files.output, last_size)
        push_output(text, opt)
        last_size = info.size
      end
    end

    -- read output file until we get a file indicating completion
    while not system.get_file_info(files.complete) do
      check_output_file()
      coroutine.yield(0.1)
    end
    check_output_file()
    push_output("!DIVIDER\n", opt)

    -- clean up and finish
    clean_up()
    opt.on_complete()

    -- handle pending thread
    local pending = table.remove(pending_threads, 1)
    if pending then
      core.add_thread(pending)
    else
      thread_active = false
    end
  end

  -- push/init thread
  if thread_active then
    table.insert(pending_threads, thread)
  else
    core.add_thread(thread)
    thread_active = true
  end
end

local ConsoleView = View:extend()

function ConsoleView:new()
  ConsoleView.super.new(self)
  self.scrollable = true
  self.hovered_idx = -1
  self.focusable = false
  self.height = config.console.size
  self.visible = config.console.visible
end


function ConsoleView:get_name()
  return "---"
end


function ConsoleView:get_font()
  return style.xft.mono_regular
end


function ConsoleView:get_line_height()
  return self.get_font():get_height() * config.core.line_height
end


function ConsoleView:get_line_count()
  return #output - (output[#output].text == "" and 1 or 0)
end


function ConsoleView:get_scrollable_size()
  return self:get_line_count() * self:get_line_height() + style.padding.y * 2
end


function ConsoleView:get_visible_line_range()
  local lh = self:get_line_height()
  local min = math.max(1, math.floor(self.scroll.y / lh))
  return min, min + math.floor(self.size.y / lh) + 1
end


function ConsoleView:on_mouse_moved(mx, my, ...)
  if self.cursor ~= "arrow" then
    self.cursor = "arrow"
  end

  self.hovered_idx = 0
  if not self.visible or my < core.active_view.size.y then
    return
  end
  for i, item, x,y,w,h in self:each_visible_line() do
    if mx >= x and my >= y and mx < x + w and my < y + h then
      if item.text:find(item.file_pattern) then
        self.hovered_idx = i
      end
      break
    end
  end
end


local function resolve_file(name)
  if system.get_file_info(name) then
    return name
  end
  local filenames = {}
  for _, f in ipairs(core.project_files) do
    table.insert(filenames, f.filename)
  end
  local t = common.fuzzy_match(filenames, name)
  return t[1]
end


function ConsoleView:on_line_removed()
  local diff = self:get_line_height()
  self.scroll.y = self.scroll.y - diff
  self.scroll.to.y = self.scroll.to.y - diff
end


function ConsoleView:on_mouse_pressed(...)
  local item = output[self.hovered_idx]
  if item then
    local file, line, col = item.text:match(item.file_pattern)
    local resolved_file = resolve_file(file)
    if not resolved_file then
      core.error("Couldn't resolve file \"%s\"", file)
      return
    end
    core.try(function()
      local dv = core.root_view:open_doc(core.open_doc(resolved_file))
      if line then
        dv.doc:set_selection(line, col or 0)
        dv:scroll_to_line(line, false, true)
      end
    end)
  end
end


function ConsoleView:each_visible_line()
  return coroutine.wrap(function()
    local x, y = self:get_content_offset()
    local lh = self:get_line_height()
    local min, max = self:get_visible_line_range()
    y = y + lh * (min - 1) + style.padding.y
    max = math.min(max, self:get_line_count())

    for i = min, max do
      local item = output[i]
      if not item then break end
      coroutine.yield(i, item, x, y, self.size.x, lh)
      y = y + lh
    end
  end)
end


function ConsoleView:update(...)
  if self.last_output_id ~= output_id then
    self.scroll.to.y = self:get_scrollable_size()
    self.last_output_id = output_id
  end

  local dest = self.visible and self.height or 0
  self:move_towards(self.size, "y", dest)

  ConsoleView.super.update(self)
end


function ConsoleView:draw()
  self:draw_background(style.background)
  local icon_w = style.xft.icon:get_width(style.icons["attention"])

  for i, item, x, y, w, h in self:each_visible_line() do
    local tx = x + style.padding.x
    local time = os.date("%H:%M:%S", item.time)
    local color = style.text
    local xft = self.get_font()
    if self.hovered_idx == i then
      color = style.accent
      renderer.draw_rect(x, y, w, h, style.line_highlight)
    end
    if item.text == "!DIVIDER" then
      local w = xft:get_width(time)
      renderer.draw_rect(tx, y + h / 2, w, math.ceil(SCALE * 1), style.dim)
    else
      tx = common.draw_text(xft, style.dim, time, "left", tx, y, w, h)
      tx = tx + style.padding.x
      if item.icon then
        common.draw_text(style.xft.icon, color, item.icon, "left", tx, y, w, h)
      end
      tx = tx + icon_w + style.padding.x
      common.draw_text(xft, color, item.text, "left", tx, y, w, h)
    end
  end

  self:draw_scrollbar(self)
end


-- init static bottom-of-screen console
local view = ConsoleView()
local node = core.root_view:get_active_node()
node:split("down", view, true)

local last_command = ""

command.add(nil, {
  -- toggle builtin console
  ["console:toggle"] = function()
    view.visible = not view.visible
  end,

  ["console:run"] = function()
    core.command_view:set_text(last_command, true)
    core.command_view:enter("Run Console Command", function(cmd)
      console.run { command = cmd }
      last_command = cmd
      if not view.visible then
        command.perform("console:toggle")
      end
    end)
  end
})

