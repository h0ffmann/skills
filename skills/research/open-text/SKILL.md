---
name: open-text
description: "Get the full text of a work that is free to copy, keep it byte for byte with its licence, and index it. Use to fetch a book, story, essay or poem. When the text is not free, it gives a citation only."
---

# open-text

Read a thinker's work in the work itself. This skill keeps the full text in the repository, so
notes and essays can quote it with a line number. It copies a text only when the law lets
everyone copy it. Otherwise it records where to read it, and stops.

## 1. Find the text

Prefer a source that names the text and lets you copy it:

1. Project Gutenberg: plain text with a header that names the title, the author and often the
   translator.
2. Standard Ebooks (CC0 for their work) or Wikisource (the page names its edition).

Read the header and the first pages. Record the title, author, translator, edition and year.

## 2. Is it free to copy?

The owner works from Brazil and the repository is on GitHub, in the United States. A text is
free to copy only when it is free in **both** countries:

| Test | Free when, in 2026 | Law |
|---|---|---|
| United States | first published before 1931 | 17 U.S.C. § 304 |
| Brazil, named author | the author died before 1956 | Lei 9.610/98, art. 41 |
| Brazil, anonymous work | first published before 1956 | Lei 9.610/98, art. 43 |

Move each year forward by one for each year after 2026.

**A translation is its own work** (Lei 9.610/98, art. 7, XI). Test the translator as you test
the author. If the file does not name the translator, identify the translation from a known
edition, and say how sure you are. If you cannot, treat it as anonymous.

Under an open licence (CC0, CC BY, CC BY-SA), the text is free to copy if you keep the licence
and the notice.

**When it is not free, or you cannot tell**, do not copy the text. Add a row to "Not copied" in
the index, with the citation and the reason. Then tell the owner.

## 3. Copy it as is

Save the file unchanged, for example `works/<author-slug>/pg<number>.txt`. Keep the whole
eBook, with its header and its licence. Do not trim, reflow or correct it. Record its sha256.
Find the first and the last line of the work with `grep -n`.

## 4. Mark the licence

Give the file its licence in the way that the repository already uses (`REUSE.toml`, a
`LICENSES/` file or a table in the README).

## 5. Index it

Add one entry to the index (`works/index.md`):

```markdown
### <Work title>, <author> (<year written>)

- **File:** `works/<author>/pg<n>.txt`, lines <a> to <b>
- **Source:** Project Gutenberg eBook #<n>, fetched <YYYY-MM-DD>, sha256 `<hash>`
- **Edition:** <the edition that the eBook comes from>
- **Translator:** <name and death year> | <not named, identified as X because Y> | none
- **Licence:** public domain. US: <reason>. Brazil: <reason>. <how sure>
```

## 6. Report

Give the file, its lines, the licence reasons and each thing that you were not sure of.
