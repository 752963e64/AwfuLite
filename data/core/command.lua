local core = require "core"
local config = require "core.config"


config.dprint("command.lua -> loaded")


local command = {}
command.map = {}


local always_true = function() return true end


function command.add(predicate, map)
  predicate = predicate or always_true
  if type(predicate) == "string" then
    predicate = require(predicate)
  end
  if type(predicate) == "table" then
    local class = predicate
    predicate = function() return core.active_view:is(class) end
  end
  for name, fn in pairs(map) do
    if not command.map[name] then
    -- assert(not command.map[name], "command already exists: " .. name)
      command.map[name] = { predicate = predicate, perform = fn }
    else
      print( "command already exists: " .. name )
    end
  end
end


local function capitalize_first(str)
  return str:sub(1, 1):upper() .. str:sub(2)
end


function command.prettify_name(name)
  return name:gsub(":", ": "):gsub("-", " "):gsub("%S+", capitalize_first)
end


function command.get_all_valid()
  local res = {}
  for name, cmd in pairs(command.map) do
    if cmd.predicate() then
      table.insert(res, name)
    end
  end
  return res
end


local function perform(name)
  local cmd = command.map[name]
  if cmd and cmd.predicate() then
    cmd.perform()
    return true
  end
  return false
end


function command.perform(...)
  local ok, res = core.try(perform, ...)
  return not ok or res
end


function command.add_defaults()
  local reg = { "core", "root", "command", "doc", "find", "module" }
  for _, name in ipairs(reg) do
    require("core.commands." .. name)
  end
end


return command
