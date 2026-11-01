---
name: citation-score
description: "Score how much of a text is cited, from 0% to 100%, with a coloured verdict. Use to score the citations of a phrase, a text, a file or a URL."
---

# citation-score

How much of a text stands on a source, and how much is the writer's own? This skill counts it.
The count is approximate.

## Run it

```sh
scripts/citation-score.sh "a phrase, or a longer text"
scripts/citation-score.sh path/to/text.md
scripts/citation-score.sh 'https://example.org/page'
pbpaste | scripts/citation-score.sh -
scripts/citation-score.sh --color=never --list=10 notes/index.md
scripts/citation-score.sh --self-test
```

The path is relative to this skill folder. The script needs bash, awk, sed and curl only.

## The scale

| Score | Verdict | Colour |
|---:|---|---|
| 100% | PERFECT. HIGHEST MATURITY LEVEL. | green, bold |
| 75% to 99% | STRONG. Almost every sentence stands on a source. | green |
| 50% to 74% | FAIR. Half of it stands on a source. | yellow |
| 25% to 49% | THIN. Most of it is yours, or unsupported. | yellow |
| 1% to 24% | WEAK. Nearly all of it is yours, or unsupported. | red |
| 0% | POOR. 2 DIGIT IQ. | red, bold |

The verdict is about the text, never about the person.

## What it counts

The script splits the text into sentences of three words or more. It does not count headings,
code blocks, comments, front matter or table rules. A sentence is *cited* when it has one of
these marks: a pandoc key (`[@smith2016]`), a DOI, a URL, a Markdown link, a wiki link, a
footnote, a numbered reference, an author and a year, or a line that starts with `Source:`.

## Show the result in a chat

A chat does not show terminal colours. Run with `--color=never`. Then draw the bar with ten
squares: 🟩 for each 10% when the score is 75% or more, 🟨 from 25% to 74%, 🟥 below 25%, and ⬜
for the rest. Then give the percentage and the verdict in bold, the counts and the sentences
with no mark.

Example: `🟨🟨🟨🟨⬜⬜⬜⬜⬜⬜ **38% cited: THIN.** 16 of 42 sentences have a citation mark.`

## Limits

State these limits with each score:

1. It counts marks, not truth. An invented citation gets the same score as a correct one.
2. One mark covers one sentence. A paragraph with one citation for three sentences gets 33%.
3. A sentence with no mark is not always a fault. It can be the writer's own idea.
4. 100% is not the goal for every text. A text of citations only has no thesis.
5. On a web page, navigation links count as marks. Thus a URL gets a high score.
