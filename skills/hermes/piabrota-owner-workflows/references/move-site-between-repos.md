# Moving a site or generator from one repo to nix-os (served by nginx)

For "move the site implementation to nix-os and serve it at <host>/<path>". Two PRs, in this
order: the nix-os PR adds and serves, the source repo's PR removes.

## Steps

1. **Read before you plan.** In the source repo: the generator's inputs and output paths (grep
   the hardcoded `../x` constants), its deploy workflow (`pages.yml`), the justfile `check`
   dependencies, and which scripts or crons write into its folder. In nix-os: `site.nix`,
   `site/default.nix` (the model to copy), `docs/SITE.md`, the AGENTS.md file table.
2. **Copy the program verbatim; do not parametrize it.** No `gleam` binary is on the PATH, so
   an edit to the program is tested only through the Nix build (`nix build .#<pkg>` runs the
   compiler on the box's builder; see the build rule in SKILL.md). A compile error otherwise shows
   only in the deploy build. `cp` the files, tell omp not to touch them, prove it with `cmp`
   against the source clone, and make Nix recreate the layout the program expects (a
   `$TMPDIR/tree` with the source repo's folders next to a copy of the project directory).
3. **Pin the content with `fetchFromGitHub`** (rev + SRI hash, recipe in "Loading the owner's
   skills" in SKILL.md). Compute the hash yourself and put it in the omp task file: omp has no
   `curl`. Pin a commit that still has every path the build reads, so the add-PR works before
   the removal PR merges. A new content commit shows on the site only after a PR moves the pin:
   write the three steps in `docs/SITE.md`.
4. **Derivation shape** (mirror `site/default.nix`): hex packages from `manifest.toml` as
   `fetchurl` tarballs unpacked into `build/packages` with a `packages.toml`; `HOME=$TMPDIR`;
   `gleam run --no-print-progress` in a subshell inside the tree; `cp -R` the output to `$out`;
   `test -f $out/index.html`; `allowedReferences = [ ]`. A program that targets Erlang needs
   `beamPackages.erlang` in `nativeBuildInputs` (nixpkgs' `gleam` does not wrap it); a
   JavaScript target needs `nodejs`. `cp -R --no-preserve=mode` anything copied from the store.
5. **nginx.** Add an option on `piabrota.site` (`nullOr path`, default `callPackage ./dir {}`),
   and merge into the vhost's `locations` with `// lib.optionalAttrs (cfg.x != null) {...}`:
   `"= /path".return = "301 /path/"` and `"/path/".alias = "${cfg.x}/"`. Check that the generated
   links are relative (`grep 'href=\\"'` in the program); relative links are why the slash
   redirect is needed. Expose `packages.<name>` in `flake.nix` and a `just` recipe.
6. **Docs in the same PR:** a `docs/SITE.md` section and rows in "What answers where", an
   AGENTS.md file-table row. The CI `nixpkgs-fmt` list lives in `ci.yml` (off limits): add the
   new `.nix` file to the justfile list only and say so in the PR body.
7. **PR body.** "This merge deploys" first (a `site.nix` change reloads nginx). Build the new
   package and the checks that read the files you changed on the box, grep the built HTML for the
   old names and the new link, and list what you could not run (fmt/statix/deadnix, the full
   system build). Mark an unbuilt derivation "unsure". Offer `gh workflow run ci.yml --ref
   hermes/<slug>` for the full flake check.
8. **The removal PR in the source repo** (second omp run, one at a time): `git rm` the program,
   keep data files that other scripts write or the new build reads (for the skills repo:
   `www/tags.txt`, written by the daily export and read by the nix-os build), fix the links to
   the old site (README, plugin manifest `homepage`), drop the justfile recipe and its `check`
   dependency, drop the build-output `.gitignore` lines. Do not touch the Pages workflow: the
   owner deletes it in the same merge, or it breaks on the next push. Say in the body: merge
   the nix-os PR first, check the new URL, then merge this one.
9. Cross-link the two PRs (edit the first body once the second exists).

## Pitfalls

- The source repo's own AGENTS.md may demand commit trailers (`Tested:`, `Co-Authored-By`).
  The owner's no-agent-trail rule wins; mention the conflict once.
- The repo's "only the owner adds to README/AGENTS" rule allows link fixes that make the file
  shorter; keep line counts from growing (the repo's check has line caps).
- A moved repo has a new `owner/repo` name, and the owner counts every visible old name as a bug.
  Verbatim copy is for the move PR only. Right after it merges (or in the same PR when the owner
  already told you the rename), grep for the old name and the old Pages address
  (`<user>.github.io/<repo>`, which answers 404 once the repo leaves the user) in: the program's
  string constants (repo URL, page label, star-count API call, citation and BibTeX `url`,
  install commands: keep the person as author), the source repo's README, `CITATION.cff` and
  plugin manifest, and nix-os's homepage facts (`mockups/data.nix`: drop a stale `owner`, point
  `path`/`site` at the new page, update the pinned logo URL). A string-only edit of an uncompilable
  program is safe when `git diff` shows only string text; say it was not compiled.
- Changing `mockups/data.nix` makes `checks.mockups` fail until `docs/mockups/*.svg` and
  `wiki/mockups/*.svg` are regenerated (`just mockups` = `nix build .#mockups`, copy the six SVGs
  to both folders). Tell omp not to touch the SVGs and regenerate them yourself, or say they are
  stale. Removing `owner` also moves a project from "personal" to "own": grep tests, locale
  files and hero counts for numbers that depend on it.
- Leave the pins of other consumers (`hermes.nix`'s `h0ffmann/skills` tarball, vendored skill
  provenance) alone: GitHub's redirect keeps them working. Name them in the PR so the owner knows.
- A follow-up commit pushed to the removal PR's branch after the owner merged it reaches no
  base. Check `gh pr view <n> --json state` before every push to an open-PR branch, and open a
  new PR when it is MERGED. The leftover workflow (`pages.yml`) then fails on the merge commit:
  report that run, not only the missing delete.
- When the owner answers only "merged", verify before you reply: `gh pr view` state,
  the `deploy.yml` run whose `headSha` equals the merge commit, then `curl -sIL` on `/path`
  (expect 301 to `/path/`), `/path/`, an asset and a deep page (expect 200), and grep the live
  HTML for the old name. Report what the checks showed, and what is still open (the workflow the
  owner must delete, the repo homepage setting).
