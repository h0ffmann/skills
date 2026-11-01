---
name: ste100
description: "Write or rewrite English text in ASD-STE100 Simplified Technical English. Use for docs, READMEs, PR bodies, tool descriptions, error messages, prompts and agent instructions, or when a text is dense, hedged or easy to misread. Not for pt-BR text (use ptbr-writer) or for creative copy."
---

# ste100

ASD-STE100 is a controlled form of English. It removes words with more than one meaning and
sentences with more than one structure. A human or an agent then reads the text in one way only.

## Two modes

Select a mode before you write. If the request does not give one, select it from the text type.

- **Strict**: procedures, runbooks, error messages, tool descriptions, prompts, agent rules and
  safety text. Apply all rules.
- **Descriptive**: READMEs, notes, PR bodies and changelogs. Apply all structural rules. Use the
  word rules as a direction, because prose needs some range.

## Structural rules

| Rule | Do | Do not |
|---|---|---|
| Sentence length | 20 words or fewer for an instruction, 25 or fewer for a description | Long sentences with many clauses |
| One instruction | "Open the file. Read line 3." | "Open the file and read line 3, then check it." |
| Active voice | "The script deletes the file." | "The file is deleted." |
| Simple tenses | "We received the report." | "We have received the report." |
| No phrasal verbs | "Start the job." "Remove the panel." | "Spin up the job." "Take off the panel." |
| No semicolons | Two sentences | A semicolon of any kind |
| Short noun groups | Three nouns or fewer: "fuel pump valve" | "high pressure fuel pump inlet valve" |
| No ellipsis | Keep the subject, the verb and the article | "Files not saved will be lost." |
| Paragraphs | One topic and six sentences or fewer | A paragraph with many topics |
| Lists | A list for three steps or more | A sequence inside one sentence |

Keep a compound tense only when it carries a fact that a simple tense cannot. Example: "The job
may have failed." Keep the hedge. Do not change it into "The job failed."

## Word rules

- **One word, one meaning.** Select one word for one thing and use it each time. Do not change
  "check", "verify" and "confirm" for the same action.
- **A verb, not a noun.** "Analyze the log", not "perform an analysis of the log".
- **Plain words.** "Use", not `utilize`. "Start", not `kick off`.
- **Define a technical word** the first time it occurs, in bold, with one plain sentence.
- **Fixed modality.** "Must" is an obligation. "Can" is a capability. A probability is a number.
- **No marketing words**: `seamless`, `robust`, `powerful`, `cutting-edge`, `effortless`, `world-class`.
- **Keep the articles** ("a", "an", "the"). They make translation easier.

## Process

1. Read the text once for its meaning. Do not rewrite before you understand it.
2. Examine each sentence. Find each broken rule.
3. Rewrite each bad sentence. Keep every fact, number, condition and hedge.
4. If a shorter form loses precision, keep the long form.
5. Never add a fact, a cause or a frequency that the source does not state.
6. If the text already obeys the rules, say so. Do not change correct text.

## Two languages

A page with a pt-BR mirror says the same facts in both languages. Write the pt-BR side with the
`ptbr-writer` skill. Change the two pages in the same PR.

## Output

By default, give the rewritten text only. Add one line `Kept as is: <phrase>, <reason>` when you
kept a long form on purpose.

When the request asks for the reasons, give a table: rule, original, rewrite. Then give the mode
and the number of changes.

## What it does not do

- It does not make weak content true or useful. It only fixes the form.
- It does not use the official ASD dictionary. That dictionary is not free to copy. When exact
  approved words are necessary, get the standard and check each word against it.
