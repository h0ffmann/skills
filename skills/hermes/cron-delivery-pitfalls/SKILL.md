---
name: cron-delivery-pitfalls
description: "Use when a cron result goes unseen or a cron script fails."
disable-model-invocation: true
license: MPL-2.0
---

# cron-delivery-pitfalls

Adds to `hermes-cron` (read-only here). Learned on 2026-11-05 from the `skills-export` job.

## When to Use

- The owner says a job "did not run" or he never saw its result or its failure.
- A script works in the shell and fails under cron with `command not found`.

## Pitfalls

- A job made or run from the CLI can have `origin` set to a local chat. Its result and its failure notice then
  go nowhere the owner reads. `hermes cron list` says "ran, but the result was not delivered (local chat ...)".
  Fix: `hermes cron edit <id> --deliver discord --failure-deliver discord`. Check `Deliver:` in the list.
- `hermes cron run <id>` from the CLI prints "Ran now: failed" when only delivery fails (no gateway in that
  process). Read the real result in `~/.hermes/cron/output/<id>/<timestamp>.md`.
- A `.sh` cron script runs as `bash <file>` with the PATH of the `hermes-agent` unit. That PATH lacks `awk` and
  `perl`. Add `export PATH="$PATH:/run/current-system/sw/bin"` near the top, and fail early with a clear line
  when a needed tool is missing. Test with `env -i HOME=/var/lib/hermes PATH=<unit PATH> bash script`.
- A script in `~/.hermes/scripts/` is a hand copy. Keep the master in nix-os (`hermesHomeFiles`, see
  `hermes/scripts/export-skills.sh`), or a rebuild loses the fix.

## Check

After a fix, read tomorrow's run record and confirm the Discord delivery. Do not call it fixed from a manual run.
