# A thesis or report rig for UFRJ: where the rules are and what was measured

Use with the section "A rig that produces a document" of `openrig-runtime-and-spec-changes.md`. Facts were checked
in one build on nixpkgs 26.05; re-check a number before you quote it.

## Where the rules and templates live

- **Poli final project (Projeto de Graduação):** the Resolução nº 05/2012 annex of the Escola Politécnica (a PDF on
  poli.ufrj.br) is in force: Portuguese text, A4, spacing 1.5, Times 12 or Arial 11 equivalent, minimum margins 25 mm
  top and bottom and 30 mm left and right, obligatory pre-textual pages (capa, folha de rosto, folha de aprovação, ficha
  catalográfica, resumo, abstract, sumário), roman numbers before the text, one reference system for the whole work.
  A newer "Norma Gráfica" proposal (`COPPE-UFRJ/CoppeTeX`, `dist-poli/norma/`) is not approved: keep the two apart and
  mark each check with its source.
- **Reference LaTeX class:** `COPPE-UFRJ/CoppeTeX` (`dist-poli` is GPL-3): the natural second template.
- **The owner's first template:** `h0ffmann/forecast-energy-demand`, `docs/project/{pt,shared}/`: class `book`, six
  chapters, `\bibliographystyle{coppe}`, built by Tectonic in its CI. It has no resumo, abstract or ficha page: an
  overlay of ours adds them. Pin it by commit with `fetchFromGitHub`.
- **Citation discipline:** `h0ffmann/closed-source` (`AGENTS.md`, `REFERENCES.md` log with statuses, the
  `citation-score` skill, pandoc with `--citeproc`).
- Read a PDF rule text with `gh api repos/<o>/<r>/contents/<path> --jq .content | base64 -d`, or `curl`, then
  `nix shell nixpkgs#poppler-utils -c pdftotext -layout`, and give omp the extracted text file: it has no web.

## Findings that shaped the toolkit

- `coppe.bst` is not in nixpkgs' TeX Live, so a BibTeX route with the template's style is impossible: use pandoc
  `--citeproc` with a pinned ABNT CSL file (accuracy against NBR 6023 and 10520 unverified; test for dropped
  `booktitle` and wrong year letters).
- Tectonic downloads its bundle at run time, so it is out for seats with no network: use `texlive.combine` with a
  small package list and pdfLaTeX (emoji then need refusing with a clear message).
- `pandoc-crossref` from nixpkgs drags a 5.5 GiB closure: do the cross-references in a small Lua filter instead.
- Closure of the toolkit package (pandoc, poppler, TeX set): 727 MiB; a 15-page sample assembles in about 3 s with a
  peak process of 135 MiB. The memory of a Claude Code seat is not measured.
- Raw TeX in markdown must be off (`-raw_tex`), with math the only allow-listed path; prove it with a `\write18`
  and an `\input` attempt that does not run.
- Poppler's text-box margins read about 1 mm short of the true TeX margin: compare against the margins recorded by
  the build, not only the box.
- Progress state goes in one file per section, not in the shared project JSON, so parallel writers do not race.
