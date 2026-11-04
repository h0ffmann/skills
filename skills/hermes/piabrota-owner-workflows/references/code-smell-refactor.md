# Lowering a CI code-smell score without changing behaviour

Use for "reduce the code smell", "the score is high", or any refactor whose target is a number
from a CI report. In nix-os the report is a pinned analyzer (workflow `code-smell-report.yml`)
that scores 0 (best) to 100 over Python, Rust and shell only; Nix and Gleam are covered by
statix, deadnix and nixpkgs-fmt.

## Measure first, with the CI's own ruler

1. Read the workflow for the tool URL, the SHA-256 and the exclude flags. Download the binary to
   scratch, run `sha256sum --check`, then run the exact command line of the workflow on the
   working tree. Your number must equal the last PR comment's number; if it does not, the
   command line differs, so fix that before you trust any delta.
2. Read the metric table with its weights, not only the total. The total is a weighted sum, so the
   heaviest metric with the worst score pays most (in nix-os: cyclomatic complexity, weight 0.30).
   List the functions that the report names with their complexity: they are the work list.
3. Copy the binary into `/var/lib/hermes/workspace/` so omp can run it (omp cannot read `~/.hermes`).

## Baseline the tests before the refactor

The repo's unit tests are the only proof that behaviour stays. `python3` may be missing on the
terminal: run the tests with `export XDG_CACHE_HOME=<scratch>/nixcache` and
`nix run nixpkgs#python3 -- -m unittest -v <module>` from the tests folder, and record the count
(for nix-os `hermes/plugins/tests`, `test_plugins`). Put the same command in the omp task file.

## The omp task file for a smell refactor

- Say that behaviour must not change and that messages seen by users and tests stay character
  for character. Plugins that open real PRs make a silent change worse than a bad score.
- Order the work by weight: split the highest-complexity functions first (one named function per
  rule, a list of rule functions in a loop, early return, a dict in place of an `if/elif` ladder),
  then move helpers that two files repeat into the shared module, then comments.
- Require a characterization test for each branch that no test covers, written first and passing on
  the old code.
- Forbid gaming: no comment that restates a name, no function split into pieces nobody calls, no
  deleted check or error path. A comment says WHY. A metric such as comment ratio is weak; say so
  in the PR and do not chase it with filler.
- Fence off paths: `.github/`, `flake.lock`, `*.nix`, `vendor/`, `.claude/` (vendored third-party
  skills are refreshed by copying upstream, never edited). After the run, `git status` must show
  no file under a fenced path; revert one with `git checkout -- <path>` and say so in the PR.
- Ask for the before and after score, the six metric rows, each function's complexity before and
  after, the test counts, and the shellcheck exit code. Then repeat the measurement yourself.

## PR body

First line: whether the merge deploys (plugin and script changes under `hermes/` do; Markdown
only does not). Give the score before and after from your own run, the tests before and after,
what omp changed, and what stays unmeasured (the CI run itself).
