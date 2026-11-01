# ouroboric

Writing standard: ASD-STE100.

The skills in this folder come from Ouroboric, an open project of self-improving software
factories by ouroboric-dev (the ideas are Bruno Valério's). Their code is AGPL-3.0 and their docs
are CC BY 4.0. Three skills are this repository's own text. One skill is copied as is.

| Skill | Source |
|---|---|
| `sharingan` | The idea of REA (read, evaluate, adopt) in `ouroboric`, and `ouroboric-sharingan` in h0ffmann/picasso |
| `retro` | The idea of the `retro` skill of `havamal` |
| `writing-styles` | The idea of `docs/4-ways-of-working/writing-styles.md` of `ouroboric` |
| `ponytail-review` | [havamal/skills/ponytail-review](https://github.com/ouroboric-dev/havamal/tree/main/skills/ponytail-review), as is. MIT, by DietrichGebert |

## The skills of ouroboric-dev

Read on 2026-11-01, at havamal commit `144be35`. Only `havamal` has skills. Both are vendored
there from other authors, with `skills.lock`.

| Skill | Upstream | Licence | Here |
|---|---|---|---|
| [`ponytail-review`](https://github.com/ouroboric-dev/havamal/tree/main/skills/ponytail-review) | DietrichGebert/ponytail | MIT | As is, in `ponytail-review` |
| [`retro`](https://github.com/ouroboric-dev/havamal/tree/main/skills/retro) | mattpocock/skills | MIT | Our own version, in `retro` |

## The public repositories of ouroboric-dev

Read on 2026-11-01. All are at `github.com/ouroboric-dev/<name>`.

| Repository | Licence | What it is |
|---|---|---|
| `ouroboric` | CC-BY-4.0 | The charter, the standards, the journal and the brand |
| `yggdrasil` | AGPL-3.0 | An open software factory. Agents build, humans steer (design phase) |
| `asgard` | AGPL-3.0 | The company factory that runs on Yggdrasil (design phase) |
| `odin` | AGPL-3.0 | The orchestrator: the graph engine and the `ygg` CLI |
| `gungnir` | AGPL-3.0 | The contract: Go interface types and JSON schemas |
| `jormungandr` | AGPL-3.0 | The loop: build, check and fix, with budgets and escalation |
| `gleipnir` | AGPL-3.0 | The harness: agent adapters, the sandbox driver and the check runner |
| `voluspa` | AGPL-3.0 | The graph library: one folder for each graph, with its prompts |
| `havamal` | AGPL-3.0 | The skill library: vendored skills with a lock file, and own skills with evals |
| `mimir` | AGPL-3.0 | The public benchmark kit: briefs, task format, suites and results |
| `helheim-go` | AGPL-3.0 | The Go flavour for backends |
| `midgard-react` | AGPL-3.0 | The React flavour for web frontends |
| `niflheim-local` | AGPL-3.0 | The local flavour: services for one machine with no cloud |
| `ouroboric-packages` | MIT | The official packages on PyPI and crates.io that hold the name |
| `.github` | MIT | The profile and the defaults of the organisation |
