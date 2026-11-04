# Tuning the omp coding worker (oh-my-pi) on the box

Read the repo state first: `hermes.nix` (`ompWrapped`), `hermes/omp.yml`,
`hermes/skills/hermes-omp/SKILL.md`, and the omp docs at the pinned tag (shallow clone of
`can1357/oh-my-pi` at that tag; `docs/settings.md`, `docs/config-usage.md`,
`docs/system-prompt-customization.md`, `docs/context-files.md`). The pinned tag is in
`omp/package.nix`.

## Layers, each edited in a different place (nearest to the run first)

Two layers need no deploy. **The task file** (per run, written from the owner's chat request).
**Per-run flags** the owner can ask for: `--thinking <off|minimal|low|medium|high|xhigh|max|auto>`,
`--model <id-or-role>`, `--max-time <duration>`; model, thinking and time only, never a flag that
loosens a rule. The five below are edited by PR (the last one in the target repo).

1. **Settings overlay `hermes/omp.yml`.** The wrapper sets `PI_CONFIG_FILES` to this store file, so
   it outranks omp's own `config.yml` and a cloned repo's `.omp/config.yml`, and omp cannot edit
   it. Models, limits, tool switches and the bash allow/deny patterns live here.
2. **The wrapper in `hermes.nix`.** Environment variables, `choom` (the OOM killer stops omp before
   the gateway) and any flag to pass on every run, such as `--append-system-prompt <store file>`.
   A fixed prompt addition belongs here as a store file, not in `~/.omp/agent/APPEND_SYSTEM.md`,
   which omp could edit.
3. **The `hermes-omp` skill.** The procedure: task file, command, diff review, PR. Most quality
   gain with a Sonnet-only setup comes from the task file: goal, a done-criterion, the exact check
   commands that fit 1 vCPU / 1 GB, and a required "how I proved it" section in omp's answer.
4. **The target repo's context.** omp reads its `AGENTS.md`, `.omp/AGENTS.md` and `.omp/RULES.md`
   (`RULES.md` stays in every request). That is a PR to that repo, not to nix-os.

Every change to layers 1-3 is a nix-os PR; a merge restarts `hermes-agent`. The release itself is a
fifth nix-os layer: `omp/package.nix` (tag and hash).

## Which setting wins (omp docs `config-usage.md`, "Layers", at the pinned tag)

Highest first: an environment variable a setting declares; runtime overrides; overlays
(`PI_CONFIG_FILES`, then each `--config <file>`, later wins); the project's `.omp/config.yml`; the
user's `~/.omp/agent/config.yml`; omp's default. The wrapper puts `hermes/omp.yml` in the overlay
slot, so a cloned repo or omp's own user file cannot loosen it; an array in the overlay replaces
the lower array. omp sessions are JSONL files under
`~/.omp/agent/sessions/<encoded-cwd>/` (`omp --export <session>` writes HTML; not tried on the box).
To teach the owner, lay out this order and the layer list as one table: layer, file, what it
controls, who edits it, when it takes effect.

## Levers that matter for coding quality

- `modelRoles`: `default`/`slow`/`plan` carry the main work; `task` is the subagent role that edits
  code; `smol`, `tiny`, `commit`, `memory`, `advisor`, `judge` are cheap side roles. Check `omp.yml` for what is already set before you propose a change: `task` is Sonnet today, so
  the first offer is a higher `--thinking` for one run, or a stricter task file, not a model swap
  (cost of any raise: owner's quota). `task.agentModelOverrides`
  changes single agents only.
- `defaultThinkingLevel`: more reasoning, better code, more quota. Read the default and the
  accepted values in `docs/settings.md` at the pinned tag before proposing one: the default is
  `high` (values `minimal` to `max`, plus `auto`), so a bare `medium` would lower it. Pin `high`
  explicitly so an upstream default cannot move it, and say that the line changes nothing today.
- `lsp`, `eval`, `browser`, `memory`, `advisor` are off for RAM. LSP is the off-switch that would
  help code quality most; propose it only as a measured trial (peak RSS under the 1 GiB cap).
- `tools.maxTimeout`, `async.maxJobs`, and the skill's `--max-time` bound a run.

## Running omp for a task (the hermes-omp procedure in practice)

- When the owner says "use OMP" for a code change, run it; do not do the edits by hand. Write the
  task file with every change listed as an exact edit (file, old text, new text or content), the
  check commands, and a "how to prove it is done" section. Run from the working tree on the
  `hermes/*` branch: `omp -p --no-title --max-time 15m < <task file> > <scratch>/out.txt`.
- A foreground `terminal` call above 600 s is promoted to a background process with a completion
  notice: do not re-run it. End the turn with a short status and review the diff when the notice
  arrives. One omp run at a time.
- Afterwards read `git status`, `git diff --stat` and the diff yourself, run the cheap checks
  (`nix-instantiate --parse`, a YAML load, greps for the new lines) and keep omp's claims separate
  from what you verified.
- **Review-only run** ("review PR N with omp"): add `--approval-mode write`. In that mode omp can
  read and write files but `bash` is refused, so it cannot run `git`, `gh` or `nix`. Prepare its
  inputs: refetch the PR head right before (the owner pushes while you work; `git fetch --depth 1
  origin pull/N/head && git switch --detach FETCH_HEAD`), and copy the diff to
  `/var/lib/hermes/workspace/omp-tasks/` (omp cannot read `~/.hermes/cache/scratch`). The task
  file lists the areas in priority order, asks for `file:line`, a severity (BLOCKER, SHOULD-FIX,
  NIT) with certain/likely/unsure, the files read and what it could not check, and says to edit
  nothing. A 2,000-line PR takes 10 to 12 minutes, so run it in the background and end the turn.
  Afterwards `git switch main`, delete the task and diff files, and check `git status` is clean.
- While omp runs, its stdout stays empty (the log shows only "Working...") until it ends. When
  the owner asks "still running?", answer from facts: `pgrep -af bin/omp`, `ps -o etime=,rss= -p
  <pid>`, the size of the output file and `git status --short`; give the time left on the
  `--max-time` limit. Do not guess.
- **Verify before you relay.** Re-check each top finding with a grep or a read of the file (and of
  the upstream source at the pinned rev for claims about Hermes behaviour); report which findings
  you confirmed and which you only relay, and keep omp's own "unsure" labels. Do not run omp a
  second time for a review unless a whole area was skipped.
- **Fix runs on a PR you do not own** go in at most two omp runs of one theme each (for example
  checklist and doc claims first, stale docs second). Inspect the diff between runs.
- **A wide rename or sweep** (a name changes in code, docs and config) needs a keep-list in the task
  file: what must NOT change (names of skills, plans, secrets, a human's shortcuts, files under
  `.github/`, drawn figures) and the grep that proves it
  (`git grep -n -i '<old>' -- . ':!<excluded dirs>'` lists only keep-list items, each with a reason).
  Do the `git mv` yourself before the run, and run the evaluation checks afterwards: omp cannot
  run `nix`.
- **Two jobs in one session:** the omp run owns the working tree until it ends. Start the other
  branch in a `git worktree`, and do not touch the files omp reads.
- **The owner changes where the work lands while omp runs** ("in the same PR" becomes "in a new
  PR"). `git switch -c hermes/<new-slug>` on the same tree moves the uncommitted edits to the
  new branch and leaves the old branch clean; omp keeps working. Commit on the new branch from
  the base the owner named. Follow the latest order and say where the work went.
- **Vendored files** (`.claude/skills/<name>/`, `vendor/`) are refreshed by copying upstream. Put
  them in the task file's keep-list: omp edits them when a grep hit sits there, and the next
  refresh brings the old text back. Revert such an edit and report the hit instead.

## Rules that stay

- Never propose loosening `bash.patterns` or `restrictedFolders`. `omp --config <file>` accepts
  repeatable overlays and a later file wins, so a hand-run overlay can loosen the guardrails by
  accident: suggest manual experiments with model and thinking keys only.
- Calibrate with the real run: a five-file edit (config, new prompt file, wrapper, skill, docs in
  two languages) took about 80 s and peaked near 500 MiB resident, well under the 1 GiB cap.
  Expect small formatting slips (a missing blank line between YAML keys): fix them yourself after
  reading the diff instead of a second omp run. omp warns that a new file must be `git add`ed
  before a flake build; do it before the commit.
- State what is unverified: the first run with a newly passed flag (for example
  `--append-system-prompt <store path>`) only proves itself after the deploy, because the run
  that wrote the change used the old wrapper. Exit 137 means the kernel killed it.
