-- The writing of a table in a format, and the plural of a count.
local M = {}

function M.render_rows(rows, format, full)
  local parts = {}
  for _, row in ipairs(rows) do
    local line
    if format == "csv" then
      line = row.token .. "," .. row.number
    elseif format == "bar" then
      local bars = require("topcut.bars")
      line = row.token .. " " .. row.number .. " " .. bars.bar(row.number, full)
    else
      line = row.token .. " " .. row.number
    end
    parts[#parts + 1] = line .. "\n"
  end
  return table.concat(parts)
end

function M.plural(count, noun)
  if count == 1 then
    return count .. " " .. noun
  end
  return count .. " " .. noun .. "s"
end

return M
