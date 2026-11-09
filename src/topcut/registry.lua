-- The version, the limits, the usage text, the command table and the failure helper. Verbatim from the brief.
local M = {}

M.VERSION = "topcut 0.1.0"
M.MAX_LINES = 32

M.USAGE = "usage: topcut check\n" .. "       topcut share [--unit UNIT] [--format FORMAT]\n" .. "       topcut topk --k N [--format FORMAT]\n" .. "       topcut topp --p PERMILLE [--format FORMAT]\n" .. "       topcut minp --ratio PERMILLE [--format FORMAT]\n" .. "       topcut chain --steps STEPS [--format FORMAT]\n" .. "       topcut draw --at N\n"

M.FORMATS = { "plain", "csv", "bar" }
M.UNITS = { permille = 1000, percent = 100, ppm = 1000000 }
M.OPTIONS = { "--format", "--unit", "--k", "--p", "--ratio", "--steps", "--at" }

-- name: the command word; options: the options it accepts; required: the option that must be given ("" for none);
-- module and handler: where the function that runs it lives. A handler is called as handler(options, items).
M.COMMANDS = {
  { name = "check", options = {}, required = "", module = "topcut.cmd_check", handler = "check_command" },
  { name = "share", options = { "--unit", "--format" }, required = "", module = "topcut.cmd_share", handler = "share_command" },
  { name = "topk", options = { "--k", "--format" }, required = "--k", module = "topcut.cmd_filters", handler = "topk_command" },
  { name = "topp", options = { "--p", "--format" }, required = "--p", module = "topcut.cmd_filters", handler = "topp_command" },
  { name = "minp", options = { "--ratio", "--format" }, required = "--ratio", module = "topcut.cmd_filters", handler = "minp_command" },
  { name = "chain", options = { "--steps", "--format" }, required = "--steps", module = "topcut.cmd_chain", handler = "chain_command" },
  { name = "draw", options = { "--at" }, required = "--at", module = "topcut.cmd_draw", handler = "draw_command" },
}

-- Ends a command: cli.run turns the error into the reply { status = STATUS, out = "", err = "topcut: MESSAGE\n" }.
function M.fail(status, message)
  error({ status = status, message = message }, 0)
end

return M
