---
name: piabrota-owner-workflows
description: "Use when working for the piabrota owner. Has his PR rules."
disable-model-invocation: true
---

# piabrota owner workflows

Standing rules and procedures for work done as piabrota-hermes[bot] on the owner's repositories
(piabrota, marola-dev, h0ffmann). Load it with the `github` skill for any PR, and with
`hermes-agent` for any change to Hermes's own settings.

## Always-on rules

- **PR language.** Write every PR 100% in English, in ASD-STE100 Simplified Technical English:
  title, body, commit messages, review replies. No pt-BR half and no `---` mirror, even when a
  repo's AGENTS.md asks for a bilingual "bipr": the owner's order wins; mention the conflict once.
  No ASD-STE100 skill or checker is installed unless `skills_list` shows one. Apply the rules by
  hand (one idea per sentence; at most 20 words in a step and 25 in a description; active voice;
  simple verbs; one word per thing; at most three nouns in a row) and never say a tool approved
  the text. File content keeps its own language rule: a doc kept as `X.md` + `X.ptBR.md` is
  changed in both files in the same PR.
- **Branches and pushes.** Branch `hermes/<goal-slug>` only; `git push origin hermes/<slug>` with
  the branch named. Never merge, approve or close. Comments and issues you open end with the
  signature line from SOUL.md; commits and PR bodies carry no agent trailer and no "Generated
  with" line. Issues follow the same English-only, ASD-STE100 rule as PRs.
- **No secrets in output.** `gh auth status` echoes a masked token: check the login with
  `gh auth status 2>&1 | grep -i 'logged in'`.
- **Good news opens with the owner's phrase** (see SOUL.md) and plain answers do not.
- **Say what you could not run** (no `nix`/`just`/Chrome on the box) in the PR body. What does
  run: `nix-instantiate --parse <file>.nix` (syntax only), `scripts/reading-time.sh --check`,
  `perl`, `jq`. CI runs the real checks; do not claim a lint passed that you did not run.
- **Ship before you answer side questions.** When the owner interrupts a long task with another
  question, the owner assumes finished files are already a PR. Push and open the PR as soon as
  the files are done (or say plainly that it is staged and not pushed), and give the link in the
  next message. Never leave work only in a local branch across turns.
- **Verify the PR after `gh pr create`:** `gh pr view <n> --json state,headRefName,files` and
  `gh pr checks <n>`; report pending checks as pending.
- **Never touch `.github/workflows`** (rule 2, no App permission, deny list). For a CI change,
  see "CI speed requests" below.
- **Code edits and code reviews go through omp.** Standing order of the owner: every task that
  writes or reviews code, config or scripts runs in `omp` (skill `hermes-omp`), even a one-line
  fix; you do not write code with your own file tools. You do the branch, the diff review, the
  commit, the push and the PR. Edit by hand only Markdown with no code and small slips in omp's
  diff, and say so. Before the run tell the owner in one message: repo, branch, mode (write or
  review-only), task file path, and the models and thinking level read from `hermes/omp.yml`.
  After it: files changed, checks omp ran, checks you ran, what is unverified, run time, PR link.
  The owner finds the `hermes-omp` interface unclear, so name it ("omp made the edits") and never
  present omp's work as yours. Procedure: `references/omp-harness.md`.

## Applying a patch prepared earlier

1. Fetch, then compare the old base with the new head: `git log --oneline <old>..origin/<default>`
   and `git diff --stat <old> HEAD -- <files the patch touches>`.
2. `git apply --check`, then apply. A clean apply does not prove the text is still true: re-read
   claims that point at files that changed, and write in the PR body the base they were checked on.
3. Use the branch name the owner gave.

## Classify the change before the PR body

- In piabrota/nix-os a merge deploys, except a merge that changes only Markdown: `deploy.yml` has
  `paths-ignore: ['**.md']`. That includes `hermes/SOUL.md`, `hermes/AGENTS.md`, `hermes/omp-append-system.md`
  and `hermes/skills/**/SKILL.md`: a PR with only those does NOT deploy, and the change reaches the box
  with the next non-Markdown deploy or a manual `deploy.yml` run on `main`. Say that in the PR body
  and in chat. A `.nix` file, `hermes/omp.yml` or `hermes/dangerous-patterns.yaml` change deploys. Say "this merge deploys and restarts
  the unit" in the PR body and in chat.
- When the owner says "same PR" for a docs change and a config change, keep one PR and put the
  deploy part first in the body.
