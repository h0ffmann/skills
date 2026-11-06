---
name: github-better-outreach
description: "Writes a ready-to-run gh command that sets the 20 best GitHub topics, and a better description, for one repository. Use when a person asks for topics, tags, discoverability or outreach of a repository."
---

# github-better-outreach

The output is a command that the owner runs. Do not run it. Run it only when the owner asks.

## Step 1: read the live state

```bash
gh api repos/<owner>/<repo> --jq '{description, homepage, topics, language, stars: .stargazers_count}'
gh api repos/<owner>/<repo>/languages
```

Then read the `README.md`, `AGENTS.md` and the manifests (`Cargo.toml`, `package.json`,
`pyproject.toml`, `flake.nix`, `go.mod`). Find:

- What the project is, in one noun phrase. Example: "an agentic runtime on Kubernetes".
- Who searches for it. Example: people who run AI agents, Rust users, platform engineers.
- The main language, the main frameworks and the platform it runs on.

## Step 2: the rules of the project

- Read `AGENTS.md` and `CLAUDE.md` for names that the owner forbids. Some projects never name the
  upstream project, its organization, its users or its issues. A forbidden name is never a
  topic, and it never occurs in the description.
- If the owner said such a rule in the conversation, obey it too.

## Step 3: the candidates

Make about 30 candidates in four groups. Keep a balance in the final 20.

| Group | Share of 20 | Examples |
|---|---|---|
| What it is (the category) | 6 to 8 | `agent-runtime`, `ai-agents`, `static-site-generator` |
| The problem it solves | 4 to 6 | `orchestration`, `sandbox`, `forecasting` |
| The language and the stack | 4 to 6 | `rust`, `tokio`, `grpc`, `postgresql`, `nix` |
| The platform and the audience | 2 to 4 | `kubernetes`, `cloud-native`, `self-hosted`, `cli` |

GitHub limits: at most 20 topics. Each topic has lowercase letters, digits and hyphens only. It
starts with a letter or a digit. It has at most 50 characters.

## Step 4: measure the traffic

For each candidate, count the repositories that use it:

```bash
for t in rust ai-agents agent-runtime; do
  printf '%s %s\n' "$t" "$(gh api -X GET search/repositories -f q="topic:$t" --jq .total_count)"
done
```

- A large count (more than about 10,000) brings readers, but the repository is hard to find in it.
- A count of 100 to 10,000 is the best zone. Readers are there, and the repository is visible.
- A count of less than about 20 brings almost no readers. Keep it only if it is the exact name
  of the category.
- If two topics have one meaning (`k8s` and `kubernetes`), keep both only when both have
  traffic. Otherwise keep the one with more traffic.

The search API has a rate limit. Put about one second between the calls if it refuses.

## Step 5: remove the weak topics

Remove each topic that:

- Is a forbidden name from Step 2.
- Is the name of a company or a cloud that the project does not need to run.
- Is a vanity word with no traffic, such as `foss`, `awesome-project` or the owner's name.
- Repeats another topic with no new readers, such as `rust-lang` next to `rust`.
- Says something that the code does not do.

## Step 6: the output

Give one command that replaces all topics. `PUT` replaces, so old topics that are not in the
list go away.

```bash
gh api -X PUT repos/<owner>/<repo>/topics \
  -H "Accept: application/vnd.github+json" \
  -f "names[]=topic-1" -f "names[]=topic-2" -f "names[]=topic-3"
```

If the description is weak, give a second command. Keep it under 120 characters. Start with
what the project is. Put the important search words first.

```bash
gh repo edit <owner>/<repo> --description "..." --homepage "https://..."
```

Then, in short text:

- The topics that you removed, and the reason for each group.
- The topics that you added, and the reason for each group.
- One swap that the owner can make, if a choice was close.

## Step 7: after the owner runs it

Read the topics again and show them:

```bash
gh api repos/<owner>/<repo>/topics --jq .names
```
