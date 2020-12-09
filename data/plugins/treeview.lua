local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"
local style = require "core.style"
local View = require "core.view"


config.dprint("treeview.lua -> loaded")


local mimetypes = {
  code = { "%.c$", "%.h$", "%.inl$", "%.cpp$", "%.hpp$",
  "%.sh$", "%.rc$", "%.lua$", "%.js$", "%.css$", "%.html?$", "%.md$",
  "%.py$", "%.xml$", "%.pl$" },
  video = { "%.avi$", "%.mov$", "%.mp4$" },
  audio = { "%.mp3$", "%.wma$", "%.ogg$" },
  pdf = { "%.pdf$" },
  image = { "%.ico$", "%.png$", "%.jpe?g$", "%.gif$" },
  archive = { "%.tar$", "%.[gx]z$", "%.bz2?$", "%.zip$" },
}


local function get_depth(filename)
  local n = 0
  for sep in filename:gmatch("[\\/]") do
    n = n + 1
  end
  return n
end


local TreeView = View:extend()


function TreeView:new()
  TreeView.super.new(self)
  self.scrollable = true
  self.init_size = true
  self.visible = config.treeview.visible
  self.width = config.treeview.size
  self.cache = {}
  self._update = nil
  self.visible_item = 0
end


function TreeView:get_name()
  return "Treeview"
end


function TreeView:get_font()
  return style.xft.mono_bold
end


function TreeView:get_cached(item)
  local t = self.cache[item.filename]

  if not t then
    t = {}
    t.filename = item.filename
    t.abs_filename = system.absolute_path(item.filename)
    t.name = t.filename:match("[^\\/]+$")
    t.depth = get_depth(t.filename)
    t.type = item.type
    if t.type == "file" then
      if common.matches_ext(t.name, mimetypes.code) then
        t.icon = style.icons["file-code"]
      elseif common.matches_ext(t.name, mimetypes.video) then
        t.icon = style.icons["file-video"]
      elseif common.matches_ext(t.name, mimetypes.audio) then
        t.icon = style.icons["file-audio"]
      elseif common.matches_ext(t.name, mimetypes.pdf) then
        t.icon = style.icons["file-pdf"]
      elseif common.matches_ext(t.name, mimetypes.image) then
        t.icon = style.icons["file-image"]
      elseif common.matches_ext(t.name, mimetypes.archive) then
        t.icon = style.icons["file-archive"]
      else
        t.icon = style.icons["doc-text"]
      end
    end
    self.cache[t.filename] = t
  end

  return t
end


function TreeView:get_item_height()
  return self:get_font():get_height() + style.padding.y
end


function TreeView:get_scrollable_size()
  return self:get_item_height() * (self.visible_item + 1)
end


function TreeView:check_cache()
  -- invalidate cache's skip values if project_files has changed
  if core.project_files ~= self.last_project_files then
    for _, v in pairs(self.cache) do
      v.skip = nil
    end
    self.last_project_files = core.project_files
  end
end


function TreeView:each_item()
  if self._update then self.visible_item = 0 end
  return coroutine.wrap(function()
    self:check_cache()
    local ox, oy = self:get_content_offset()
    local y = oy + style.padding.y
    local w = self.size.x
    local h = self:get_item_height()
    local i = 1
    while i <= #core.project_files do
      local item = core.project_files[i]
      local cached = self:get_cached(item)

      coroutine.yield(cached, ox, y, w, h)
      y = y + h
      i = i + 1

      if self._update then
        self.visible_item = self.visible_item + 1
      end

      if not cached.expanded then
        if cached.skip then
          i = cached.skip
        else
          local depth = cached.depth
          while i <= #core.project_files do
            local filename = core.project_files[i].filename
            if get_depth(filename) <= depth then break end
            i = i + 1
          end
          cached.skip = i
        end
      end -- not expand
    end -- loop project_files
    self._update = nil
  end) -- coroutine
end


function TreeView:on_mouse_moved(px, py)
  self.hovered_item = nil
  for item, x,y,w,h in self:each_item() do
    if px > x and py > y and px <= x + w and py <= y + h then
      self.hovered_item = item
      break
    end
  end
end


function TreeView:on_mouse_pressed(button, x, y, clicks)
  if button == "left" then
    self._update = true
    if not self.hovered_item then
      return
    elseif self.hovered_item.type == "dir" then
      self.hovered_item.expanded = not self.hovered_item.expanded
      if core.last_active_view then
        core.set_active_view(core.last_active_view)
      end
    else -- open file...
      core.try(function()
        core.root_view:open_doc(core.open_doc(self.hovered_item.filename))
      end)
    end
  end
end


function TreeView:update(...)
  local dest = self.visible and self.width or 0
  if self.init_size then
    self.size.x = dest
    self.init_size = false
  else
    self:move_towards(self.size, "x", dest)
  end

  TreeView.super.update(self)
end


function TreeView:draw()
  self:draw_background(style.background2)
  local icon_width = style.xft.icon:get_width(style.icons["folder-open"])
  local spacing = style.xft.mono_bold:get_width(" ") * 2

  local doc = core.active_view.doc
  local active_filename = doc and system.absolute_path(doc.filename or "")

  for item, x,y,w,h in self:each_item() do
    local color = style.text

    -- highlight active_view doc
    if item.abs_filename == active_filename then
      color = style.accent
    end

    -- hovered item background
    if item == self.hovered_item then
      renderer.draw_rect(x, y, w, h, style.line_highlight)
      color = style.accent
    end

    -- icons
    x = x + item.depth * style.padding.x + style.padding.x
    if item.type == "dir" then
      local icon1 = item.expanded and style.icons["fold-open"] or style.icons["fold-close"]
      local icon2 = item.expanded and style.icons["folder-open"] or style.icons["folder-close"]
      common.draw_text(style.xft.icon, color, icon1, nil, x, y, 0, h)
      x = x + style.padding.x
      common.draw_text(style.xft.icon, color, icon2, nil, x, y, 0, h)
      x = x + icon_width
    else
      x = x + style.padding.x
      common.draw_text(style.xft.icon, color, item.icon, nil, x, y, 0, h)
      x = x + icon_width
    end

    -- text
    x = x + spacing
    x = common.draw_text(style.xft.mono_bold, color, item.name, nil, x, y, 0, h)
  end
end


-- init
local view = TreeView()
local node = core.root_view:get_active_node()
node:split("left", view, true)

-- register commands and keymap
command.add(nil, {
  ["treeview:toggle"] = function()
    view.visible = not view.visible
  end,
  ["treeview:larger"] = function()
    if not view.init_size then
      view.init_size = true
    end
    view.width = view.width + 10
  end,
  ["treeview:smaller"] = function()
    if not view.init_size then
      view.init_size = true
    end
    view.width = view.width - 10
  end
})

