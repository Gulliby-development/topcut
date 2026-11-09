-- The candidates ranked by weight, heaviest first; equal weights keep the input order.
local M = {}

-- Returns a new array of the same item tables; items is not changed. A stable insertion sort moves an item ahead only while its weight is strictly greater.
function M.ranking(items)
  local sorted = {}
  for i = 1, #items do
    local item = items[i]
    local j = i - 1
    while j >= 1 and sorted[j].weight < item.weight do
      sorted[j + 1] = sorted[j]
      j = j - 1
    end
    sorted[j + 1] = item
  end
  return sorted
end

return M
