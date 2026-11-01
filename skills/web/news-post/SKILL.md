---
name: news-post
description: "Write, change or review a news post in pt-BR and English. Each claim has a source and the build calculates the reading time. Use for a post on a news page, or when somebody asks about the reading time of a post."
---

# news-post

A news post tells the public what the project did. The public trusts a post only when each claim
has a source. Use this skill with `citizen-science` for the sources and with `ptbr-humanizer`
for the pt-BR text.

## Where a post is

- Each post has one Markdown file for each language: `YYYY-MM-DD-<slug>.pt-BR.md` and
  `YYYY-MM-DD-<slug>.en.md`. Both files are necessary.
- A README in the posts folder gives the format and the index of the posts.
- A build script writes the posts into a marked block of the news page. Do not edit that block
  by hand.

## Reading time

- Each post shows its reading time next to its date: "5 min de leitura", "4 min read".
- The build calculates the reading time. Do not write it in the Markdown.
- The build counts the words of the title and the body. It does not count link targets or markup.
- It divides the count by 200 words for each minute and rounds up. The minimum is 1 minute.
- Each language gets its own reading time.
- The `--check` mode of the build fails when the page shows an old reading time.
- Do not change the words for each minute to make a post shorter. Remove text from the post.

## Write or change a post

1. Write the pt-BR file first. Then write the English file. Both files have the same sections,
   the same facts and the same links.
2. Give a link for each claim: a file, a PR, an issue or a DOI. Work that continues is work in
   progress. Never show a plan as done.
3. Write the full name of each acronym at its first use, in each language. Say what the thing is
   when the name does not tell the reader. Units and product names are not acronyms.
4. Add the post to the index in the README of the posts folder.
5. Run the build. Then run the build with `--check` and the site checks.
6. Do two reviews before the PR. First, check each claim against its link and the parity of the
   two languages. Second, check the language and the voice. Fix each finding. Then run the build
   again.
7. Put screenshots of the news page in the PR: 1280 × 800 and 390 × 844, in the two languages.

## Check an old post

- The reading time on the page agrees with the build.
- The two languages tell the same facts. A fact that changed in one changed in the other.
- The links work. Statements such as "in review" or "no data yet" are still true.
- An old post gets a dated update paragraph at its end. Do not change the old text silently.
