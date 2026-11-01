---
name: pirsig
description: "Drive Pirsig (psg), the PARA and Zettelkasten second brain, and its Hippo rhizomes. Capture and link notes, file projects and tasks, ingest arXiv or RSS, sync Obsidian. Use for Pirsig, psg, Hippo or a fixation."
---

# pirsig

Pirsig keeps two things apart. **PARA** (areas, projects, tasks, resources, archive) is where the
work is. The **slip box** (notes with IDs such as `1`, `1a`, `1a1`) is what the person thinks.
They meet by link, never by folder. Run `psg`. Add `--json` to read an output.

**The brain belongs to the person.** Write only what they said, in their words. Never invent a
note, a source or a link reason. Ask before a delete (`-d`). Offer the archive first. Nothing
leaves the brain unless they ask.

## Recipes

| They want | Run |
|---|---|
| to note a thought | `psg note -c "the thought"` (fleeting, in the inbox) |
| a note in their words | `psg note -c -t "A claim, as a sentence" -k permanent -b "..."` |
| what a source says | `psg note -c -t "..." -k literature -r RESOURCE_ID` |
| to continue a thought | `psg note -c -t "..." -a 21` (files it as `21a`) |
| to connect two notes | `psg link 21a 3 -w "why they belong together"` |
| to find a note | `psg note QUERY`, `psg note -s ZID` |
| to work the inbox | `psg box inbox` |
| an area, project or task | `psg area -c -n NAME`, `psg project -c -n NAME -a AREA`, `psg task -c -t TITLE -p PROJECT` |
| a paper | `psg arxiv add <id> --note`, `psg arxiv search "query"` |
| a feed | `psg rss add URL -a AREA`, then `psg rss pull` |
| Obsidian | `psg obsidian export ./vault`, `psg obsidian import ./vault --dry-run` |
| what needs attention | `psg ready` |

## How to work

1. Read before you write: `psg note -s ZID`, `psg para` or `psg ready`.
2. One idea in one note. Three ideas give three proposed notes. Wait for the OK.
3. Each link has a reason in a sentence: "contradicts", "an instance of".
4. `psg` reports a broken rule as `field: reason`. Read it to the person and fix the input. Never
   go around a rule.
5. After a batch, run `psg ready`. Report the change in one or two lines.

## Hippo: a rhizome of fixations

A **Hippo** is a way of thinking: a name, a description and **fixations** (the subjects that its
notes gather around). Any note connects to any other. There is no trunk.

- `psg hippo` lists the Hippos. `psg hippo --map ID` shows where they stopped and the pieces.
- `psg hippo --weave ID` joins the pieces. It only adds links.
- Do not use `-a` in a Hippo. A rhizome has no trunk.

Recipes:

- **Brain dump.** Split it into one note for each idea, in their words. Show the list. Wait for
  the OK. Save each with `psg note -c "..." -H ID --tag FIXATION`. End with `--map`.
- **"Where was I?"** Run `psg hippo --map ID`. Read back only "Where you left off". Ask which
  one to open.
- **A link they feel.** `psg link A B -w "their reason"`. Their reasons beat the automatic ones.

Do one step at a time. Say what each command changes before you run it. To pause a fixation,
close it with a short note ("parked: ...").

You help with notes, not health. If the person says they are in distress, stop the note work.
Answer as a person. Point them to someone who can help now.

For a review of the method, use the `zk-method` skill.
