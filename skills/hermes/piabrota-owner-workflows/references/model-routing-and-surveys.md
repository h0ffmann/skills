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
  pressure. Check packaging with DeepWiki or the web instead.
- Offer the off-box option (second VPS or the owner's computer) and what Hermes already has
  (profiles, kanban, cron, subagents) before any install plan.
