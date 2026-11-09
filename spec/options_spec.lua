local harness = require("spec.harness")

local rows = {
  { { "share", "extra" }, "", 2, "", "topcut: unexpected argument extra\n" },
  { { "share", "-" }, "", 2, "", "topcut: unexpected argument -\n" },
  { { "share", "" }, "", 2, "", "topcut: unexpected argument \n" },
  { { "share", "--bogus" }, "", 2, "", "topcut: unknown option --bogus\n" },
  { { "check", "--format", "plain" }, "", 2, "", "topcut: option --format is not valid for check\n" },
  { { "share", "--k", "3" }, "", 2, "", "topcut: option --k is not valid for share\n" },
  { { "share", "--unit", "ppm", "--unit", "ppm" }, "", 2, "", "topcut: given twice: --unit\n" },
  { { "share", "--unit" }, "", 2, "", "topcut: missing value for --unit\n" },
  { { "share", "-x", "--unit" }, "", 2, "", "topcut: unknown option -x\n" },
  { { "check", "--unit" }, "", 2, "", "topcut: option --unit is not valid for check\n" },
  { { "share", "--unit", "x", "--bogus" }, "", 2, "", "topcut: bad value for --unit\n" },
  { { "topk" }, "", 2, "", "topcut: missing --k\n" },
  { { "topp" }, "", 2, "", "topcut: missing --p\n" },
  { { "minp" }, "", 2, "", "topcut: missing --ratio\n" },
  { { "chain" }, "", 2, "", "topcut: missing --steps\n" },
  { { "draw" }, "", 2, "", "topcut: missing --at\n" },
  { { "draw", "--format", "csv" }, "", 2, "", "topcut: option --format is not valid for draw\n" },
  { { "topk", "--unit", "ppm", "--k", "2" }, "", 2, "", "topcut: option --unit is not valid for topk\n" },
  { { "share", "--format", "csv", "--unit", "ppm" }, "a 1\n", 0, "a,1000000\n", "" },
  { { "share", "--unit", "percent", "--format", "plain" }, "a 1\nb 1\n", 0, "a 50\nb 50\n", "" },
  { { "topk", "--format", "csv", "--k", "1" }, "the 500\ncat 300\ndog 150\nsat 40\nmat 10\n", 0, "the,500\n", "" },
  { { "minp", "--format", "bar", "--ratio", "500" }, "the 500\ncat 300\ndog 150\nsat 40\nmat 10\n", 0, "the 500 ####################\ncat 300 ############\n", "" },
  { { "draw", "--at", "0" }, "a 1\n", 0, "a\n", "" },
  { { "chain", "--format", "csv", "--steps", "topk:1" }, "the 500\ncat 300\ndog 150\nsat 40\nmat 10\n", 0, "the,500\n", "" },
}

harness.check_rows(rows)
