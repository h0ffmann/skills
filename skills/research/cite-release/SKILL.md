---
name: cite-release
description: "Prepare a citable release and keep its Zenodo and citation metadata correct. Use to release or tag a version, mint a DOI, add an author, or change .zenodo.json, CITATION.cff or the citation block."
---

# cite-release

Each published GitHub release is archived by Zenodo. Zenodo gives each release a version DOI
under one concept DOI. **A DOI cannot be deleted.** Thus an agent prepares and the owner tags.

## The chain

1. The owner runs the release recipe (`just release X.Y.Z`). It tags a clean `main` that is
   level with `origin/main`. It refuses when the citation check fails or the tag exists.
2. A workflow makes the GitHub release from the tag.
3. The Zenodo webhook archives the release with `.zenodo.json` from the tagged commit.

A `--dry-run` does every check and makes no tag. There are no release candidates, because each
archived release is permanent.

## Metadata rules

- **`.zenodo.json` is the only citation file that a person edits.** `CITATION.cff` and the
  BibTeX, APA and ABNT blocks between `<!-- citation:start -->` and `<!-- citation:end -->` are
  made from it (`just citation`). A check fails when they do not agree. Never edit them by hand.
- Never write `version`, `publication_date` or `doi` in `.zenodo.json`. Zenodo sets them.
- An author is a cited creator. A supervisor is a contributor, never a creator.
- Write an ORCID bare in `.zenodo.json` (`0000-0000-0000-0000`). The generator writes the URL.
- Related works use the Zenodo relation words (`hasPart`, `references`, `isSupplementTo`).
  A related repository with its own concept DOI is named by that DOI.
- Write the title, the description and the keywords that a researcher of the field searches for.

## Version numbers

- PATCH: fixes and docs.
- MINOR: a new feature, a new MIP, a new tool or a new repository.
- MAJOR: only when the owner says so.

A release where only submodule pointers changed is not a release. Do not suggest one.

## Steps

1. Read `.zenodo.json`, the release recipe and the last tag (`git tag --sort=-v:refname`).
2. Make the metadata change on a branch. Run `just citation`, then the citation check.
3. Open a PR with the diff and the check output.
4. After the merge, give the owner the exact command: `just release X.Y.Z --dry-run`, then
   without `--dry-run`. Confirm the version number with the owner first.
5. After the DOI exists, one PR writes the new DOI wherever the latest release is named.

## Exports

For RIS, CodeMeta, BibTeX or APA on request, convert from the generated `CITATION.cff`. Do not
write the files that the generator owns.
