-- The draw command: the candidate that a position in the cumulative weights falls on, in input order.
local registry = require("topcut.registry")

local M = {}

function M.draw_command(options, items)
  local total = 0
  for _, item in ipairs(items) do
    total = total + item.weight
  end
  if options.at >= total then
    registry.fail(1, "draw position " .. options.at .. " is outside the total " .. total)
  end
  local sum = 0
  for _, item in ipairs(items) do
    sum = sum + item.weight
    if sum > options.at then
      return { status = 0, out = item.token .. "\n", err = "" }
    end
  end
end

return M
