---
name: lean-code
description: "Write, change or review code with the smallest correct diff. Question the need, reuse what exists, prefer the standard library, add no speculative abstraction. Use on any coding task, or for \"simplest\" or \"yagni\"."
---

# lean-code

The best code is the code that nobody writes. Lean means efficient, not careless. Read the
problem fully first. Then write as little as possible.

## The ladder

Stop at the first step that holds:

1. **Is it necessary?** A speculative need is skipped. Say so in one line.
2. **Does this codebase have it?** Reuse the helper, type or pattern that exists.
3. **Does the standard library do it?** Use it.
4. **Does the platform do it?** `<input type="date">` before a picker, CSS before JavaScript, a
   database constraint before application code, a Nix option before a script.
5. **Does an installed dependency do it?** Use it. Do not add a dependency for a few lines.
6. **Can it be one line?** Write one line.
7. **Only then**, the smallest code that works.

## Rules

- **Understand first.** Trace the real flow end to end before you select a step. The smallest
  change in the wrong place is a second bug.
- **A bug fix is at the root cause.** Find each caller of the function. One guard in the shared
  function is smaller than a guard in each caller.
- **Surgical diffs.** Change only the lines that the task needs. Do not reformat, rename or
  move other code.
- **No speculative abstraction**: no interface with one implementation, no factory for one
  product, no configuration for a value that never changes, no scaffold "for later".
- **Delete before you add.** Boring before clever.
- **State your assumptions.** If a choice changes data, a score or a public contract, ask.
  Otherwise select the answer of `AGENTS.md` or `DESIGN.md` and say which.
- **A deliberate shortcut gets a comment** that names its limit and the next step:
  `# lean: global lock, use a lock for each account if throughput matters`.
- **One check for each non-trivial path**: a branch, a parser, money or security. The smallest
  test that fails when the logic breaks. No test for a trivial line.

## Never simplify away

Input checks at a trust boundary, error handling that prevents data loss, security, accessibility,
and anything that the request asks for by name. Hardware and the physical world need a
calibration value, even when a model looks complete.

## Review mode

For a review, report only findings that remove code or risk:

| File:line | What to remove or replace | With | Why |

End with the number of lines that the changes remove. Do not report style that a formatter owns.

## Output

Code first. Then three short lines or fewer: what you skipped, and when to add it.
