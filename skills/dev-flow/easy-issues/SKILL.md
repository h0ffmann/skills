---
name: easy-issues
description: "Find small open issues that are ready for an agent, and solve each one as its own tested PR. Works for members and for contributors through a fork. Use for /easy-issues."
disable-model-invocation: true
---

# easy-issues

A person types this skill. It opens PRs on repositories that other people maintain.

**Never**: merge, close or label an issue, approve a workflow run, push to `main`, use
`--no-verify`, or touch a secret, a paid resource or a repository setting.

## Step 1: who runs it

```bash
gh auth status                                         # no login: stop
gh api repos/<owner>/<repo> --jq .permissions.push
```

- `true`: **member**. Push branches to the repository.
- `false`: **contributor**. Fork once (`gh repo fork <owner>/<repo> --clone=false`). Push to the
  fork. Open the PR with `--repo <owner>/<repo> --head <login>:<branch>`. A maintainer must
  approve the CI of a fork PR. Say so in the report.

## Step 2: the queue

Scope: no argument is the current repository. An owner name is each repository of that owner.
`repo#N` is exactly those issues.

Keep an issue only when all of these are true:

- It has the `agent-ready` label. A member can widen this when the owner asks. A contributor
  cannot.
- It is `size/S` or smaller, or plainly under 100 changed lines.
- It is not a MIP, a MIP task, a question, a duplicate or research. Nobody else has it.
- No open PR fixes it (`gh pr list --search "<N> in:body" --state open`).
- After `gh issue view N --comments`, the fix is clear. It needs no human decision, secret,
  account or design choice. It stays inside one repository. It deletes no data.

Show the short list, one line for each issue, before Step 3.

## Step 3: one helper for each repository

Each helper gets the short list of its repository and these rules:

- Clone to a short path (`/tmp/ei-<repo>`). Some build tools fail on long paths.
- Read the `AGENTS.md`, `CLAUDE.md` and `.claude/rules/` of the repository first. Obey them.
- Use `nix develop -c <command>` where a flake exists.
- For each issue: a branch `fix/<N>-<slug>` from a fresh `origin/main`. For a bug, the failing
  test first. Then the smallest fix. Then the full gate of the repository.
- If a gate cannot run here (Docker, a GPU), name it in the PR. Do not skip it silently.
- The commit body has `Fixes #N`, then the trailers that the repository asks for.
- Use the PR template of the repository, or its PR recipe.
- If the fix grows past a quick win, stop, open no PR, and report the reason.

## Step 4: report

One table for all repositories: issue, PR link or "skipped: reason", and each gate that could not
run. For contributors, add the fork CI note and a list of good issues that need the
`agent-ready` label from a maintainer.
