# OpenRig v0.7.7 docs: one line each

Folder: `/var/lib/hermes/workspace/openrig-src/docs/reference/`. Read on 2026-11-05 (titles and first lines).

## Start here
- `quickstart.md` (212 lines): getting started, short.
- `getting-started.md` (1354): full setup reference for the agent that installs OpenRig. Not for us.
- `help.md`: what to do when a user says OpenRig is not working.
- `whats-new.md`: what changed in 0.7.7.

## Specs and layout
- `rig-spec.md` (1219): RigSpec 0.2, pod-aware. Fields, `rig up --name`, materialize one seat.
- `agent-spec.md`: AgentSpec 1.0.
- `rig-bundle.md`, `bundle-formats.md`, `publishing-a-rig-bundle.md`: bundles (we do not install them).
- `instance-layout.md`: `$OPENRIG_HOME` tree and the spec library folder.
- `topology-naming.md`: how to name rigs, pods, seats.
- `edge-types.md`: delegates_to and the other edges.
- `project-workspace.md`: workspace root, missions, exhaust.

## Seats, state, operations
- `agent-state-taxonomy.md`: LIFECYCLE and ACTIVITY words.
- `checked-seat-stop.md`: safe stop check.
- `seat-delivery.md`, `seat-node-targeting.md`, `non-interruptive-mode.md`: typing guard, settings by node, no prompts.
- `harness-runner-contract.md`, `execution-platform-contract.md`, `author-contracts.md`: how a runtime plugs in (draft).
- `host-resources.md`: `rig ps --resources`. `health-diagnosis.md`: System Health packet.
- `keeping-a-watch.md`: remind me / check every hour.
- `refocus-channel.md`: how new orientation reaches a running seat.
- `claude-status-line.md`, `community-harness-presets.md`: Claude seat extras, community harnesses.
- `telemetry.md`, `operation-correlation.md`, `inventory-request-diagnostics.md`: diagnostics.

## SDLC
- `sdlc-conventions.md` (445): the source of truth. Part A simple default, Part B overlay only when assigned.
- `wave-sdlc.md`: parallel build, wave-level review.
- `planning-dial.md`: how much rigor a plan gets (P0 to P2+).
- `product-management-pass.md`: the layer above planning.
- `product-journey-sdlc.md` (348): component menu, the doghouse and the moon base.
- `release-boundary.md`: housekeeping at each fence.
- `mission-install.md`: world install and mission install.
- `lore-routing.md`, `knowledge-maturity.md`, `rosters.md`, `chain-file-convention.md`, `legacy-topology-migration.md`.
- `scoped-operating-posture.md`: quiet by default for human-led work.

## Outside the box (not used here)
- `a2a-agents.md`, `acp-agents.md`, `hosted-members.md`, `gateway-participants.md`, `slack-app-setup.md`,
  `stream-classifier-worker.md`, `terminal-sessions.md`, `browser-access.md`.

## Contributor
- `developing.md`: gates and lanes. `worktree-builds.md`: per-worktree install, never a symlinked node_modules.

Source: `docs/reference/` of mvschwarz/openrig at v0.7.7 (Apache-2.0). Summarised, not copied.
