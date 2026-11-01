---
name: handoff
description: "Save and resume work sessions as handoff notes in an Obsidian vault, and keep one digest note for each project there. Use for \"save this session\", \"write a handoff\", \"load my last context\" or \"what was I working on\". Not for decisions (use mip) or conventions (use AGENTS.md)."
---

# handoff

The repository is the source of truth. The vault holds only two things that the repository does
not hold: handoff notes for a cold session, and one digest note that links to the project docs.

## Where the vault is

```bash
V="${OBSIDIAN_VAULT:-$HOME/Documents/2nd-brain}"; P="$(basename "$(git rev-parse --show-toplevel)")"; D="$V/$P"
```

`$V` must exist and contain `.obsidian/`. If it does not, say so and stop. Never make a vault in
another place. In a sandbox, the vault is often not visible. Then do the save from the host.

## Resume

1. **Try the agent tool first.** On the same machine, `claude --continue` or `claude --resume`
   gives the full transcript. That is better than a summary. Say which one fits.
2. Otherwise, list the five newest `$D/context/*.md` files. Let the person select one.
3. **Check the note against the repository.** Does the branch exist? What merged since the date
   of the note (`git log --since`)? Are its PRs merged or closed?
4. Give the state, the next steps and the open questions. Mark each one "still true" or
   "changed". Do not paste the note.

## Save

1. The topic is the branch name. Ask only when the branch is `main`.
2. Write `$D/context/YYYY-MM-DD-<topic>.md`. The same topic on the same day updates that file.
3. Write for a reader with no context. Use paths from the repository root. No secrets.

```markdown
---
project: <project>
branch: <branch>
date: YYYY-MM-DD
tags: [<project>, handoff]
---
# <topic>

Resume: `claude --resume <session name>` on <machine> · digest: [[<project>]]

## Goal
## Done            commits and PRs, what changed and why
## Current state   files changed, test commands and their result
## Next steps      in order
## Open questions
## Do not retry    what failed, and why
## Key files       path, and why it matters
```

## Digest

Write `$D/<project>.md` again from nothing each time. Nobody edits it by hand. It holds:

- what the project is, in one line from `AGENTS.md`, and the repository URL.
- open PRs and local branches ahead of `origin/main`.
- MIPs that are not `Implemented`.
- the last ten commits on `main`.
- the handoff notes as `[[wikilinks]]`, newest first.

## Offer

After a long session, before a `/clear`, or when a PR goes up, offer one time: "Save a handoff to
the vault?" Write nothing without a yes.
