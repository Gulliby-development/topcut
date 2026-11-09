-- The reading of the list of candidates.
local registry = require("topcut.registry")

local M = {}

local function split_lines(text)
  local lines = {}
  local pos = 1
  while pos <= #text do
    local nl = text:find("\n", pos, true)
    local line
    if nl then
      line = text:sub(pos, nl - 1)
      pos = nl + 1
    else
      line = text:sub(pos)
      pos = #text + 1
    end
    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end
    lines[#lines + 1] = line
  end
  return lines
end

local function is_token(word)
  return #word >= 1 and #word <= 12 and word:match("^[A-Za-z0-9_.%-]+$") ~= nil
end

local function is_weight(word)
  return word == "0" or (#word <= 6 and word:match("^[1-9]%d*$") ~= nil)
end

function M.read_candidates(stdin)
  local lines = split_lines(stdin)
  if #lines > registry.MAX_LINES then
    registry.fail(1, "input is too long (max " .. registry.MAX_LINES .. " lines)")
  end
  local items = {}
  local seen = {}
  local total = 0
  for n, line in ipairs(lines) do
    local words = {}
    for w in line:gmatch("[^ \t]+") do
      words[#words + 1] = w
    end
    if #words > 0 and words[1]:sub(1, 1) ~= "#" then
      local prefix = "line " .. n .. ": "
      if #words ~= 2 then
        registry.fail(1, prefix .. "expected TOKEN WEIGHT")
      end
      local token, weight = words[1], words[2]
      if not is_token(token) then
        registry.fail(1, prefix .. "bad token " .. token)
      end
      if not is_weight(weight) then
        registry.fail(1, prefix .. "bad weight " .. weight)
      end
      if seen[token] then
        registry.fail(1, prefix .. "duplicate token " .. token)
      end
      seen[token] = true
      local value = math.tointeger(tonumber(weight))
      items[#items + 1] = { token = token, weight = value }
      total = total + value
    end
  end
  if #items == 0 then
    registry.fail(1, "no candidates")
  end
  if total == 0 then
    registry.fail(1, "total weight is zero")
  end
  return items
end

return M
