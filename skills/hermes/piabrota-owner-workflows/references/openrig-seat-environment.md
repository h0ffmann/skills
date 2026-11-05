# OpenRig seats: the pane environment

Load this when an OpenRig seat shows "timed out waiting for the runner to report ready", when
the pane says `node: command not found`, or when omp exits with "No default model selected".
A seat start fails in layers: each fix shows the next missing opt-in in the pane. Launch one seat
after each deploy and read `rig capture`; do not batch guesses for layers you have not seen.

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

## Next layer: the model key

Symptom in the pane: `No default model selected` and `omp exited (code 1)`; `rig ps` shows
"Model ... configured not-declared".

An omp seat gets a provider key only with a double opt-in:

- The daemon setting `recovery.provider_auth_env_allowlist` names the variable. In the unit it is
  `OPENRIG_RECOVERY_PROVIDER_AUTH_ENV_ALLOWLIST=ANTHROPIC_API_KEY`: a name, never a value. The value
  stays in the unit's root-only environment file.
- The seat model is written as `provider/id`, for example `anthropic/claude-sonnet-5-5`. A short
  name passes no key. Read the source to see whether the AgentSpec default or the member `model:`
  counts for an omp seat before you edit the spec.

## Next layer: the approval mode

Symptom: the typed runner command has `--approval-mode always-ask`, and the seat stops at its
first tool call. `rig up <spec> --plan` warns `permission_policy absent; launch_posture=floor`.

The ambient `OPENRIG_YOLO=1` of the unit does not widen a seat when the rig has no
`permission_policy`. The rig needs `permission_policy: builtin:yolo` (or a custom policy file).
This widens seat permissions, so ask the owner with `clarify` before you write it, even when an
earlier decision says the seats run without prompts. State that omp's own deny rules stay the guard.
Read plan warnings every time: they name the posture before any seat starts.

## The web UI and its vhost

Proven live on the box: the vhost answers 401 without a login and the dashboard login opens it.
From the OpenRig 0.7.7 source: the UI is the `packages/ui` app (`tsc` and
`vite build` from `node_modules/.bin`), served by the daemon from `<cli package>/ui/dist` when
`OPENRIG_UI_ENABLED=true`. The daemon has a browser boundary on `/api/*`: the Host must be
`localhost`, an IP, the machine name or in `OPENRIG_ALLOWED_HOSTS`, and a browser Origin must be
the daemon's own or in `OPENRIG_ALLOWED_ORIGINS`. Behind an nginx vhost set both to the public name
(`https://<name>` for the origin), keep the daemon on loopback, and proxy the WebSocket of the
terminal with upgrade headers and a long read timeout.

The UI can type into seats that run without approval prompts. Put basic auth and TLS in front of
it. Reuse the dashboard's htpasswd path (`hermes-web.nix` option) for the vhost: a new login file
needs root, and a missing file makes nginx answer 500. Check the DNS record first
(`dig +short A <name> @1.1.1.1` must show the box address), or the ACME order fails at deploy.
The SSH tunnel (`ssh -L 7433:127.0.0.1:7433 <user>@<host>`, then `http://localhost:7433`) needs
none of this. Hermes has no sudo and never reads the htpasswd file, so when the owner asks for
the login, give him the commands to run on the host: `sudo cut -d: -f1 <file>` (names only),
`sudo nix shell nixpkgs#apacheHttpd -c htpasswd -B <file> <user>` (add or reset; `-c` would
overwrite the file), then `chown root:nginx` and `chmod 0640`. nginx reads the file on each
request, so no reload is needed.

## How to prove a fix

A test with the system bash shows only the mechanism. Add these checks:

1. Read the launch code of the OpenRig version that runs. Do not guess what the pane receives.
2. Build the per-user profile and list its `bin`.
3. `rig spec validate <rig.yaml>` accepts the `env:` block.
4. After the deploy, check `ls /etc/profiles/per-user/<seat user>`, then launch one seat and
   read its pane with `rig capture`. Say in the PR that a real pane was not tested before the
   deploy.

## Which token the seats use

The seats use the owner's existing subscription token, never an API key. The unit copies the
`CLAUDE_CODE_OAUTH_TOKEN` line of Hermes's secrets file into a root-only file under the name
`ANTHROPIC_API_KEY`, because that is the one Anthropic name OpenRig's omp runner forwards. The omp
wrapper sees the `sk-ant-oat` prefix and turns it into `ANTHROPIC_OAUTH_TOKEN`, so omp signs in as
a subscription. Never read the file to check: a seat that reaches an idle prompt and answers proves
it. The `claude-code` runtime would take `CLAUDE_CODE_OAUTH_TOKEN` directly, but it needs the
unfree `claude` binary and loses omp's deny rules: offer it only as a separate PR the owner asks for.

## A rig keeps the spec it was made with

`rig up <rig> --existing` restores from the stored snapshot. A changed `rig.yaml` (a new `env:`, a
`permission_policy`, a member `model:`) does not reach a rig that already exists. To apply it with
the seats dead: `rig archive <rig-id>` (reversible with `rig unarchive`, data kept), then
`rig up /etc/openrig/specs/rigs/<name>/rig.yaml --plan` and without `--plan`. Without the archive,
`rig up <spec>` refuses when a rig of that name exists and the tmux server is gone. A healthy start
shows `run`, `idle`, no attention flag, `Startup: ready`, and a pane where the seat read its
identity and waits for a task. `rig up <spec>` starts both members: check the unit's memory first
(two seats is the limit).

## Start the seats again after a deploy

1. `rig status` must say "Daemon running". Run `kvm4-health`.
2. `rig up <rig> --existing --plan`. An `omp` seat that never finished a turn needs `--fresh`.
3. `rig up <rig> --existing --fresh dev.builder` (the member id, not the session name). Start one
   seat. Read its pane. Check the memory of the unit. Then start the next seat.
   `rig seat launch <seat> --fresh` refuses while the tmux server is gone ("session existence was
   NOT determined"). Use `rig up --existing --fresh` there: it starts the server.
   A relaunch re-reads the profile of the seat user at launch. A pane started before the deploy
   that fixed the profile keeps the old PATH, so relaunch it.
4. A deploy that restarts the unit ends the seats. Take `rig snapshot <rig>` before the owner
   merges a nix-os PR.

## The owner must see the output

Run omp with `--mode json` through `omp-stream`, in the background, with a heartbeat
(`references/omp-harness.md`). Check `command -v omp-stream` before the run. A run that starts
before the deploy that adds the command falls back to plain mode and shows nothing.
The output of a seat is a different case. Read it with `rig capture` and `rig transcript`.
