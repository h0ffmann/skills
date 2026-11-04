# The Hermes gateway unit: self-diagnosis, restart loops, reloads

Use when the owner says Hermes is unstable, a unit restarts without end, a background job vanished
after a deploy, or asks you to "debug yourself" with the doctor commands. The gateway is the unit
`hermes-agent`; the dashboard is the unit `hermes-backend`.

## Self-diagnose with Hermes's own tools first, read-only

Run them in this order and read the verdict of each before you guess:

1. `hermes gateway status` ("Running manually, not as a system service" means a gateway outside
   the unit), `hermes doctor`, `hermes guide` (the hermes-guide plugin: ten checks, exit 1 means
   warnings), `hermes cron doctor`.
2. `systemctl show <unit> -p NRestarts -p ActiveState -p SubState -p ExecMainStartTimestamp -p
   MemoryMax` and `journalctl -u <unit> --since <time> --no-pager`. Filter out the repeated lines
   (`grep -v`) to see the one that differs.
3. `~/.hermes/logs/gateway.log` and `agent.log` around the first bad timestamp: a graceful restart
   logs `SIGUSR1 received ... supervisor relaunches`.
4. Which unit owns a process: `cat /proc/<pid>/cgroup`; the parent: `awk '/PPid/' /proc/<pid>/status`.
   A gateway in the cgroup of another unit escapes the memory cap of its own unit.
5. `hermes <subcommand> --help` before you invent a fix: the flag that solves a supervisor problem
   is documented there (`gateway run --external-supervisor`). Then confirm in the installed
   package (`ls -d /nix/store/*-hermes-agent-*/lib/python*/site-packages`; grep `gateway/restart.py`).

Do not run `hermes gateway stop` or `restart` yourself to "test": it ends the turn you are in and
kills the jobs you started. Give the owner the command and the consequence, and run it only on his
"go".

## Restart loop with exit 0 ("A gateway already owns this host")

Symptom: `NRestarts` in the thousands, `ExecStart` exits 0, the journal repeats the message above.
Cause: the unit's `ExecStart` is a shell wrapper, so the gateway no longer sees systemd as its
parent. Without `--external-supervisor`, a reload (SIGUSR1) makes the gateway spawn a detached
replacement and exit; `Restart=always` then starts a second gateway that finds the first and exits 0,
forever. The fix is the flag in the wrapper (`hermes gateway run --external-supervisor`): the gateway
exits 75 back to the wrapper, which turns 75 into 0, and systemd restarts it inside the unit.

After the fix merges the old detached gateway still owns the host, so the loop continues until the
owner stops it once (`sudo -u hermes hermes gateway stop`). Tell him that sequence in the PR body
and in chat, and the check afterwards: `NRestarts` stops growing, the gateway PID is in the cgroup of
`hermes-agent.service`, and a test reload leaves no `gateway run` process outside the unit.

## A reload or restart kills background jobs

- Jobs you start from the terminal (omp, long builds) are children of the gateway. When a deploy
  reloads or restarts the unit, they receive SIGTERM: the omp error file ends with
  `[Stopped by SIGTERM]` and only some files exist. The completion notice may never arrive,
  because the process that would deliver it restarted.
- At the start of every turn after a long or overnight run, check the facts before you answer:
  `ps -eo pid,etime,args | grep omp`, the size of the output file, `git status --short`.
  Say plainly that the run died, then rerun the same task file (files already written stay).
- Before a long run tell the owner not to merge a PR that deploys until the run ends, and say
  which merges deploy (`.nix`, `hermes/omp.yml`, `hermes/dangerous-patterns.yaml`).
- The same applies to the owner's own `gateway stop`: the supervisor reaps the gateway's child
  process groups, so ask him to run it when no background job runs.
