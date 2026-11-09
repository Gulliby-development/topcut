<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# topcut

[![CI](https://github.com/Gulliby-development/topcut/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/topcut/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

topcut replays top-k, top-p and min-p sampling cuts on a short list of weighted candidates. It reads the list from standard input and prints the result. It is written in Lua 5.4 with the standard library only. It makes no model call and uses no random numbers and no clock. All arithmetic is on integers, so the same input always gives the same output.

It is for people who tune or debug samplers and want to see a cut on a list they can read, in a terminal, in a script or in CI.

Run it from the repository directory:

```text
lua bin/topcut COMMAND
```

## Usage

```text
usage: topcut check
       topcut share [--unit UNIT] [--format FORMAT]
       topcut topk --k N [--format FORMAT]
       topcut topp --p PERMILLE [--format FORMAT]
       topcut minp --ratio PERMILLE [--format FORMAT]
       topcut chain --steps STEPS [--format FORMAT]
       topcut draw --at N
```

Every command reads the candidate list from standard input.

- `check` validates the list and prints `ok, N candidates, total T`, for example `ok, 5 candidates, total 1000`. A single candidate is `1 candidate`.
- `share` prints every candidate in input order with its share of the total weight in a unit. Default unit: `permille`.
- `topk` keeps the N heaviest candidates.
- `topp` keeps the smallest group of heaviest candidates whose weights reach a share of the total.
- `minp` keeps the candidates that weigh at least a ratio of the heaviest one.
- `chain` applies several filters one after the other.
- `draw` names the candidate that a position in the cumulative weights falls on.

Defaults: `--format` is `plain` and `--unit` is `permille`.

Option values:

| Option | Accepted values |
| --- | --- |
| `--format` | `plain`, `csv`, `bar` |
| `--unit` | `permille`, `percent`, `ppm` |
| `--k` | whole number from 1 to 32 |
| `--p` | whole number from 1 to 1000 |
| `--ratio` | whole number from 0 to 1000 |
| `--at` | whole number from 0 to 999999999 |
| `--steps` | one to four steps separated by commas |

Numbers have no sign, no leading zero and no more digits than the largest value of the range (`0` is fine where the range starts at 0). Every option takes the next word as its value; there is no `--option=value` form.

Each step of `--steps` is `topk:N`, `topp:P` or `minp:R`, with a value in the range of the option of the same name, for example `topk:3,minp:100`. An empty step, a fifth step or any other text is a bad value.

`help`, `-h` and `--help` as the first word print the usage on standard output and exit with status 0. `--version` prints `topcut 0.1.0` and exits with status 0. With no word the usage goes to standard error and the status is 2.

## List format

One candidate per line: a token and a weight, separated by spaces or tabs.

- A token is 1 to 12 characters from `A-Z`, `a-z`, `0-9`, `_`, `.` and `-`. Upper and lower case are different tokens, and a token may appear only once.
- A weight is `0` or one to six decimal digits (0 to 999999) with no leading zero and no sign.
- Blank lines, lines holding only spaces and tabs, and lines whose first word starts with `#` are skipped. They still count in line numbers.
- Spaces and tabs at the ends of a line are ignored. One CR at the end of a line is dropped. A last line without a line feed counts.
- At most 32 lines are allowed, skipped lines included.
- The list needs at least one candidate and a total weight above zero.

## Formats

A table has one line per candidate, with a token and a number.

- `plain`: `TOKEN NUMBER`
- `csv`: `TOKEN,NUMBER`
- `bar`: `TOKEN NUMBER MARKS`, where MARKS is a run of `#` characters. A number of 0 has no marks, so the line ends with a space.

The marks are `number * 20 / full` rounded down, at least 1 mark for a number above 0, and at most 20 marks. Full is the unit scale for `share` (1000, 100 or 1000000) and the heaviest weight of the table for the other commands.

The share units are `permille` (whole is 1000), `percent` (100) and `ppm` (1000000). A share is `(weight * scale + total // 2) // total`, so a half rounds up and the shares need not add up to the scale.

## Filters

The ranking sorts candidates by weight, heaviest first. Candidates with the same weight keep their input order.

- `topk --k N` keeps the N heaviest candidates, or all when the list is shorter.
- `topp --p PERMILLE` walks down the ranking and keeps every candidate up to and including the first one at which the weight kept so far times 1000 is at least P times the total weight.
- `minp --ratio PERMILLE` keeps the candidates whose weight times 1000 is at least RATIO times the heaviest weight. The heaviest one always stays.

All three print the kept candidates in ranking order, each with its unchanged weight.

`chain --steps STEPS` applies its steps one after the other, each on the candidates the step before it kept. The first step works on the whole list. A `topp` step uses the total weight of what is left, and a `minp` step uses the heaviest weight of what is left. Weights never change, and the output is what remains, in ranking order.

`draw --at N` takes position N in the cumulative weights of the list in input order, and prints the token of the first candidate whose running total after its own weight is above N. A position of the total or more is an error.

## Examples

In the examples `topcut` stands for a shell function that runs `lua bin/topcut "$@"`. They use a POSIX shell in the repository directory, and `2>&1` shows the error line.

```text
$ printf 'the 500\ncat 300\ndog 150\nsat 40\nmat 10\n' | topcut topp --p 900
the 500
cat 300
dog 150
$ printf 'the 500\ncat 300\ndog 150\n' | topcut share --unit percent --format bar; printf 'a 1\nb 3\n' | topcut share --format csv
the 53 ##########
cat 32 ######
dog 16 ###
a,250
b,750
$ printf 'the 500\ncat 300\ndog 150\nsat 40\nmat 10\n' | topcut chain --steps topk:4,minp:100; printf 'the 500\ncat 300\ndog 150\n' | topcut draw --at 520
the 500
cat 300
dog 150
cat
$ printf 'a 1\nb\n' | topcut check 2>&1; printf 'a 1\n' | topcut topk 2>&1
topcut: line 2: expected TOKEN WEIGHT
topcut: missing --k
```

## Errors

A command that works writes its result to standard output and nothing to standard error. A command that fails writes nothing to standard output and one line `topcut: MESSAGE` to standard error.

Exit statuses:

- 0: success.
- 1: an error in the list or in a command.
- 2: an error in the command line. Standard input is not read.

The checks run in this order: the command line, then the list, then the command.

Command-line errors (exit 2):

- `topcut: unknown command WORD`
- `topcut: unexpected argument WORD`
- `topcut: unknown option WORD`
- `topcut: option OPTION is not valid for COMMAND`
- `topcut: given twice: OPTION`
- `topcut: missing value for OPTION`
- `topcut: bad value for OPTION`
- `topcut: missing --k`, `topcut: missing --p`, `topcut: missing --ratio`, `topcut: missing --steps` or `topcut: missing --at`

List errors (exit 1):

- `topcut: input is too long (max 32 lines)`
- `topcut: line N: expected TOKEN WEIGHT`
- `topcut: line N: bad token WORD`
- `topcut: line N: bad weight WORD`
- `topcut: line N: duplicate token WORD`
- `topcut: no candidates`
- `topcut: total weight is zero`

Command error (exit 1):

- `topcut: draw position N is outside the total T`

## Development

```text
stylua --check .
luacheck .
busted
```

The tests are literal rows that run command lines through `topcut.cli.run`.

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R103).
