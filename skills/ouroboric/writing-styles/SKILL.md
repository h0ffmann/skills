---
name: writing-styles
description: "Select the writing style of a document from its reader: agent-facing, procedure, spec, guide, reference, research, journal, public help or UI copy. Then apply the skill and rules of that style. Use before you write a new document."
---

# writing-styles

Each document has one reader, and thus one **style**. A style names the skill to use, the house
rules and the checks.

## Which style applies

The most specific setting wins:

1. `style:` in the front matter of the document
2. a `style:` line in the nearest folder `README.md`
3. the repository default: `guide`.

## The styles

| Style | Reader | Skill | House rules |
|---|---|---|---|
| `agent-facing` | a model | `ste100`, strict | Imperative. One instruction in each sentence. A map, not a manual: point to docs |
| `procedure` | a person who follows steps | `ste100`, strict | Numbered steps, one action each. A warning comes before its step |
| `spec` | engineers and agents | `ste100` | Requirements in ASD-STE100, 20 words or fewer. MUST, SHOULD, MAY as in RFC 2119 |
| `guide` | operators and developers | `ste100`, descriptive | Tutorial, how-to or explanation. A task starts with a verb |
| `reference` | a person who looks a thing up | none | Consistent tables. Mostly generated |
| `research` | a future reader who checks claims | `paper` | Each claim cited. Facts apart from analysis (`[ANALYSIS]`). Unchecked items marked |
| `journal` | readers of the journey | `ste100`, descriptive | Concrete and honest. Include what went wrong |
| `public-help` | end users | `easy-translate` rules | A reading age of about 9. The answer first |
| `ui-copy` | users inside the interface | `web-ui` | Short, consistent labels. An error says what happened and what to do |
| pt-BR, any style | Brazilian readers | `ptbr-writer` | The level that matches the style: `estrito` for procedures, `descritivo` for guides, `leve` for UI |

## The humanizer pass

A humanizer pass removes phrases that sound generated. Use it last, and only on text for people:
public pages and posts. Never use it on `agent-facing`, `procedure`, `spec` or `reference` text.
There it trades precision for a natural sound.
