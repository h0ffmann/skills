---
name: nix-lab
description: "Write or change a self-contained Nix flake lab: a toolchain or dev shell that other repositories use. Covers locks, Rust tools, a just 1.21 justfile and the local gate. Use for flake.nix, devShells or a new lab."
---

# nix-lab

A lab is one directory with its own flake. Other repositories use it as a flake input, a sparse
submodule or a GitHub Action. A lab must work alone.

## The lab contract

1. **Five files**: `flake.nix`, `flake.lock`, `justfile`, `README.md` and `lab.json`.
2. **It references nothing outside itself**: no `../`, no shared `lib/`, no root flake input. If
   two labs need the same code, copy it. A dependency between labs is wrong, even when it removes
   a duplicate.
3. **The same output shape in each lab**:
   - `devShells.<system>.default`, and named shells when necessary.
   - `lib.<system>.tools`, the package list, for `++` into a consumer's `mkShell`.
   - `packages.<system>.<tool>`.
   - `checks.<system>.*`, and each check must build in the Nix sandbox.
4. **Systems**: `x86_64-linux`, `aarch64-linux` and `aarch64-darwin`, unless the lab cannot
   (CUDA). Use `lib.optionals pkgs.stdenv.hostPlatform.isLinux`. Do not remove a system.
5. **`lab.json`**: `summary` (one line, 100 characters or fewer) and `headline` (nixpkgs
   attribute paths whose version a profile shows). Only nixpkgs attributes go there.

## Pins

- `nixpkgs` follows `nixos-unstable`, or the stable channel of the host. Commit the lock.
- The gate runs with `--no-update-lock-file`. A lock that is behind the flake fails.
- Update with `nix flake update` inside the lab. Commit the lock in the same PR as the change
  that needs it.
- A breaking change to the output shape breaks each consumer. Say so in the PR. Open the PR of
  each consumer at the same time.

## Tools are Rust

A lab tool is a Cargo crate in `labs/<lab>/tools/`, one binary for each command. Build it with
`rustPlatform.buildRustPackage` and `cargoLock.lockFile`. Wrap it with `makeWrapper` and the
programs that it calls. Tests are `cargo test` in the package build. The gate also runs
`clippy -D warnings` and `cargo fmt --check`. No shell script and no Python script in a lab.

## Justfiles run on Ubuntu's just

Each justfile must parse with just 1.21.0 (the `apt` package of Ubuntu 24.04).

- Do not use `[group(...)]` or `[positional-arguments]`. Use `set positional-arguments`.
- Before a push, run `just --justfile <file> --summary` with just 1.21.0.

## The gate

Run it from the lab directory before the PR:

```console
nix flake check --no-update-lock-file --print-build-logs .
nix run nixpkgs#nixpkgs-fmt -- --check .
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- --fail .
just --list
```

Format with `nixpkgs-fmt` only.

## A new lab touches six places

1. `labs/<lab>/` with the five files.
2. The root `README.md`: a section with one paragraph, the `just` recipes, and a `<details>`
   table of what it pins. Also its line in "Structure" and in "Flake outputs".
3. The CI matrix of labs, when the repository has CI.
4. The one-paragraph description, if it changed.
5. Each consumer gets the new pin.
6. `labs/<lab>/README.md` has a "Use it from another repository" section with the exact
   `inputs.<lab>.url = "github:<owner>/<repo>?dir=labs/<lab>"` block.

## Safety

- Nothing applies to the host without a human. Show the dry run of any command that writes
  `/etc/nix/*`, restarts `nix-daemon` or collects garbage. Then wait.
- Do not build a large package only to prove that a dev shell evaluates. Evaluate it.
