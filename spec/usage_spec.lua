local harness = require("spec.harness")

local rows = {
  { { "help" }, "", 0, "usage: topcut check\n       topcut share [--unit UNIT] [--format FORMAT]\n       topcut topk --k N [--format FORMAT]\n       topcut topp --p PERMILLE [--format FORMAT]\n       topcut minp --ratio PERMILLE [--format FORMAT]\n       topcut chain --steps STEPS [--format FORMAT]\n       topcut draw --at N\n", "" },
  { { "-h" }, "", 0, "usage: topcut check\n       topcut share [--unit UNIT] [--format FORMAT]\n       topcut topk --k N [--format FORMAT]\n       topcut topp --p PERMILLE [--format FORMAT]\n       topcut minp --ratio PERMILLE [--format FORMAT]\n       topcut chain --steps STEPS [--format FORMAT]\n       topcut draw --at N\n", "" },
  { { "--help", "--bogus" }, "", 0, "usage: topcut check\n       topcut share [--unit UNIT] [--format FORMAT]\n       topcut topk --k N [--format FORMAT]\n       topcut topp --p PERMILLE [--format FORMAT]\n       topcut minp --ratio PERMILLE [--format FORMAT]\n       topcut chain --steps STEPS [--format FORMAT]\n       topcut draw --at N\n", "" },
  { {}, "", 2, "", "usage: topcut check\n       topcut share [--unit UNIT] [--format FORMAT]\n       topcut topk --k N [--format FORMAT]\n       topcut topp --p PERMILLE [--format FORMAT]\n       topcut minp --ratio PERMILLE [--format FORMAT]\n       topcut chain --steps STEPS [--format FORMAT]\n       topcut draw --at N\n" },
  { { "--version" }, "", 0, "topcut 0.1.0\n", "" },
  { { "--version", "x" }, "", 0, "topcut 0.1.0\n", "" },
  { { "frob" }, "", 2, "", "topcut: unknown command frob\n" },
  { { "" }, "", 2, "", "topcut: unknown command \n" },
  { { "Check" }, "", 2, "", "topcut: unknown command Check\n" },
  { { "-H" }, "", 2, "", "topcut: unknown command -H\n" },
}

harness.check_rows(rows)
