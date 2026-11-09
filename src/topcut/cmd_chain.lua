-- The chain command: topk, topp and minp steps applied in order over the ranking.
local rank = require("topcut.rank")
local report = require("topcut.report")

local M = {}

local function apply_topk(left, n)
  local kept = {}
  for i = 1, math.min(n, #left) do
    kept[i] = left[i]
  end
  return kept
end

local function apply_topp(left, p)
  local total = 0
  for _, item in ipairs(left) do
    total = total + item.weight
  end
  local kept = {}
  local sum = 0
  for _, item in ipairs(left) do
    sum = sum + item.weight
    kept[#kept + 1] = item
    if sum * 1000 >= p * total then
      break
    end
  end
  return kept
end

local function apply_minp(left, ratio)
  local heaviest = left[1].weight
  local kept = {}
  for _, item in ipairs(left) do
    if item.weight * 1000 >= ratio * heaviest then
      kept[#kept + 1] = item
    end
  end
  return kept
end

function M.chain_command(options, items)
  local left = rank.ranking(items)
  for step in options.steps:gmatch("[^,]+") do
    local name, value = step:match("^(%a+):(%d+)$")
    value = tonumber(value)
    if name == "topk" then
      left = apply_topk(left, value)
    elseif name == "topp" then
      left = apply_topp(left, value)
    elseif name == "minp" then
      left = apply_minp(left, value)
    end
  end
  local rows = {}
  for _, item in ipairs(left) do
    rows[#rows + 1] = { token = item.token, number = item.weight }
  end
  return { status = 0, out = report.render_rows(rows, options.format, left[1].weight), err = "" }
end

return M
