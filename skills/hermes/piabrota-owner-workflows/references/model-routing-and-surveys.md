# Model routing, project surveys and service costing

Three topics that come up sometimes. Each is a procedure with its own checks.

## Routing Hermes work to cheaper models

- Hermes has no per-turn router. `smart_model_routing` is an unread stub. Real levers:
  `delegation.model` (all `delegate_task` subagents, global pin), `auxiliary.<task>.model` (side
  calls: `title_generation`, `skills_hub`, `vision`, ...), per-cron-job `model`, and the external
  `advanced-delegation` plugin (`model_map` routes the main model picks per task).
- Put mechanical work on the small model (subagents, titles, skill matching). Keep compression,
  the dangerous-command `approval` classifier (a guardrail), the post-turn review and every
  decision on the main model.
- The main model delegates only if SOUL.md tells it when. Add: check subagent output before use.
- Use a model ID found in the pinned source or in the live model list; say that run-time
  acceptance on the owner's subscription is unverified until a delegated run works.
- **Bumping a model ID (for example a newer Haiku).** Check three things before the PR:
  the ID is in `~/.hermes/provider_models_cache.json` (`grep -o 'claude-[a-z0-9.-]*'`; the
  provider's own list, so no web fetch is needed, and `web_extract` may be search-only) plus one
  web search for the vendor's announcement; `~/.hermes/config.yaml` is generated from nix-os
  `hermes.nix` (a hand edit is overwritten, so the change is a PR that deploys); and the full
  list of places that name the old ID (`git grep -n '<old-id>'` on nix-os `main`).
  Those places split into two groups with different owners: Hermes settings (`settings.auxiliary.*`,
  `settings.delegation.model`, and the docs, wiki pages and AGENTS.md rows that describe them in
  both languages) and omp's own roles in `hermes/omp.yml` (and the docs lines that describe
  those). Move the Hermes group together, because one docs row lists `delegation.model` and the
  `auxiliary.*` keys side by side. Leave `omp.yml` out unless the owner asks, because omp's model
  registry is pinned to its own version and may not know the new ID. Say in chat which group
  moved and which did not, and offer the second as a follow-up. Put the grep result as the
  "how to prove it is done" check in the omp task file.
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

## Surveying open-source tools for a media or ML pipeline (video, voice, image)

- Batch the facts in one `execute_code`. For code: `gh api repos/<o>/<r> --jq
  '[.full_name,.license.spdx_id,.stargazers_count,.pushed_at[:10],.archived]'`; print `full_name`,
  because a renamed repo redirects and the name you typed hides the new owner. For weights:
  `https://huggingface.co/api/models/<id>` and read `cardData.license`. The code licence is not the
  weights licence: an MIT repo can ship non-commercial weights. `NOASSERTION` and `other` mean read
  the licence file. A non-commercial weight fails any plan that earns money.
- Packaging: `nix eval --raw nixpkgs#<attr>.version`, then `.meta.license.spdxId` and
  `.meta.unfree`, one attribute at a time with `XDG_CACHE_HOME` set (cheap, unlike `nix search`).
  Unfree is out where `allowUnfree` is off.
- Measure the box with a tool already on it, not with vendor claims: a 10 s clip through `nice -n
  10 ffmpeg` at two presets under `/usr/bin/env time -f '%e s %M KB'`. Give the numbers as the best
  case for that clip shape, label every extrapolation, and mark speed figures from blogs as measured
  on another CPU.
- With no GPU on the box, split the design: CPU steps here (script, voice, captions, edit, render),
  GPU steps on the owner's PC (image and video generation). Add the new job's memory to the sum of
  the unit caps before you propose it, and run batch jobs one at a time.
- Apply the repo yardstick before ranking: no Node and no browser on the host (so a headless-browser
  renderer is out), Python plus ffmpeg from nixpkgs first.
- **A spec PR for a pipeline that Hermes runs later** (subagents plus omp) holds, in this order:
  the decisions the owner must make first (blocking each phase), the measured limits of the box,
  one table of stages with the files each reads and writes, a tool list with licences and install
  sizes (`nix build --dry-run`) and a do-not-use list, roles (Haiku subagents for read-only fan-out
  only, one omp at a time with a task-file template, the owner for review and merge), phases that
  each end with an artifact and a number, the install and smoke-check order, the platform risks,
  and a dummy pipeline built from tools already on the box that prints an `ARTIFACT OK` or
  `ARTIFACT FAILED` verdict line. No formal tests when the owner says so: the verdict line and a
  look at the output are the check. A spec that adds a row to `AGENTS.md` can push the file past
  30,000 characters: run `scripts/context-size.sh` and say so in the PR.
