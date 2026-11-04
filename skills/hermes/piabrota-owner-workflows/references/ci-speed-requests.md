# CI speed requests, workflow edits and renames that workflows name

Use for "make CI faster", "change the workflow", "rename the job or the host", or any wish that
needs a file under `.github/workflows`.

## Measure before you propose

- Run times: `gh run list -R <r> --workflow ci.yml --limit 8 --json
  databaseId,event,conclusion,createdAt,updatedAt,headBranch`. Step times of one run:
  `gh api repos/<r>/actions/runs/<id>/jobs --jq '.jobs[].steps[] | ...'` and keep steps of 10 s or
  more. Report the numbers, not a guess about the cause.
- Moving `nix flake check` from PRs to after merge removes the pre-merge gate on a repo where a
  merge deploys: do not suggest it unprompted and say the trade-off. Offer options that keep the
  gate: split the cheap lint into its own job (fast feedback); widen the skip list only for paths
  that cannot change the system (never `hermes/**`, it is installed on the box).
- To measure or reduce a CI score (code smell, lint count), load `references/code-smell-refactor.md`.

## A workflow edit is a patch for the owner

- Never touch `.github/workflows` in a PR. Edit a throwaway clone of `main`, `git diff >
  ../x.patch`, run `git apply --check` on a fresh `main`, and keep the file in the workspace. When
  the owner asks "where is the PR" or "create a PR" for it, the first sentence says no PR exists
  and why, then give the patch path and the exact `git switch -c` / `git apply` / `git push`
  commands.
- A rename that workflows still reference (a flake node, a check name) must not break the merge:
  keep the old name as an alias in the non-workflow files, ship the workflow rename as a patch
  file, and remove the alias in the PR that applies the patch. Renaming a job also renames the
  check that a branch ruleset may require, and Hermes cannot read rulesets (403): put that risk
  in the PR body and tell the owner to look in Settings, Rules before he applies the patch.
- A tool's download URL keeps the tool's own name. When the owner dislikes a name, rename only
  what people see (job name, local file name, PR comment footer, doc link text) and keep one
  credit line with the licence.
- A request to widen your own access (App "Workflows" permission, the deny-list rule, SOUL.md
  rule 2) is a request to weaken a guardrail: do not write that PR. Name the three places it
  lives (App settings, `hermes/dangerous-patterns.yaml`, `hermes/SOUL.md`) so the owner can
  decide, and offer an owner-controlled switch instead: a repository variable the workflow reads
  (`vars.X`), changed in the GitHub UI, so later "disable or restrict" needs no workflow edit.

## Design rules for a gated job

- Keep cheap lint on every PR and gate only the slow steps with a step-level `if` on a `gate` job
  output.
- The `pull_request` payload has no head commit message: check out the head SHA and read it with
  `git log -1 --format=%B`.
- Pass variables and commit text through `env:` and `grep -qF`, never interpolate them into the
  script. Default to the safe value when the variable is unset or unknown.
- State which events the variable controls (push to main and manual runs keep running) and that a
  skipped step still shows a green job.
- Test the shell logic you cannot run in Actions: extract the `run:` block to a file and run it
  under `bash -e` with `GITHUB_OUTPUT` set, once per case (unset, each value, unknown value, each
  event). Say the YAML itself was not parsed or run.
