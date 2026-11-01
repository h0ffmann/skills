# agents

Writing standard: ASD-STE100.

This folder is the index of the Claude agents that the projects of h0ffmann use, or plan to use.
An agent is a model that acts alone between a trigger and a result. It reads, decides and writes
a report, a comment, a commit or an answer. The skills have a different index, in `README.md`.

The plugin does not install these agents. Each agent stays in the repository that runs it. To use
one, copy its file into `.claude/agents/` of your project.

## Claude Code subagents

The eight files in this folder are copies, as is, of the subagents in the projects. Each file keeps
the MIT licence of its source repository. Each agent only reads and reports. A person or the
calling session makes the fix.

| Agent | Model | What it does | Source |
|---|---|---|---|
| [`revisor-proposta`](revisor-proposta.md) | opus | Scientific review of the UFRJ undergraduate project proposal: ABNT, register, citations (pt-BR) | ww3-gpu |
| [`security-reviewer`](security-reviewer.md) | opus | Security review of the diff of a branch: secrets, hooks, workflows, prompts | ww3-gpu |
| [`news-fact-check`](news-fact-check.md) | opus | First review of a news post: each claim against its link, pt-BR and English parity | marola-site |
| [`news-copy-review`](news-copy-review.md) | opus | Second review of a news post: language, voice, clarity | marola-site |
| [`mip-reviewer`](mip-reviewer.md) | fable | Reviews one PR of a MIP task stack against its task row | marola-devkit |
| [`mip-claims-auditor`](mip-claims-auditor.md) | haiku | Finds external claims without a source in a MIP | marola-devkit |
| [`jar-verifier`](jar-verifier.md) | sonnet | Checks a Kyo API against the pinned jar with `javap` | marola-app |
| [`design-reviewer`](design-reviewer.md) | inherit | Scores an answer to a system-design interview question against a hidden rubric | gcp-agentic-architect |

One more subagent comes from other authors. It is not copied here.

