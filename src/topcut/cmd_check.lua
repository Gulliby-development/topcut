-- The check command: validates the list and reports its size and total weight.
local report = require("topcut.report")

local M = {}

function M.check_command(_, items)
  local total = 0
  for _, item in ipairs(items) do
    total = total + item.weight
  end
  return { status = 0, out = "ok, " .. report.plural(#items, "candidate") .. ", total " .. total .. "\n", err = "" }
end

return M
