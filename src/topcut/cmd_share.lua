-- The share command: each weight as a share of the total in the chosen unit.
local registry = require("topcut.registry")
local report = require("topcut.report")

local M = {}

function M.share_command(options, items)
  local scale = registry.UNITS[options.unit]
  local total = 0
  for _, item in ipairs(items) do
    total = total + item.weight
  end
  local rows = {}
  for _, item in ipairs(items) do
    rows[#rows + 1] = { token = item.token, number = (item.weight * scale + total // 2) // total }
  end
  return { status = 0, out = report.render_rows(rows, options.format, scale), err = "" }
end

return M
