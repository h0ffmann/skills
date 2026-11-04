# Debugging Hermes's web dashboard (nix-os `hermes-web.nix`)

Use when the owner pastes a dashboard error (the Chat tab shows "retrying in 30s (attempt N)" and
a queued message) or asks why a dashboard page fails. The dashboard is the unit `hermes-backend`
on loopback behind nginx; the gateway is the unit `hermes-agent`. Telegram and Discord keep
working when only the Chat tab fails.

## Chat tab "retrying": find the real error, do not guess

The Chat tab runs the Ink TUI in a PTY. The TUI attaches to the running gateway through a control
socket in `HERMES_HOME`. The lifecycle log only shows reconnect attempts, and `gui.log` does not
log a refused attach, so the cause is invisible in the logs. Reproduce the discovery step instead:

1. Read what the logs do say: `~/.hermes/logs/tui_gateway_crash.log` (reconnect lines),
   `gui.log` (ws / pty accepted), `journalctl -u hermes-backend`, and `journalctl -u nginx` for
   auth errors. Confirm the gateway is up (`hermes gateway status`, `gateway.sock` exists).
2. Run the TUI's bootstrap by hand, as the `hermes` user, with the package's own Python (take
   `HERMES_PYTHON` from the head of `<package>/bin/hermes`):
   `cd <package>/ui-tui/dist/scripts && HERMES_HOME=~/.hermes HERMES_PYTHON_SRC_ROOT=<package>/share/hermes-agent PYTHONPATH=<same> $HERMES_PYTHON gateway_bootstrap.py`.
   It prints the verdict (`gateway inaccessible: <reason>`) that the TUI hides.
3. Never fetch the dashboard session token to test `/api/ws`: it is a credential. A handshake
   without a valid token returns 403 by design and proves nothing.

## Known cause: `unsafe_control_permissions`

Upstream (`hermes_cli/gateway_runtime_discovery.py`, `home_mode_unsafe`) refuses the socket when
`HERMES_HOME` is group-writable and the group is shared. The NixOS module always recreates the
home with mode 2770, and `hermes.nix` puts the owner in the `hermes` group for the CLI
(`users.users.h0ffmann.extraGroups`). A `chmod` by hand is undone on the next activation.

Options, which are the owner's call because both cost something:

- Remove the owner from the `hermes` group. The group becomes private and the Chat tab works.
  The owner then runs the CLI as `sudo -u hermes hermes ...`, and `scripts/hermes-check.sh` (and
  `just remote-hermes-check`), which rely on the group, need the same prefix. Removing access
  strengthens a guardrail, so it is allowed.
- Keep the group. The CLI works and the Chat tab stays broken.

Give the diagnosis and the two options first; open the PR after the owner picks one (the merge
restarts `hermes-agent`). Say the check script change could not be tested on the box.
