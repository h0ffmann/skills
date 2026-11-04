# Loading the owner's skills (or another skill repo) into Hermes

Use for "load the skills of repo X", "add these skills as commands", or a PR that changes
`settings.skills.external_dirs` in nix-os `hermes.nix`.

- External skills need no new code. Every skill in `settings.skills.external_dirs` is a `/name`
  command (Telegram and others), and on Discord `/skill` with an autocomplete list (25 shown).
  Hermes ignores the `disable-model-invocation` frontmatter key, so "manual-only" skills can still
  load on their own: tell the owner.
- Pin with `pkgs.fetchFromGitHub` (rev + hash), not a git submodule: a flake reads its git tree
  without submodules unless the URL has `?submodules=1`, and enabling them in CI is a workflow
  edit. Hash: `nix-prefetch-url --unpack https://github.com/<o>/<r>/archive/<rev>.tar.gz`, then
  `nix --extra-experimental-features nix-command hash convert --hash-algo sha256 --to sri
  <base32>`. A wrong hash fails the CI build and prints the right one: say so in the PR.
- Copy an allowlist of skill folders with `pkgs.runCommand ... { allowedReferences = [ ]; }`
  (mirror `optionalSkills` in `hermes.nix`), set it in `external_dirs`, and add the derivation to
  `restartTriggers`. A missing path fails the build, so list paths from the pinned tree.
- Vet every skill before listing it. Leave out: a skill that makes a bilingual PR (conflicts with
  the English-only rule), tells the agent to merge or force-push, assumes Claude Code settings or
  an Obsidian vault, runs a script that needs `python3`, `pandoc`, `just`, Chrome, Docker, `psg`
  or `zk` (not on the box), duplicates another skill, is an empty stub, or shares a name with a
  bundled skill (the bundled one wins). Scan frontmatter and bodies with a script, then read the
  borderline ones. Document included and excluded skills, each with its reason, in the PR docs.
- Test without touching the live config: put `skills:\n  external_dirs: [<dir>]` in a temp
  `HERMES_HOME/config.yaml` and run `HERMES_HOME=<tmp> hermes skills list`; compare names with
  `find ~/.hermes/skills -name SKILL.md` for clashes. Copies out of the Nix store are read-only:
  `chmod -R u+w` before `rm -rf` in scratch.
- The pinned repo's own AGENTS.md rules (for example a `Co-Authored-By` trailer) do not govern
  this agent's PRs: add a short note to `hermes/AGENTS.md` saying which rules win over a skill.
