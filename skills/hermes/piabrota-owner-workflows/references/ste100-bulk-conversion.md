# Converting many English docs to ASD-STE100 with Haiku subagents

Use for "convert the English of this repo to ASD-STE100, reduce complexity and Markdown
verbosity". Haiku does the rewrite; you check it with a script and with the diff.

## Order

1. **Inventory (read-only, do it yourself).** Make a clean worktree of `origin/main`. List the
   English `*.md` files; skip the pt-BR mirrors (`*.ptBR.md`), generated or vendored paths and
   anything another open branch is editing (a conflict costs more than the gain). Per file count
   characters, sentences over 25 words, passives, semicolons, bold spans and table characters.
   Report totals and the worst files.
2. **Pilot on two files** with two parallel `delegate_task` subagents (Haiku), one output file
   each in the workspace, never in the repo. Give each the same hard rules (below) and ask for a
   fixed report: path, long-sentence count before and after, the five largest edits, what it kept
   long on purpose, what it was unsure of.
3. **Check with `scripts/md_structure_check.py <source> <rewrite>`.** It must print IDENTICAL for
   fenced code, headings and tables, and no missing or added inline code, links, HTML tags or
   numbers. Any difference fails the file. Then read `diff -u` for meaning: Haiku adds a subject
   ("the author writes"), swaps a word for a near synonym, and drops a hedge.
4. **Measure** characters and sentences over 25 words before and after. Do not trust the
   subagent's own numbers or its claims (it said it removed bold, and the count did not move).
5. **Decide the scope with the owner from the numbers**, then run the real conversion as one PR
   per group of documents (deploy docs, plugin docs, wiki), each with the checker output in the
   PR body. A Markdown-only PR does not deploy.

## Hard rules to give the subagent

Keep every fenced block, inline code span, link target, heading line, number, name and hedge
(may, can, if); keep the table shape (rows and columns, shorter cells allowed); add no fact and
delete none. Then the STE rules: 20 words in an instruction and 25 in a description, active
voice, simple tenses, no phrasal verbs, no semicolons, at most three nouns in a row, keep the
articles, one word for one thing. Verbosity: remove bold used only for emphasis, remove filler
sentences that restate the heading, flatten nested bullets into two plain sentences, add no new
heading, table or bullet.

## What the pilot showed

Structure survives (code, links, headings, tables, numbers identical) and sentences over 25 words
fall to near zero, but the text does not get shorter: expect 0 to 5 percent more characters, because
splitting a sentence adds words. Say so before the owner expects a size cut. Real size cuts come from
deleting filler and repeated text by hand, which a rewrite for STE does not do.
