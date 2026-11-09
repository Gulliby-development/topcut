-- The test helper: every row runs one command line through topcut.cli.run.
-- A spec file reaches busted's describe and it only through the busted module, not through globals.
local busted = require("busted")
local luassert = require("luassert")
local cli = require("topcut.cli")

local M = {}

local function show(text)
  return (text:gsub("[^ -~]", function(c)
    return string.format("\\x%02x", c:byte())
  end))
end

-- A row is { args, input, status, out, err }. The label names the list of the file ("rows" or "totals").
function M.check_rows(rows, label)
  busted.describe(label or "rows", function()
    for i, row in ipairs(rows) do
      busted.it("row " .. i .. ": " .. show(table.concat(row[1], " ")), function()
        local result = cli.run(row[1], row[2])
        luassert.are.same({ row[3], row[4], row[5] }, { result.status, result.out, result.err })
      end)
    end
  end)
end

-- A row is { args, "", expected, "", "" }: expected is 1 when the command line must read standard input, else 0.
function M.check_reads(rows)
  busted.describe("reads", function()
    for i, row in ipairs(rows) do
      busted.it("row " .. i .. ": " .. show(table.concat(row[1], " ")), function()
        luassert.are.equal(row[3] == 1, cli.reads_stdin(row[1]))
      end)
    end
  end)
end

return M