- For a platform product (YouTube), read the platform's own pages before the design: monetisation
  rules for mass-produced content, the synthetic-content label, API upload limits for unverified
  projects. Report them as risks with links, and build in disclosure and a human review; never
  design around detection.

## Costing a self-hosted service for the box (Paperclip-style requests)

- Put three things side by side: the vendor's stated minimum (official docs only), the box's
  measured headroom (`free -m` available, swap used, `/proc/pressure/memory`, `nproc`, `df -h /`),
  and the repo rules that the service would break (nix-os AGENTS.md resource budget and the
  AWESOME-HERMES yardstick: no Node/Go/Docker/browser on the host, no PostgreSQL server for an
  app, no resident daemon unless needed). Verdict first, then the three tables.
- Start with the repo: `ls docs/` of nix-os `main` (`gh api repos/piabrota/nix-os/git/trees/main?recursive=1`)
  for an existing research doc on the service, and read it with `gh api .../contents/docs/<X>.md
  -H 'Accept: application/vnd.github.raw'`. Such a doc is dated and written for one host: re-check
  every number on the host the owner names now. Re-read the host's `hosts/<name>/default.nix` and the
  AGENTS.md resource budget, which says a tool that only one host needs goes in that host's
  directory. A verdict for the 1-vCPU host does not carry to the 4-vCPU one; the rules it
  breaks may still need the owner's explicit exception, so name them.
- **A sum of `MemoryMax` values is a sum of ceilings, not use.** Never say "only N GiB is left"
  from the caps. Print both per unit, side by side (`systemctl show <u> -p MemoryCurrent -p
  MemoryPeak -p MemoryMax`) with `free -m` (used and available), and call the cap sum the worst
  case. When the owner doubts a number you gave, re-measure and correct your own wording in the
  first lines; his decision to remove a service stands on its own and needs no false premise.
- Say which host you measured. `kvm4-health` and `free -m` on this box measure the host Hermes
  runs on (flake name `piabrota2`), not the web host `piabrota`.
- Do not install the service to measure it: the deny list blocks installs and it breaks the "no
  writes outside your own state" rule. Say its real use is unmeasured; never turn a vendor
  minimum into a measured figure.
- Do not run `nix search nixpkgs ...` on the box: it evaluates all of nixpkgs and spiked memory
  pressure. Check packaging with `gh` instead: `gh api 'search/code?q=<name>+repo:NixOS/nixpkgs+filename:package.nix'`
  (a 0 count is weak evidence, say so), `gh api 'search/repositories?q=<name>+nix+language:nix'`
  for community flakes and modules, and `gh api repos/numtide/llm-agents.nix/contents/packages`
  (a daily-updated set of agent tools; read its `package.nix` and `hashes.json` for the version).
  Compare each candidate's licence, last push, stars, packaged version against upstream's newest
  release, and the nixpkgs channel it tracks against ours; a one-person flake that lags upstream
  and tracks unstable is a copy-the-module option, not a flake input.
- For a Node/npm service also read: upstream `engines`, whether it bundles FHS-linked binaries
  (an embedded database) that NixOS cannot run unpatched, its database modes, and how it starts
  agent CLIs (the service `PATH`, which user, whose credentials). Hermes as a child agent means a
  second install under the service user; the deny-list plugin belongs to the gateway, so say
  whether a child loads it only if you checked.
- A command text that holds an installer word (`npx` inside a `grep -E` pattern) trips the
  install deny pattern and the call is blocked: search for the shape (`onboard|quickstart`).
- Offer the off-box option (second VPS or the owner's computer) and what Hermes already has
  (profiles, kanban, cron, subagents) before any install plan. When the host has room, end with one
  concrete next step: a PR on nix-os with the module in `hosts/<name>`, a `MemoryMax`, bound to
  `127.0.0.1` first, a deploy warning in the body, and the one choice the owner must make
  (exposure: nginx hostname or Tailscale).