| Agent | Model | What it does | Source |
|---|---|---|---|
| [`gemini-research-expert`](https://github.com/MadsLorentzen/ai-job-search/blob/master/.claude/agents/gemini-research-expert.md) | sonnet | Web research with Gemini in headless mode | MadsLorentzen/ai-job-search, MIT |

## Headless agents of piabrota

These agents watch piabrota/nix-os and its VPS. Each one is a bash script that runs Claude Code
headless, with read-only tools. They run on the VPS as rax tasks and post as the GitHub App
`piabrota-ops`. The prompts are in [piabrota/agents](https://github.com/piabrota/agents).

| Agent | Runs | What it does |
|---|---|---|
| `deploy-doctor` | each tick | Finds why a deploy failed and opens one issue for each failed run |
| `deploy-fixer` | after `deploy-doctor` | Opens a fix PR when the change itself broke the deploy |
| `pr-reviewer` | each tick | Writes one review comment on each open PR, and edits it on each push |
| `mentions` | each tick | Answers each comment that names `@piabrota-ops` |
| `mirror-keeper` | each tick | Opens a PR that updates the pt-BR or English mirror of a changed document |
| `flake-annotator` | each tick | Gives the risk of a flake update PR |
| `feedback` | each tick | Turns a report marked wrong into a lesson in memory |
| `health-digest` | each day | Writes the health digest of the VPS |

## Claude Projects and their routines

| Routine | Project | Schedule | What it does |
|---|---|---|---|
| A2A inbox (`para:marola`) | Marola Agent | each 3 h | Answers the `[A2A]` issues for marola |
| Preparar post LinkedIn | Marola Agent | Mon to Wed | Gives a reminder the day before a post, with a topic |
| Lembrete LinkedIn | Marola Agent | Tue to Thu | Gives a reminder at the time of a post |
| A2A (`para:wave-forecaster`) | Wave Forecaster | each 3 h | The other side of the same channel |
| Daily deps update | Wave Forecaster | each day | Opens or drives one dependency update PR in ww3-gpu |
| Weekly settings snapshot | Wave Forecaster | Fridays | Copies the live project settings into ww3-gpu |

## Planned

| Agent | What it will do | State |
|---|---|---|
| `tcc-ufrj-writer` | Writes the text of the UFRJ undergraduate thesis (TCC). `revisor-proposta` reviews it | Planned. No file yet ⚠ |
| Post writer | Writes a draft news post in pt-BR and English for the two news reviewers | Idea, in marola-agents |
| Site UI agents | Design review, worst-case data, motion review and screenshots on marola.dev | Idea, in marola-agents |

## The runtime

[h0ffmann/rax](https://github.com/h0ffmann/rax) is the Rustic Agentic Runtime: a port of Google
AX to pure Rust. It runs agentic tasks on Agent Substrate. The agents of piabrota run on it, from
the piabrota/rax fork.

## Surveys and docs

Each link opens the raw Markdown file.

| Document | What it covers |
|---|---|
| [AWESOME-AGENTIC-ARCHITECT_202609.md](https://raw.githubusercontent.com/h0ffmann/gcp-agentic-architect/main/AWESOME-AGENTIC-ARCHITECT_202609.md) | Resources for the Google Cloud Professional Agentic Architect exam |
| [PROMPT-SERIES_202609.md](https://raw.githubusercontent.com/h0ffmann/gcp-agentic-architect/main/docs/PROMPT-SERIES_202609.md) | The seven sessions that built gcp-agentic-architect |
| [AGENTIC-ARCHITECT-MAPPING.md](https://raw.githubusercontent.com/h0ffmann/gcp-agentic-architect/main/marola/AGENTIC-ARCHITECT-MAPPING.md) | The exam guide against what marola has |
| [MIP-0057.md](https://raw.githubusercontent.com/h0ffmann/gcp-agentic-architect/main/marola/MIP-0057.md) | The Agentic Architect coverage for marola |
| [interviews/README.md](https://raw.githubusercontent.com/h0ffmann/gcp-agentic-architect/main/interviews/README.md) | System-design questions for agentic and RAG roles |
| [AGENT-STACK-SURVEY.md](https://raw.githubusercontent.com/marola-dev/marola/main/docs/4-Research-and-plans/AGENT-STACK-SURVEY.md) | Three agent toolkits, and a Q&A agent about marola |
| [AGENT-FRAMEWORKS-SURVEY.md](https://raw.githubusercontent.com/marola-dev/marola/main/docs/4-Research-and-plans/AGENT-FRAMEWORKS-SURVEY.md) | Multi-agent frameworks on the JVM, and Apache Pekko |
| [AWESOME-AGENTIC-ENGINEERING.md](https://raw.githubusercontent.com/marola-dev/marola/main/docs/4-Research-and-plans/AWESOME-AGENTIC-ENGINEERING.md) | The list of agent tools and practices of marola |
| [MIP-0017](https://raw.githubusercontent.com/marola-dev/marola/main/docs/MIPs/MIP-0017-agentic-tooling-survey.md) | Agentic tooling ideas from other repositories |
| [marola-agents](https://raw.githubusercontent.com/marola-dev/marola-agents/main/README.md) | The inventory of each agent of marola, in the product and in CI too |
| [piabrota/agents](https://raw.githubusercontent.com/piabrota/agents/main/README.md) | The headless agents of piabrota, their memory and their GitHub App |
| [rax](https://raw.githubusercontent.com/h0ffmann/rax/main/README.md) | The Rustic Agentic Runtime |

## Notes and essays

From h0ffmann/closed-source. Each link opens the raw Markdown file.

| Text | What it says about agents |
|---|---|
| [OUROBORIC.md](https://raw.githubusercontent.com/h0ffmann/closed-source/main/OUROBORIC.md) | Ouroboric in one note: software factories where agents build and humans steer |
| [OUROBORIC_RESEARCH.md](https://raw.githubusercontent.com/h0ffmann/closed-source/main/OUROBORIC_RESEARCH.md) | The research index of Ouroboric |
| [Spec-driven development](https://raw.githubusercontent.com/h0ffmann/closed-source/main/docs/4-ways-of-working/ouroboric/spec-driven-development.md) | How a spec drives the work of an agent |
| [Espionage and agents at scale](https://raw.githubusercontent.com/h0ffmann/closed-source/main/notes/202610122239-espionage-and-agents-at-scale.md) | An open question: intellectual property given to frontier models and agents leaks |
| [Private code and private science lose their value](https://raw.githubusercontent.com/h0ffmann/closed-source/main/notes/202610132127-private-code-and-private-science-lose-their-value.md) | Agents make reverse engineering fast |
| [Rhizome AI](https://raw.githubusercontent.com/h0ffmann/closed-source/main/notes/202610132129-rhizome-ai-one-founder-on-documents.md) | One founder, a product of agents on public documents |
| [picasso: determinism](https://raw.githubusercontent.com/h0ffmann/closed-source/main/notes/202610140142-picasso-determinism-and-the-long-run.md) | A study that an agent did, with its quotations checked again |
| [Why I write, 2026](https://raw.githubusercontent.com/h0ffmann/closed-source/main/essays/2026-why-i-write.md) | Agents that program with the author |
| [The hypotheses have no end](https://raw.githubusercontent.com/h0ffmann/closed-source/main/essays/2026-the-hypotheses-have-no-end.md) | Pirsig, closed source and agents |
| [New vs. better](https://raw.githubusercontent.com/h0ffmann/closed-source/main/essays/2026-new-vs-better.md) | Reverse engineering with agents |
