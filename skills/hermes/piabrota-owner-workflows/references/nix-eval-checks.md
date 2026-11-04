# Checking a nix-os change by evaluation, and bumping a flake input

Use when a change touches `.nix` files or `flake.lock` and a full build is too heavy to run, or the
owner waives verification. Evaluation is cheap on kvm4 (seconds when warm; the whole-system eval
fits the unit's memory cap). It proves the flake still evaluates, never that it builds or runs.

## Bump one flake input to a release

1. Resolve the tag to a full commit: `gh api repos/<o>/<r>/commits/<tag> --jq .sha`.
2. Before you write the PR, ask upstream what changed since the old pin, without cloning:
   `gh api 'repos/<o>/<r>/commits?path=nix&since=<pin date>' --jq length` (also `flake.nix`,
   `flake.lock`, `pyproject.toml`). Zero commits on the module paths means the options that
   `hermes.nix` sets did not move.
3. In a branch off `origin/main`: `nix flake lock --override-input <input> github:<o>/<r>/<full-rev>`.
   Read `git diff flake.lock`: only that node's `rev`, `narHash` and `lastModified` may change.
4. Commit only `flake.lock`. State in the body what was not run (build, `nix flake check`, the
   checks that need a build) and, when the owner waived checks, say so.
5. Anything that holds the version by hand (a variable in `hermes.nix`, the README badge) moves in
   the same PR.

## Prove a value without building

```console
nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath   # each host
nix eval --json .#deploy.nodes --apply builtins.attrNames                          # node names
nix eval --raw .#nixosConfigurations.<host>.config.services.hermes-agent.package.drvPath
nix derivation show -r <drvPath> | grep -o '\\"baseVersion\\":\\"[^"\\]*'          # text inside a derivation
```

- A file-writing derivation (`writeText`) keeps its JSON in the `.drv`, with escaped quotes: grep
  with the escapes above. This proves a stamp or config value without building the package.
- A package from a `callPackage` is overridable. Read the argument names in the upstream `.nix`
  file at the pinned rev (`gh api repos/<o>/<r>/contents/<path>?ref=<rev>`), then
  `pkg.override { <arg> = ...; }`. The module's own `override` chains on top; check the module's
  extra settings (for example `extraDependencyGroups`) still evaluate to the same list.
- Flakes see only tracked files: `git add` moved and new files first. A `Git tree is dirty`
  warning is harmless.
- To work on a second branch while omp edits the first, use `git worktree add ../<dir> -b
  hermes/<slug> origin/main`; do not switch the branch omp is editing.
