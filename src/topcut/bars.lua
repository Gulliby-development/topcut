-- The hash marks of a value against a full bar.
local M = {}

-- value * 20 / full rounded down, at least one mark for a value above 0 and at most 20; no mark for 0.
function M.bar(value, full)
  if value <= 0 or full <= 0 then
    return ""
  end
  local marks = value * 20 // full
  return string.rep("#", math.min(20, math.max(1, marks)))
end

return M
