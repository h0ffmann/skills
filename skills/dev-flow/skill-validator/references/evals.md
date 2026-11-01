# Skill evals

## Contents

- Test cases
- Runs
- Grades
- Patterns

## Test cases

Keep the test cases in `evals/evals.json` in the skill folder. Start with two or three cases. Add
the assertions after the first run, because the first output shows what a good result is.

```json
{
  "skill_name": "csv-analyzer",
  "evals": [
    {
      "id": 1,
      "prompt": "there's a csv in my downloads called customers.csv, can you clean it?",
      "expected_output": "A clean CSV, and a count of the rows with no email.",
      "files": ["evals/files/customers.csv"],
      "assertions": ["The output has a count of the rows with no email"]
    }
  ]
}
```

- Use realistic prompts with file names and context. Vary the form and the level of detail.
- Include one edge case, such as a malformed input.
- An assertion must be specific and observable. "The output is good" is too vague. An exact phrase
  is too brittle.
- Leave style to human review. Do not write an assertion for it.

## Runs

Run each case two times, with a clean context for each run.

- For a new skill, the baseline is a run without the skill.
- For a change, the baseline is a copy of the previous version.

Put the results in a workspace folder next to the skill folder, not in the skill folder.

```text
<skill>-workspace/iteration-1/<eval-name>/with_skill/outputs/
<skill>-workspace/iteration-1/<eval-name>/without_skill/outputs/
```

Each run also records its tokens and duration. A better result can cost too many tokens.

## Grades

Record pass or fail for each assertion, with evidence from the output. A section title with no real
content is a fail. Use a script for each mechanical assertion.

```json
{
  "assertion_results": [
    {"text": "The output has a count", "passed": true, "evidence": "Line 3: 12 rows have no email"}
  ],
  "summary": {"passed": 1, "failed": 0, "total": 1, "pass_rate": 1.0}
}
```

Then compare the configurations: the pass rate, the tokens and the time. Standard deviation has a
meaning only with many runs of each case. Before that, compare the raw counts.

## Patterns

| Pattern | Action |
|---|---|
| An assertion passes in both configurations | Remove it. It shows no value |
| An assertion fails in both configurations | Fix the assertion or the test case first |
| An assertion passes only with the skill | Find which instruction helped, and keep it |
| The result changes between runs | Add an example, or make the instruction more specific |
| One case costs much more than the others | Read its transcript to find the wasted work |

A human reviews the outputs next to the grades, and records specific feedback. "The chart has no
axis labels" is useful. "It looks bad" is not useful. Change the skill from the failed assertions,
the feedback and the transcripts. Run all the cases again in a new `iteration-N` folder.
