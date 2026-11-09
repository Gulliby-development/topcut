-- The command line: help, version, the option rules, the reading of the list and the call of the command.
local registry = require("topcut.registry")
local input = require("topcut.input")

local M = {}

local RANGES = {
  ["--k"] = { 1, 32 },
  ["--p"] = { 1, 1000 },
  ["--ratio"] = { 0, 1000 },
  ["--at"] = { 0, 999999999 },
}

local STEP_OPTIONS = { topk = "--k", topp = "--p", minp = "--ratio" }

local function contains(list, word)
  for _, item in ipairs(list) do
    if item == word then
      return true
    end
  end
  return false
end

-- A whole number in the range of the option, or nil.
local function whole(text, option)
  local range = RANGES[option]
  if not text:match("^%d+$") then
    return nil
  end
  if #text > 1 and text:sub(1, 1) == "0" then
    return nil
  end
  if #text > #tostring(range[2]) then
    return nil
  end
  local n = math.tointeger(tonumber(text))
  if n < range[1] or n > range[2] then
    return nil
  end
  return n
end

local function valid_steps(text)
  local count = 0
  local pos = 1
  while true do
    local comma = text:find(",", pos, true)
    local step = text:sub(pos, (comma or (#text + 1)) - 1)
    count = count + 1
    if count > 4 then
      return false
    end
    local name, value = step:match("^(%a+):(.*)$")
    local option = name and STEP_OPTIONS[name]
    if not option or not whole(value, option) then
      return false
    end
    if not comma then
      return true
    end
    pos = comma + 1
  end
end

-- The value of an option from its text, or nil when the text is bad.
local function convert(option, text)
  if option == "--format" then
    return contains(registry.FORMATS, text) and text or nil
  elseif option == "--unit" then
    return registry.UNITS[text] and text or nil
  elseif option == "--steps" then
    return valid_steps(text) and text or nil
  end
  return whole(text, option)
end

local function fail_reply(message)
  return { status = 2, out = "", err = "topcut: " .. message .. "\n" }
end

-- Returns { entry, options } for a valid command line, or a reply table.
local function parse(args)
  local first = args[1]
  if first == nil then
    return { status = 2, out = "", err = registry.USAGE }
  end
  if first == "help" or first == "-h" or first == "--help" then
    return { status = 0, out = registry.USAGE, err = "" }
  end
  if first == "--version" then
    return { status = 0, out = registry.VERSION .. "\n", err = "" }
  end
  local entry
  for _, command in ipairs(registry.COMMANDS) do
    if command.name == first then
      entry = command
    end
  end
  if not entry then
    return fail_reply("unknown command " .. first)
  end
  local options = { format = "plain", unit = "permille" }
  local seen = {}
  local i = 2
  while i <= #args do
    local word = args[i]
    if word == "" or word == "-" or word:sub(1, 1) ~= "-" then
      return fail_reply("unexpected argument " .. word)
    end
    if not contains(registry.OPTIONS, word) then
      return fail_reply("unknown option " .. word)
    end
    if not contains(entry.options, word) then
      return fail_reply("option " .. word .. " is not valid for " .. entry.name)
    end
    if seen[word] then
      return fail_reply("given twice: " .. word)
    end
    seen[word] = true
    if i == #args then
      return fail_reply("missing value for " .. word)
    end
    local value = convert(word, args[i + 1])
    if value == nil then
      return fail_reply("bad value for " .. word)
    end
    options[word:sub(3)] = value
    i = i + 2
  end
  if entry.required ~= "" and not seen[entry.required] then
    return fail_reply("missing " .. entry.required)
  end
  return { entry = entry, options = options }
end

function M.reads_stdin(args)
  return parse(args).entry ~= nil
end

function M.run(args, stdin)
  local parsed = parse(args)
  if not parsed.entry then
    return parsed
  end
  local ok, result = pcall(function()
    local items = input.read_candidates(stdin)
    local module = require(parsed.entry.module)
    return module[parsed.entry.handler](parsed.options, items)
  end)
  if ok then
    return result
  end
  if type(result) == "table" and result.status and result.message then
    return { status = result.status, out = "", err = "topcut: " .. result.message .. "\n" }
  end
  error(result, 0)
end

return M
