local core = require "core"
local common = require "core.common"
local command = require "core.command"
local io = require "io"

local function gititup(string)
  local git = io.popen(string)
  local ret = ""
  for line in git:lines() do
    ret = ret .. line
  end
  git:close()
  return ret
end


command.add(nil, {
  ["git:init"] = function()
    local git = gititup("git init")
    if #git > 0 then
      core.log(git)
    end
  end,

  ["git:add"] = function()
    core.command_view:enter("Git add", function(text)
      local git = gititup("git add " .. text)
      if #git > 0 then
        core.log(git)
      end
    end, common.path_suggest)
  end,

  ["git:pull"] = function()
    core.command_view:enter("Git pull", function(text)
      local git = gititup("git pull " .. text)
      if #git > 0 then
        core.log(git)
      end
    end)
  end,

  ["git:commit"] = function()
    core.command_view:enter("Git commit", function(text)
      local git = gititup("git commit -m \"" .. text .. "\"")
      if #git > 0 then
        core.log(git)
      end
    end)
  end,
})
