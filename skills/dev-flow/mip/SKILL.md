---
name: mip
description: "Write or revise an Improvement Proposal (MIP), a numbered design document for a non-trivial feature, integration or architecture change, written before the code. Use when the user says \"MIP\", \"improvement proposal\", \"propose a feature\" or \"write up a design for\"."
---

# mip

A MIP designs a non-trivial change before anyone builds it. It says what, why, how it fits the
existing patterns, what was checked, and how we will know that it works.

## When to write one

- A new external data source or API.
- A new pluggable integration or a new module.
- A change to a score, to a safety output or to what a user sees.
- Any autonomous or proactive behaviour.

Not for a bug fix, a doc fix, a refactor with no change in behaviour, or a one-file change.

## Steps

1. **Find the folder and the template.** Use the repository's `docs/MIPs/` (or `docs/mips/`)
   and its `TEMPLATE.md`. The repository template wins over the shape below.
2. **Select the number.** Take the highest number in the index and in each open PR that adds a
   MIP. Add one. Pad it to four digits: `MIP-0042-<kebab-slug>.md`.
3. **Read first.** Read `AGENTS.md`, the architecture docs, the phase plan, the existing MIPs
   and the source files that the change touches.
4. **Check each external claim.** For a data source, a library or an API, fetch its page.
   Record its format, update rate, licence and key. A source that you could not check goes in
   "Open questions", not in "Design".
5. **Write the MIP.** Keep each section. Write "None" for an empty one. About 250 lines or fewer.
   Put long research in an appendix.
6. **Add it to the index**: number, title, status, date, effort, gain, verdict.
7. **Do not build it in the same change.** The MIP merges as `Draft` or `Accepted`. The
   implementation is a later PR that sets the status to `Implemented` and names the PR.
8. **After the merge**, make sure that the status names the PR that really merged
   (`git log origin/main --grep="MIP-NNNN"`).

## House rules

- **Local first, cloud as an option.** Each new data path has a free, local default. A paid
  service needs its cost stated and the owner's approval.
- **Safety logic stays deterministic** and outside the LLM, with unit tests.
- **No unsourced fact reaches a user.**
- **Phase discipline.** State the phase and each missing earlier step.
- **Honest status words**: "checked live", "written, not run", "not checked".

## Shape

```markdown
# MIP-NNNN: <Title>

| Status | Draft / Accepted / Implemented / Rejected / Superseded by MIP-NNNN |
| Author | <name, with agent and model> |
| Created | YYYY-MM-DD |
| Phase | <n> |
| Effort | S / M / L / XL, with one clause why |
| Gain | user value / infra and dev loop / cost and ops, one clause each |
| Verdict | do next / do when X lands / cheap win / expensive, defer / park |
| Depends on | prose for humans |
| Blocked by | MIP numbers only, or none |
| Risk | the one thing most likely to make it not worth it |

## 1. Summary            two to four sentences
## 2. Motivation         the real gap, with real output
## 3. User-visible change  before and after, the real output shape
## 4. Sources and dependencies reviewed   format, rate, licence, key, checked or not
## 5. Design             modules, files, types, the local default and the option
## 6. Safety impact      exact thresholds, or None
## 7. Verification plan  named tests, live checks, what "done" is
## 8. Risks and limits
## 9. Alternatives       including "do nothing"
## 11. Open questions    each with a default, and each follow-up MIP
## Appendix: Checked live (URL, date, what it returned) and Not checked
```

Section 10 does not exist, so section 11 is always "Open questions".

## Effort

S is one file and no new dependency. M is a few files or one small type. L is a new module, a
store or a CI workflow. XL is more than one of these, or a new surface for users.
