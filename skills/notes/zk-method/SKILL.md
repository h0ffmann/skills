---
name: zk-method
description: "Check that notes follow the Zettelkasten method: kind, atomicity, own words, links with reasons, sources. Lint a Markdown vault and propose fixes. Use for \"is this a good zettel\" or \"audit my notes\"."
---

# zk-method

A Zettelkasten is a network of small notes. Each note is one idea in its owner's words. Each note
links to others with a reason. **The person's ideas and words are theirs.** Propose a split, a
link or a sharper title. Never rewrite an argument or invent a claim.

## The four kinds

| Kind | What it is | Must have | Life |
|---|---|---|---|
| Fleeting | a quick capture | nothing | days |
| Literature | what one source says, in your words | a source (citekey, URL, page) | permanent |
| Permanent | one idea of yours, clear to a stranger in five years | an ID, a title that is a claim, one link with a reason | forever |
| Structure | an entry point: an ordered list of links | one line of reason for each link | grows |

## A good permanent note

1. **One idea.** The title is that idea as a sentence.
2. **Own words.** A quote is evidence inside your explanation, marked, with its source.
3. **Self-contained.** No "as said above", no undefined abbreviation.
4. **Links with a reason**, inside a sentence. A bare "Related:" list is a defect.
5. **Sourced.** It links the literature note. The literature note has the citation.
6. **A stable ID** (`202610271254` or `1/3a`). The title can change. The ID cannot.
7. **Short**: 100 to 500 words.

## A healthy slip box

- The inbox drains in about two weeks.
- No orphan permanent notes.
- Each topic with many notes has a structure note.
- Folders do not replace links. Folders belong to PARA (projects, areas, resources, archive).
- Never file a permanent note under a project. Link it from the project.

## Steps

1. **Scope.** One note, a set, or the vault. Find the inbox, the literature, the slip box and
   the PARA folders. The vault's own conventions win over the defaults below.
2. **Lint** a folder (the path is relative to this skill folder):

   ```sh
   python3 scripts/zk_lint.py <vault> [--inbox Inbox] [--stale-days 14] [--json]
   ```

   It finds what can be counted. Its output is a list of places to examine, not a verdict.
3. **Read and judge.** Read each flagged note and about ten other permanent notes. Check the
   seven points. Atomicity and own words need a reader.
4. **Report.** Group by note, most valuable first. For each: what fails, which rule, and the
   smallest fix, as a proposal. End with the inbox size and age, the orphan count, and the
   topics with no structure note.
5. **Fix only on request.** Make the mechanical fixes (IDs, broken links, moves). For a split,
   show a draft that keeps the person's sentences. Never delete a note. Propose it.

## Defaults

- ID: `YYYYMMDDHHMM`, in front matter `id:` and as the file name prefix.
- Front matter: `id`, `title`, `type`, `source`, `tags`.
- Links: `[[id]]` or `[[id|text]]`, inside sentences.
- Citations: a BibTeX citekey (`@ahrens2017`).
