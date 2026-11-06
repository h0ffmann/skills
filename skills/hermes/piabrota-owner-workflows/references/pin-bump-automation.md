# A scheduled bump of a pinned dependency (daily PR by piabrota-ops)

Use when the owner asks that a pin (a package version, a flake input, a vendored commit) is "updated every
day" or "from main" by the ops bot. Example: `openrig/package.nix` pins OpenRig by tag, commit, source hash and
npm hash.

## Settle what "from main" means before the task file

- Read upstream first: latest release, the head of its default branch, how far the branch is ahead of the pin,
  and what the branch's own version file says (an unreleased branch can carry an old version string; releases
  can be cut from another branch, so the pinned commit need not be an ancestor of the branch).
- If the wish can mean the release channel or the branch head, state your reading in one line and build the
  default for the reading the owner confirms. When he answers "I mean the branch", restart the task with the
  branch as the default and keep the release channel as a non-default flag.
- Branch builds are unreleased code. The PR body of the bump must say so, list the commits since the pin, list
  new database migrations, and tell the owner to snapshot and copy the state before he merges: a downgrade after
  a migration is not safe.

## Split the work: script here, workflow for the owner

- Put every step in one POSIX sh script in the repo (`scripts/<name>-bump.sh`) with `--check` (exit 10 when a
  newer pin exists), `--dry-run`, `--to <ref>`, and `--output <file>` for `key=value` lines. Test it on this
  box. The workflow stays thin: check, build the old and the new package, run the script, `dix`, open or
  refresh the PR.
- Agents may not write under `.github/workflows` and the App's push is refused there. Ship the workflow as a
  draft file at a normal path (`scripts/<name>.workflow.yml`) with a header that says where the owner copies it.
  Say in chat that it is not active until he copies it. Copy the pattern of the repo's existing ops-bot workflow
  (App token, skip rules, free disk, cache, commit identity, label). Pass every `${{ }}` value into a shell
  through `env:`.
- One open bump PR at a time on a fixed bot branch, refreshed each day (force-with-lease on the bot's own
  branch, `gh pr edit` for title and body), so the owner always sees the newest state and no PRs pile up. A
  failed build fails the job and opens no PR.

## Computing the pin (prove each against the current pin first)

- Source hash as `fetchFromGitHub` computes it: `nix flake prefetch github:<owner>/<repo>/<commit> --json | jq -r .hash`.
  Run it for the CURRENT pinned commit: it must equal the hash already in the file. That is the proof.
- npm dependency hash: `prefetch-npm-deps package-lock.json` from the lock file of that commit, again proven
  against the current value; if the tool's fetcher version differs from the one `buildNpmPackage` uses, set a fake
  hash, build and read the `got:` hash instead.
- Test the rewrite script on a COPY of the file, with an absolute path: a test that sets a relative script path
  before a `cd` rewrote the real pin file once. After every omp run, `git diff` the pin file and expect only
  the lines the task allowed.
- In CI, build only the package, from the flake's own nixpkgs, with the same call the module uses:
  `nix build --impure --expr 'let f = builtins.getFlake (toString ./.); in f.inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage ./<pkg>/package.nix { }'`.
  Prove the expression locally on the old pin first. Smoke-test `result/bin/<tool> --version` and grep the
  build stamp for the new version and commit; it needs no daemon or state.
- Rewrite only the version, commit and both hash lines with anchored `sed`, then check `git diff --stat` shows
  exactly those lines and `nix-instantiate --parse` passes. Build only the package expression, never the system.
- A version string for an unreleased commit: `<version in its package file>-main.<7-char sha>`; read upstream's
  code for any place that parses or compares the version before you choose.
- Docs that name the version split in two: present-tense claims ("runs version X") are reworded once to point
  at the pin file; provenance claims ("read at tag X") stay, because they were true at that tag only. The bump
  must touch neither.
- omp's deny list blocks `curl`: the script may use `curl` as a fallback for CI, but omp can test only the `gh api`
  path.
