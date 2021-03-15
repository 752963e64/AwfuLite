local config = require "core.config"

config.dprint("tokenizer.lua -> loaded")


local tokenizer = {}


local function push_token(t, type, text)
  local prev_type = t[#t-1]
  local prev_text = t[#t]
  -- if prev_type and (prev_type == type or prev_text:find("^%s*$")) then
  if prev_type and prev_type == type then
    t[#t-1] = type
    t[#t] = prev_text .. text
  else
    table.insert(t, type)
    table.insert(t, text)
  end
end


local function is_escaped(text, idx, esc)
  local byte = esc:byte()
  local count = 0
  for i = idx - 1, 1, -1 do
    if text:byte(i) ~= byte then break end
    count = count + 1
  end
  return count % 2 == 1
end


local function find_non_escaped(text, pattern, offset, esc)
  while true do
    local s, e = text:find(pattern, offset)
    if not s then break end
    if esc and is_escaped(text, s, esc) then
      offset = e + 1
    else
      return s, e
    end
  end
end


local function tokenize(res, text, type)
  if config.core.show_spaces then
    local si, v = 1, "·"
    while si <= #text do
      local ss, se = text:find("^[ \t]+", si)
      if ss then
        se = se + 1
        push_token(res, "tab", v:rep(se-ss))
        si = se
      else
        local ss, se = text:find("^[\x21-\x7f\xc2-\xf4][\x80-\xbf]*", si)
        if ss then
          push_token(res, type, text:sub(ss,se))
          si = se + 1
        else
          si = si + 1
        end
      end
    end
  else
    push_token(res, type, text)
  end
end

function tokenizer.tokenize(syntax, text, state)
  local res, i = {}, 1

  if #syntax.patterns == 0 then
    return { "normal", text }
  end

  while i <= #text do
    -- continue trying to match the end pattern of a pair if we have a state set
    if state then
      local p = syntax.patterns[state]
      local s, e = find_non_escaped(text, p.pattern[2], i, p.pattern[3])

      if s then
        tokenize(res, text:sub(i, e), p.type)
        state = nil
        i = e + 1
      else
        tokenize(res, text:sub(i), p.type)
        break
      end
    end

    -- find matching pattern
    local matched = false

    for n, p in ipairs(syntax.patterns) do
      local pattern = (type(p.pattern) == "table") and p.pattern[1] or p.pattern
      local s, e = text:find("^" .. pattern, i)

      if s then
        -- matched pattern; make and add token
        local t = text:sub(s, e)
        tokenize(res, t, syntax.symbols[t] or p.type)

        -- update state if this was a start|end pattern pair
        if type(p.pattern) == "table" then
          state = n
        end

        -- move cursor past this token
        i = e + 1
        matched = true
        break
      end
    end

    -- consume character if we didn't match
    if not matched then
      tokenize(res, text:sub(i, i), "normal")
      i = i + 1
    end
  end

  return res, state
end


local function iter(t, i)
  i = i + 2
  local type, text = t[i], t[i+1]
  if type then
    return i, type, text
  end
end

function tokenizer.each_token(t)
  return iter, t, -1
end


return tokenizer
