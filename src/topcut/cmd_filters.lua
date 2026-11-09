-- The topk, topp and minp commands: filters over the ranking.
local rank = require("topcut.rank")
local report = require("topcut.report")

local M = {}

-- Renders the kept items (in ranking order) with the heaviest weight as the full bar.
local function render(options, ranking, kept)
  local rows = {}
  for _, item in ipairs(kept) do
    rows[#rows + 1] = { token = item.token, number = item.weight }
  end
  return { status = 0, out = report.render_rows(rows, options.format, ranking[1].weight), err = "" }
end

function M.topk_command(options, items)
  local ranking = rank.ranking(items)
  local kept = {}
  for i = 1, math.min(options.k, #ranking) do
    kept[i] = ranking[i]
  end
  return render(options, ranking, kept)
end

function M.topp_command(options, items)
  local ranking = rank.ranking(items)
  local total = 0
  for _, item in ipairs(ranking) do
    total = total + item.weight
  end
  local kept = {}
  local sum = 0
  for _, item in ipairs(ranking) do
    sum = sum + item.weight
    kept[#kept + 1] = item
    if sum * 1000 >= options.p * total then
      break
    end
  end
  return render(options, ranking, kept)
end

function M.minp_command(options, items)
  local ranking = rank.ranking(items)
  local heaviest = ranking[1].weight
  local kept = {}
  for _, item in ipairs(ranking) do
    if item.weight * 1000 >= options.ratio * heaviest then
      kept[#kept + 1] = item
    end
  end
  return render(options, ranking, kept)
end

return M
