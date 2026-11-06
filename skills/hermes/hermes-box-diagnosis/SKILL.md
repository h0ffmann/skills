---
name: hermes-box-diagnosis
description: Use when hermes-agent loops or its memory is full.
disable-model-invocation: true
---

# Diagnosing the Hermes units on the box

Read-only first: `kvm4-health`, `systemctl show hermes-agent -p NRestarts,ActiveState,SubState,ActiveEnterTimestamp,MemoryCurrent`, `journalctl -u hermes-agent --since -5min`. A problem becomes a nix-os PR; the owner does the `sudo` steps.

## Restart loop of hermes-agent (a second gateway)
Signature: `activating (auto-restart)`, `NRestarts` growing every few seconds, journal lines "The host gateway already serves profile ... nothing to start".
1. `cat $HERMES_HOME/gateway.pid`, then `ps -o pid,etime,cgroup:60 -p <pid>`. A cgroup of the dashboard unit (`hermes-backend`) means a stray gateway.
2. Cause: a reload makes the gateway exit 75 and the unit has a gap. The dashboard Chat tab finds no gateway and starts a detached one. The Hermes client only knows a service named `hermes-gateway`; ours is `hermes-agent`. The unit's own gateway then sees the other one and exits at once with **75** (not 0).
3. Fix in code: the wrapper tests, on a fast exit (under 20 s) with status 0 or 75, whether `gateway.pid` names another live pid. It waits for it. This test comes BEFORE the reload branch. A real reload runs longer than 20 s.
4. Clear it now: the owner runs `sudo systemctl restart hermes-backend`. It kills the stray gateway, the Chat tab, this chat session and every omp run started from it. Warn first, and resume the runs after.
5. The `NRestarts` counter and the CRIT in `kvm4-health` stay until the unit restarts again: it is history, not a live fault.

## Memory store: pending writes and the limit
- Background review stages memory proposals in `$HERMES_HOME/pending/memory/*.json` (`origin: background_review`, `payload.operations`). List them compactly: `for f in *.json; do jq -r '.payload.operations[]|"\(.action) | \(.old_text//"-"|.[0:60]) | \(.content//"-")"' $f; done`.
- "Approve all" is a net result, not a replay: later proposals patch text that an earlier one removes or rewrites, so a replay fails. Read the current `memories/MEMORY.md`, compute the final entries, check they fit the limit, apply them in ONE `memory` batch, then delete the pending files so they do not come back. Tell the owner what was removed or shortened.
- The limits are `memory.memory_char_limit` (2200) and `memory.user_char_limit` (1375), Hermes defaults, because memory is in the system prompt of every turn. The owner chose to keep 2200: when it is full, shorten notes or move procedures into a skill; do not propose a bigger limit again.

## Checks after a deploy that touches the unit
- `ExecStart` really is the new one (`systemctl show hermes-agent -p ExecStart`).
- The gateway pid is in the `hermes-agent` cgroup (8G), not the dashboard cgroup (2G).
- No "starting it again" storm in the journal; `NRestarts` flat for a few minutes.
- Do not call a fix proved from a stub test. Say "not proved on the box" until the journal shows it.
