---
name: agentskills-checker
description: "Check skill folders against the Agent Skills specification with a script: frontmatter, names, limits and file references. Use before a commit that adds or changes a SKILL.md, or to audit a skill collection. For skill quality, use skill-validator."
---

# agentskills-checker

This skill makes the format check repeatable. The script holds the rules. Do not check a field
by eye, and do not copy the rules into a reply.

## Run

The script needs `python3` only. Give it a skill folder or a folder of skills. The path of the
script is relative to this skill folder.

```bash
python3 scripts/agentskills_check.py <path>...           # a skill folder or a folder of skills
python3 scripts/agentskills_check.py --strict <path>...  # a warning is a failure too
python3 scripts/agentskills_check.py --self-test         # test the script
```

Each finding is one line. The last line is a summary.

```text
ERROR skills/x/SKILL.md: `name` is missing
WARN skills/y/SKILL.md: `disable-model-invocation` is a client extension, not in the specification
50 skills, 1 errors, 1 warnings
```

Exit 0 means no failure. Exit 1 means a failure. Exit 2 means wrong arguments.

## Findings

An `ERROR` breaks the specification. A strict client can refuse to load the skill.

| Error | Fix |
|---|---|
| `SKILL.md` or the frontmatter is missing | Add the `---` block at line 1 |
| `name` or `description` is missing or empty | Add it |
| `name` has a wrong form | Use `a-z`, `0-9` and single hyphens, at most 64 characters |
| `name` is not the folder name | Change one of them, then update each reference to it |
| `description` has more than 1024 characters | Make it shorter. Move workflow steps to the body |
| `compatibility` has more than 500 characters | Make it shorter |
| A colon in a plain value | Put the value in double quotes |
| A field is not in the specification | Move it into `metadata`, or remove it |
| `metadata` is not a map of strings | Use one level of string values |

A `WARN` needs a decision, not always a change.

| Warning | Decision |
|---|---|
| A client extension | Keep it if a client needs it at the top level |
| A file name does not exist | Fix the path. Keep it only if it names a file of the target project |
| A file is more than one level deep | Move the file up |
| Too many lines or tokens | Move reference data into `references/` |

Keep `disable-model-invocation: true` at the top level. Claude Code does not read it from
`metadata`, so a move lets the agent start a manual skill by itself.

## Workflow

1. Run the script on the changed skill folders.
2. Fix each `ERROR`. Decide each `WARN`.
3. Run the script again. Stop when it exits 0.
4. Report the summary line and each warning that you kept.

Do not remove a rule from the script to get a pass. If a rule is wrong, compare it with the
specification at `agentskills.io/specification`, then fix the script and its self-test.

## Limits

The script has a small YAML parser, because the standard library has none. It accepts the subset
that the specification needs. It checks the form, not the quality of a skill.