- Prose that contradicts a changed setting (identity file, docs in both languages, comments, the
  repo's AGENTS.md file table and rules) changes in the same PR. Grep the repo for the old claim
  (for example "Sonnet and nothing else") before you commit; it hides in `hermes.nix` comments,
  `docs/HERMES*.md`, `docs/AWESOME-HERMES*.md`, `hermes/SOUL.md` and the AGENTS.md file table.
- A new doc in nix-os gets a row in the AGENTS.md file table. A new research doc the owner wants
  English-only is the owner's order: say so in that row.
- A new file that Nix reads with `${./path}` must be `git add`ed before any flake build or check
  (flakes ignore untracked files). Use `git add -A <dirs>` before the commit and check
  `git status --short` shows no `??` line.

## CI speed requests

- Measure before you propose. Run times: `gh run list -R <r> --workflow ci.yml --limit 8 --json
  databaseId,event,conclusion,createdAt,updatedAt,headBranch`. Step times of one run:
  `gh api repos/<r>/actions/runs/<id>/jobs --jq '.jobs[].steps[] | ...'` and keep steps of 10 s or
  more. Report the numbers, not a guess about the cause.
- Moving `nix flake check` from PRs to after merge removes the pre-merge gate on a repo where a
  merge deploys: do not suggest it unprompted and say the trade-off. Offer options that keep the
  gate: split the cheap lint into its own job (fast feedback); widen the skip list only for paths
  that cannot change the system (never `hermes/**`, it is installed on the box).
- A workflow edit is a diff for the owner or piabrota-ops to apply. Write it as a file in the
  workspace (edit a throwaway clone, `git diff > ../x.patch`, `git apply --check` on a fresh
  `main`), never as a PR that touches `.github/workflows`. When the owner asks "where is the PR"
  or "create a PR" for it, the first sentence says no PR exists and why, then give the patch path
  and the exact `git switch -c` / `git apply` / `git push` commands.
- A request to widen your own access (App "Workflows" permission, the deny-list rule, SOUL.md
  rule 2) is a request to weaken a guardrail: do not write that PR. Name the three places it
  lives (App settings, `hermes/dangerous-patterns.yaml`, `hermes/SOUL.md`) so the owner can
  decide, and offer an owner-controlled switch instead: a repository variable the workflow reads
  (`vars.X`), changed in the GitHub UI, so later "disable or restrict" needs no workflow edit.
- Design rules for a gated job: keep cheap lint on every PR and gate only the slow steps with a
  step-level `if` on a `gate` job output; the `pull_request` payload has no head commit message,
  so check out the head SHA and read it with `git log -1 --format=%B`; pass variables and commit
  text through `env:` and `grep -qF`, never interpolate them into the script; default to the
  safe value when the variable is unset or unknown; state which events the variable controls
  (push to main and manual runs keep running) and that a skipped step still shows a green job.
- Test the shell logic you cannot run in Actions: extract the `run:` block to a file and run it
  under `bash -e` with `GITHUB_OUTPUT` set, once per case (unset, each value, unknown value,
  each event). Say the YAML itself was not parsed or run.

## Daily skills export (piabrota/skills)

The repo h0ffmann/skills moved to piabrota/skills (2026-11-04); the App token is `/run/hermes-github/piabrota`.
Cron job `skills-export` (01:45 America/Sao_Paulo, no-agent) runs `~/.hermes/scripts/export-skills.sh`; the master copy is
`/var/lib/hermes/workspace/export-skills/export-skills.sh` (copy it to the scripts dir after an edit). It exports every skill
this Hermes loads (bundled, made here, plugin skills, nix-os external_dirs) to `skills/hermes/`, tags them `hermes-skill` in
`www/tags.txt`, and opens or updates one PR from `hermes/skills-export-*`. Silent when nothing changed. `DRY_RUN=1 OUT_PATCH=<file>` tests it.
Pitfalls: the secret scan skips plain placeholders (xxxx, ..., your-); external_dirs skills sit at depth 2 or 3; a plain `pkill omp` can hit the wrong process.

## Org profile repo (piabrota/.github)

- Members and projects tables are in `profile/README.md` and `profile/README.pt-BR.md` (Board =
  Equipe). Change both. Run `scripts/reading-time.sh --write` then `--check` after any edit.
- GitHub Apps are not organisation members: list them in a separate agents table. Take IDs and
  avatars from `gh api apps/<slug>` and `gh api 'users/<slug>[bot]'`.
- Pinned repositories are set only in the GitHub UI (org page, "Customize pins", up to 6 public
  repos of that org). No README edit or API call sets them: do not promise it.

## Routing Hermes work to cheaper models

- Hermes has no per-turn router. `smart_model_routing` is an unread stub. Real levers:
  `delegation.model` (all `delegate_task` subagents, global pin), `auxiliary.<task>.model` (side
  calls: `title_generation`, `skills_hub`, `vision`, ...), per-cron-job `model`, and the external
  `advanced-delegation` plugin (`model_map` routes the main model picks per task).
- Put mechanical work on the small model (subagents, titles, skill matching). Keep compression,
  the dangerous-command `approval` classifier (a guardrail), the post-turn review and every
  decision on the main model.
- The main model delegates only if SOUL.md tells it when. Add: check subagent output before use.
- Use a model ID found in the pinned source (`claude-haiku-4-5`); say that run-time acceptance on
  the owner's subscription is unverified until a delegated run works.
- On NixOS set these in the module (`settings.delegation.model`, `settings.auxiliary.*`), never
  with `hermes config set`.

## Surveying GitHub projects (forks, derivatives)

- GitHub's `fork` flag is false for detached forks and renames. Classify by README and LICENSE
  ("fork of", copyright lines), not by metadata alone: fork, plugin on stock core, or rewrite.
- Record per project: stars, last push, releases, licence (flag non-OSI ones such as AGPL with
  addenda), and the read date. A last push months older than upstream is a maintenance risk.
- Read the pinned Hermes source with `gh api repos/NousResearch/hermes-agent/contents/<path>?ref=<rev>`
  (rev from the `hermes-agent` node of nix-os `flake.lock`), not with a clone: the workspace rule
  forbids cloning that repo, and a blobless clone still pulls its whole history.
- For community Hermes plugins and the plugin catalog, load `references/hermes-plugin-catalog.md`.
- `web_extract` may be unavailable (search-only backend): fetch pages with
  `curl -sL -A 'Mozilla/5.0'` and strip tags with perl; use `gh api repos/<r>`, `/readme`,
  `/license`, `/releases` for repo facts.
- Separate official sources from trade or community articles; label price or feature claims from
  the latter as unverified.
- Check resource claims against the box before answering "is it heavy?": `free -m`,
  `systemctl show <unit> -p MemoryCurrent -p MemoryPeak -p MemoryMax`, and the cgroup
  `memory.stat` (anon vs file: page cache is reclaimable, so do not read it as use).

## Costing a self-hosted service for the box (Paperclip-style requests)

- Put three things side by side: the vendor's stated minimum (official docs only), the box's
  measured headroom (`free -m` available, swap used, `/proc/pressure/memory`, `nproc`, `df -h /`),
  and the repo rules that the service would break (nix-os AGENTS.md resource budget and the
  AWESOME-HERMES yardstick: no Node/Go/Docker/browser on the host, no PostgreSQL server for an
  app, no resident daemon unless needed). Verdict first, then the three tables.
- Do not install the service to measure it: the deny list blocks installs and it breaks the "no
  writes outside your own state" rule. Say its real use is unmeasured; never turn a vendor
  minimum into a measured figure.
- Do not run `nix search nixpkgs ...` on the box: it evaluates all of nixpkgs and spiked memory
  pressure on the 1 vCPU / 4 GB machine. Check packaging with DeepWiki or the web instead.
- Offer the off-box option (second VPS or the owner's computer) and what Hermes already has
  (profiles, kanban, cron, subagents) before any install plan.

## Loading the owner's skills (h0ffmann/skills) or other skill repos into Hermes

- External skills need no new code: every skill in `settings.skills.external_dirs` is a `/name`
  command (Telegram and others), and on Discord `/skill` with an autocomplete list (25 shown).
  Hermes ignores the `disable-model-invocation` frontmatter key, so "manual-only" skills can still
  load on their own; tell the owner.
- Pin with `pkgs.fetchFromGitHub` (rev + hash), not a git submodule: a flake reads its git tree
  without submodules unless the URL has `?submodules=1`, and enabling them in CI is a workflow edit.
  Hash: `nix-prefetch-url --unpack https://github.com/<o>/<r>/archive/<rev>.tar.gz`, then
  `nix --extra-experimental-features nix-command hash convert --hash-algo sha256 --to sri <base32>`.
  A wrong hash fails the CI build and prints the right one; say so in the PR.
- Copy an allowlist of skill folders with `pkgs.runCommand ... { allowedReferences = [ ]; }`
  (mirror `optionalSkills` in `hermes.nix`), set it in `external_dirs`, and add the derivation to
  `restartTriggers`. A missing path fails the build, so list paths from the pinned tree.
- Vet every skill before listing it. Leave out: a skill that makes a bilingual PR (conflicts with
  the English-only rule), tells the agent to merge or force-push, assumes Claude Code settings or
  an Obsidian vault, runs a script that needs `python3`/`pandoc`/`just`/Chrome/Docker/`psg`/`zk`
  (not on the box), duplicates another skill, is an empty stub, or shares a name with a bundled
  skill (the bundled one wins). Scan frontmatter and bodies with a script, then read the borderline
  ones. Document included and excluded skills, each with its reason, in the PR docs.
- Test without touching the live config: put `skills:\n  external_dirs: [<dir>]` in a temp
  `HERMES_HOME/config.yaml` and run `HERMES_HOME=<tmp> hermes skills list`; compare names with
  `find ~/.hermes/skills -name SKILL.md` for clashes. Copies out of the Nix store are read-only:
  `chmod -R u+w` before `rm -rf` in scratch.
- The pinned repo's own AGENTS.md rules (for example a `Co-Authored-By` trailer) do not govern
  this agent's PRs; add a short note to `hermes/AGENTS.md` saying which rules win over a skill.

## Owner plugin requests (pirsig-notes, pirsig-videos)

- Load the plugin skill first (`pirsig-videos:video-indexer`, `pirsig-notes:smart-notes`). The
  tools (`pirsig_video_fetch`, `pirsig_note_search`, `pirsig_video_check`, `*_submit`) are deferred:
  find them with `tool_search`, read the schema with `tool_describe`, call with `tool_call`.
- Fetch, write and check come first; show the owner the titles, kinds and `⚠` marks, and call a
  `*_submit` only after the owner says to send. The PR text is a fixed English template.
- When the fetch fails (YouTube's bot check on the VPS address), stop: tell the owner, offer a
  transcript pasted in chat or a fetch on their computer, and open no PR. Do not look for another
  route to the captions.
- If the owner then asks for Playwright or a headless Chromium to get past the check, do not
  write that PR. The block is on the address, not on a missing browser, so a local browser likely
  sees the same wall (say it is an expectation, not a test); passing a bot check is also what the
  stop rule forbids, and a browser on the box breaks the nix-os yardstick and the 1 GiB cap.
  Offer: cookies exported by the owner (a secret on the box, the owner's call), a transcript
  pasted in chat, a fetch on the owner's computer, or a paid cloud browser (needs a yes). Ask
  which one before any work, and offer to measure a browser's size only if the owner insists.

## Reviewing the owner's PR

For "review PR N" (with or without "add suggestions I can approve in 1 click"), load
`references/pr-review-suggestions.md`: post one `COMMENT` review with `suggestion` blocks for
small safe fixes, list decisions you cannot make for the owner, never approve. For "review with
OMP" use `references/omp-harness.md` (review-only run), and when the owner then says "fix it
yourself", the same file and `pr-review-suggestions.md` give the stacked-PR route: you may push only
`hermes/*`, so open a PR whose base is the owner's PR branch.

## Moving a service to a new host (DNS, order of steps)

For "which DNS records do I change" or "what do I do before I merge" on a host move, load
`references/host-cutover.md`: DNS checks through DNS-over-HTTPS, the one-record answer, the order
of stacked PRs, VPS prep and cutover, and what stays unverified.

## Dashboard errors (Chat tab, nginx auth)

For a pasted error from `hermes.piabrota.art` ("retrying in 30s", queued message), load
`references/hermes-dashboard.md`: reproduce the TUI's bootstrap to read the hidden verdict, then
present the fix options and let the owner choose.

## Inventory and deploy-state answers

- "List your skills / plugins / tools" is answered from live commands, not from memory of earlier
  PRs: others install plugins and skills between sessions. `skills_list`; `hermes plugins list`
  (a wide boxed table: filter rows with `grep -E '^│ [a-z]'`, `awk -F'│'`, and re-grep a name that
  the table truncated with an ellipsis); `omp --version`; `command -v <tool>`. Say which entries
  you did not know about, and that being listed does not prove a skill works (no credentials, no
  binary).
- "Is it live / did the deploy happen?" Check all three: `gh pr view <n> --json state,mergedAt`,
  `gh run list --workflow deploy.yml --limit 1`, and the box itself (`systemctl show hermes-agent -p
  ActiveEnterTimestamp`, the key in `~/.hermes/config.yaml`). A deploy run "in progress" may be a
  later merge: say you do not know which commit it is unless you read it.
- Offer a small real task (one skill command, one delegated run) as the proof for anything the
  checks above cannot show, such as whether the subscription accepts a newly pinned model ID.

## Tuning the omp coding worker

The owner's rule (2026-11-04): every task that writes or reviews code goes through omp, and the
layers must be visible. `docs/HERMES-OMP.md` in nix-os is the map; point the owner to it.

When the owner asks how to edit or improve the omp harness, load `references/omp-harness.md`: the
layers (task file, per-run flags, target repo context, skill, prompt file, overlay
`hermes/omp.yml`, wrapper, version), which setting wins, the levers that improve code quality on
Sonnet, and the rules that must not loosen. The owner wants every layer visible and a way to tune
it himself: answer with the layer table (file, who edits, when it takes effect), then offer the
PR (deploy first in the body) instead of listing options without a next step.

## Output hygiene

- Do not `cat` a large AGENTS.md, a big `git diff` or a whole docs site page into the tool output:
  repo AGENTS.md files re-load into context as subdirectory context and flood it. Use
  `grep -n`, `sed -n 'a,bp'`, `--stat`, or strip HTML with perl and `head -c`.
