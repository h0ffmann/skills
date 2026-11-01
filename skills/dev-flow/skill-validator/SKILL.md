---
name: skill-validator
description: "Write, review, debug or evolve an agent skill. Use to create or edit a SKILL.md, improve a description, fix a missed or wrong activation, or test a skill before it ships. For the format check only, use agentskills-checker."
license: MIT
---

# skill-validator

A skill costs tokens in each session and in each use. It must add what the agent does not know.
Select a mode, then follow its steps. Read `references/rules.md` when you write or review a body.
Read `references/evals.md` when you test or evolve a skill.

## Modes

- **Write**: the skill does not exist.
- **Review**: the skill exists, and the request is a quality verdict.
- **Debug**: the skill does not start, starts at the wrong time, or gives a wrong result.
- **Evolve**: the skill works, and real use shows gaps.

## First checks

1. Search the skills folder for a skill with the same job. If one exists, improve it.
2. Read the rules of the repository. They can set stricter limits than this skill.
3. In the repository of this skill, also obey these limits:
   - Each description has at most 300 characters. Each `SKILL.md` has at most 150 lines.
   - The text is in ASD-STE100. A skill body has no links, no credits and no history.
   - `README.md` and `www/tags.txt` need one entry for each new skill.

## Write

1. **Find the gap.** Run the agent on real tasks. A skill candidate is a place where it fails
   again or needs the same correction.
2. **Select the pattern.**
   - Capability: the agent cannot do X. Write a thin wrapper of a script or CLI.
   - Process: the output or the method of the agent is bad. Write a procedure with checks.
3. **Write the description first.** Use this pattern: `[Capability]. Use for [tasks or situations].`
   Add a boundary only if it prevents confusion with a related skill.
4. **Write the smallest body that works.** Use real material: runbooks, fixes and past failures.
   Add a line only when a test shows the gap.
5. **Move detail out.** Put long data in `references/`, and fragile steps in `scripts/`. Say when
   the agent must read or run each file.
6. **Test** as the `Test` section says. Then do the `Ship checklist`.

## Review

1. Run `agentskills-checker` on the skill folder.
2. Read each file of the skill, with `references/rules.md` next to it.
3. Report each finding with its file, its line, the rule and a fix. Sort them by cost to the user.
4. Do the `Ship checklist`. Report each item that fails. Do not change the skill unless the
   request asks for a change.

## Debug

Find the failure class first. The fix is different for each class.

| Symptom | Likely cause | Fix |
|---|---|---|
| The client does not list the skill | Invalid YAML, or a `name` that is not the folder name | Run `agentskills-checker` |
| The skill does not start | The description is vague or has the wrong terms | Name real tasks, inputs and file types |
| The skill starts at the wrong time | The description is too wide | Add a boundary |
| The skill starts, but the result is wrong | The body has a gap | Add a step, an example or a check |
| The result changes between runs | The body is ambiguous | Add an example, or move the step to a script |

Then apply these rules:

- Examine whether the runtime loaded `SKILL.md`. Valid YAML is not proof, and the report of an
  agent is not proof.
- Use a new session for each activation test, because some clients read skills only at start.
- Test on the weakest model that you will use. A strong model hides a vague skill.

## Evolve

1. Collect the signals: the failures, the corrections of the user, and the traces of real runs.
2. Keep a copy of the current version as the baseline.
3. Change the smallest part that explains the most signals. Fix the cause, not one prompt.
4. Remove each instruction that the traces show as wasted work.
5. If runs write the same helper again and again, put it in `scripts/`.
6. Run the tests against the baseline. Keep the change only if the results are better.
7. Stop when the results do not improve, or when the reviews show no problems.

## Test

Test the two parts separately. `references/evals.md` gives the formats.

- **Activation**: use realistic requests that do not name the skill. Also use near misses, which
  share keywords but must not start the skill.
- **Execution**: start the skill by name, and compare the result with a run without the skill.
- **Adversarial**: ask a second model which edge cases break the skill. Fix the real ones.

## Ship checklist

Report each item as pass, fail or not tested. Do not mark an item pass without evidence.

- [ ] `agentskills-checker` exits 0.
- [ ] The description starts with the capability and has real triggers.
- [ ] A boundary separates the skill from each related skill that can compete with it.
- [ ] The skill does one job and composes with related skills.
- [ ] The folder has no README, changelog or install guide.
- [ ] The text has no fact that a date can make false.
- [ ] Each path is relative and uses forward slashes.
- [ ] Each step that needs a state checks the state first.
- [ ] Each step that can fail says how to see the failure and what to do.
- [ ] The skill states a verify, fix and verify again loop.
- [ ] The skill shows the output format, if another tool reads the output.
- [ ] Activation and execution are tested, on a weak model and on a strong model.
- [ ] The change is in version control and is reviewed.
