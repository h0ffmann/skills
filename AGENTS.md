# AGENTS.md

Writing standard: ASD-STE100 (Simplified Technical English).

These are the rules for each AI agent that works in this repository or in a fork of it.
Humans must read them too. The rules are global. Do not put the facts of one project here.

## What this repository is

This repository is a set of agent skills. Each skill is one folder with a `SKILL.md` file.
The skills come from the owner's own projects. Each skill is written for those projects.
`README.md` is the index.

## Hard rules

These rules have no exceptions. A task that needs an exception stops. Then the agent asks the owner.

1. **ASD-STE100 in the whole repository.** Write each English file in ASD-STE100. Use short
   sentences, the active voice, simple tenses and one word for one meaning. Do not use
   semicolons or phrasal verbs. The `ste100` skill gives the full rules.
   Exception: a file copied as is keeps its text and its language. A pt-BR file follows the
   `ptbr-writer` skill.
2. **Few links, low cognitive load.** Put a link only where the reader must go next. Use a path
   in backticks for a file in this repository. Do not put a link in a skill body. A skill body
   holds instructions only: no credits, no history, no commit pins. Credits go in `README.md`.
   Keep each file as short as its job permits. One file does one job.
3. **No duplicate skills.** Before you add a skill, search `skills/` for one with the same job.
   If one exists, improve it. Two skills with the same job are a defect.
4. **Tailored, not vendored.** A skill here is written for the owner's projects. Do not copy a
   skill from another repository as is. Write a version that fits these projects, and give the
   credit in `README.md`. Exception: the skills of `piabrota/gramatico` and `archify` stay
   exactly as their source has them.
5. **Humans steer.** The thesis, the authors, the licence, the release and each conclusion
   belong to the owner. Do not change them without the owner's word.
6. **Never invent a fact.** Fetch a source before you cite it. Mark a claim that nobody checked
   with `⚠`. Never remove a `⚠` without doing the check.
7. **Never make a check weaker.** Do not remove, skip or loosen a test, a lint or a gate to get a
   pass. The failure tells you what to fix.
8. **No secrets.** Never commit a `.env` file, a key, a token or a cookie.
9. **No paid resources.** Never start a paid cloud resource without the owner's explicit approval.
10. **No production changes.** Never change a production database or a live host yourself.
    Write the change as a file. Then ask the owner.
11. **An agent never releases.** A tag makes a permanent DOI. Only the owner makes a tag.
12. **Never on `main`.** Each change goes on its own branch and lands through a pull request.
    The branch name and the PR title state the goal. They never start with a session id.
    An agent never merges.

## Responses

- Make each response clear and short.
- Use simple words and short sentences in plain English.
- The owner cannot see tool output. Show the important output in your text.
- Start top-level bullets without indentation.

## Behaviour

- For a major product or architecture decision, consult the owner.
- Do not add a dependency without the owner's approval.
- Assume that the owner changed things since your last look. Check the live state before you act.
- When the next step is clear and safe, do it. When the owner is the bottleneck, say so.
- Run independent work in parallel.

## Code quality

- Do not state how long a task takes.
- Focus on quality, simplicity, robustness and maintainability. The cost of time is not a reason.
- Keep the stack simple, popular and maintainable.
- Use the existing patterns and helpers before you add an abstraction.
- Write simple, readable, modular code with one clear owner for each part.
- Add a comment only for an intent, a trade-off or a constraint that the code cannot show.
- Pin each version: toolchains, lock files, submodules and actions.

## Bug fixes

- First, reproduce the bug as the user sees it, end to end.
- Prefer tests of behaviour to tests of private parts.
- For a bug, write the test that fails before you write the fix.

## Documentation

- Keep docs short, operational and based on sources.
- Do not make `AGENTS.md` or a README longer. Only the owner adds to them.
- An important subfolder with its own rules gets its own `AGENTS.md`. A parent `AGENTS.md`
  gives the broad rules and the index of child files.
- A page in two languages has a mirror. A change to one page changes the mirror in the same PR.

## Decision records

- A project can have a `docs/adr/` folder. Each ADR records the context, the decision and the
  result. The name is `docs/adr/0001-example-decision.md`.
- Do not change an old ADR to hide history. Add a new ADR that replaces it.
- When an important decision occurs, tell the owner that it needs an ADR. Do not write it yourself.

## Database

- Write each database change as a `.sql` file in `docs/database/`.
- In its comments, state what changed, why, how to apply it and how to verify it.

## Other contributors

- Other humans and agents work in the same repositories.
- Do not delete, revert or overwrite a change that you did not make.
- When an unrelated change appears, assume that another person made it.
- Do not open browser tabs or applications without the owner's approval.

## Git and GitHub

- `main` is the production branch.
- Each commit message is in English. It ends with two trailers and nothing else:

  ```
  Tested: <the command that ran and its result, or "n/a, documentation">
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

- In a worktree, copy the `.env` files from the primary checkout.

## Final self-review

- Read the diff before you declare that the work is done.
- Make sure that the diff does the full request and nothing that was not requested.
- State each risk, each decision for the owner and each follow-up that matters.

## Project basics

- Each project has an `AGENTS.md` file at its root. If it is missing, write one.
- Project skills go in `.agents/skills/`. `.claude/skills/` is a symlink to `.agents/skills/`.
- An open-source repository has a root `private/` folder in `.gitignore` for private context.

## Skills in this repository

- One skill is one folder under one category: `skills/<category>/<name>/SKILL.md`.
- The folder name and the `name:` field are the same. A name occurs only once in `skills/`.
- The `description:` field says what the skill does and when to use it, in one or two sentences.
- A skill body has at most about 150 lines. Put long reference data in a file next to it.
- After a change, run `just check`.
- `just link <dir>` puts each skill as a flat symlink into a skills folder of an agent.

## Forbidden

- Do not talk to other AI agents unless the owner asks for it.
- Do not interrupt other agents.
