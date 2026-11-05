# OpenRig seats: the pane environment

Load this when an OpenRig seat shows "timed out waiting for the runner to report ready", or when
the pane says `node: command not found`.

## Symptom

- `rig ps --nodes` shows the seats as `att` with the reason "omp launch: timed out waiting for the
  runner to report ready".
- `rig capture <seat>` shows a bash prompt, the line that the daemon typed (`node .../pi-runner.js`)
  and `bash: node: command not found`.
- A line `/bin/rm: No such file or directory` is harmless on NixOS.
- `rig send` to such a seat is refused. The foreground command is bash. Do not force it.

## Cause

OpenRig 0.7.7 starts each pane with `env -i`. It exports a short list: locale, `TMPDIR`, `XDG_*`,
the `env:` of the RigSpec and the `OPENRIG_*` names. Then it runs a login bash.
The source is `scopedLaunchCommand` in `packages/daemon/src/adapters/tmux.ts`.

The unit's `path` and the unit's environment do not reach the pane. This is by design. Do not undo
it. The option `terminal.inherit_tmux_environment` would give the daemon environment, with the
token, to every pane.

The login bash runs `/etc/set-environment`. That file builds `PATH` from
`/etc/profiles/per-user/$USER/bin` and the system profile. In the pane `USER` is empty.

## Fix

- Put the seat tools in `users.users.<seat user>.packages`: `node`, the seat `omp`, `rig`, `tmux`,
  `git`, `lsof`, `ps`, `bash`. Use one list for the unit `path` and for the profile.
- Set `USER`, `LOGNAME` and `HOME` in the `env:` of the RigSpec. A name that starts with
  `OPENRIG_` or an empty value is refused.

## What does not work

- Tools only on the unit's `path`.
- `__NIXOS_SET_ENVIRONMENT_DONE=1` in the unit's `environment`. It is a guard of the same file,
  but the variable never reaches the pane. It passed a test with the system bash and failed on the
  box.

## How to prove a fix

A test with the system bash shows only the mechanism. Add these checks:

1. Read the launch code of the OpenRig version that runs. Do not guess what the pane receives.
2. Build the per-user profile and list its `bin`.
3. `rig spec validate <rig.yaml>` accepts the `env:` block.
4. After the deploy, check `ls /etc/profiles/per-user/<seat user>`, then launch one seat and
   read its pane with `rig capture`. Say in the PR that a real pane was not tested before the
   deploy.

## Start the seats again after a deploy

1. `rig status` must say "Daemon running". Run `kvm4-health`.
2. `rig up <rig> --existing --plan`. An `omp` seat that never finished a turn needs `--fresh`.
3. `rig up <rig> --existing --fresh dev.builder`. Start one seat. Read its pane. Check the memory of
   the unit. Then start the next seat.
4. A deploy that restarts the unit ends the seats. Take `rig snapshot <rig>` before the owner
   merges a nix-os PR.

## The owner must see the output

Run omp with `--mode json` through `omp-stream`, in the background, with a heartbeat
(`references/omp-harness.md`). Check `command -v omp-stream` before the run. A run that starts
before the deploy that adds the command falls back to plain mode and shows nothing.
The output of a seat is a different case. Read it with `rig capture` and `rig transcript`.
