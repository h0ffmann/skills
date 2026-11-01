---
name: systemd-hardening
description: "Harden a systemd service written in Nix (systemd.services.<name>) with sandboxing, capability limits and syscall filters, then prove it still works. Use when you write or review a NixOS service module."
---

# systemd-hardening

A service gets only what it needs. Start from a tight base. Open each item that the service
really uses, and say why in a comment.

## Never harden these

`sshd`, `qemu-guest-agent` and `cloud-init` keep the machine reachable. Do not tighten them.

## The base

```nix
serviceConfig = {
  DynamicUser = true;                 # or a fixed User/Group when state must keep its owner
  StateDirectory = "<name>";          # /var/lib/<name>, owned by the service
  NoNewPrivileges = true;
  ProtectSystem = "strict";
  ProtectHome = true;
  PrivateTmp = true;
  PrivateDevices = true;
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectKernelLogs = true;
  ProtectControlGroups = true;
  ProtectClock = true;
  ProtectHostname = true;
  ProtectProc = "invisible";
  ProcSubset = "pid";
  RestrictNamespaces = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
  LockPersonality = true;
  MemoryDenyWriteExecute = true;      # remove for a JIT (node, JVM)
  RemoveIPC = true;
  CapabilityBoundingSet = "";
  AmbientCapabilities = "";
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  SystemCallArchitectures = "native";
  SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
  UMask = "0077";
  MemoryMax = "256M";                 # a value that fits the host budget
  CPUQuota = "50%";
};
```

## Open only what is necessary

| The service needs | Add |
|---|---|
| a port below 1024 | `CapabilityBoundingSet` and `AmbientCapabilities` = `CAP_NET_BIND_SERVICE` |
| no network | `PrivateNetwork = true`, and `RestrictAddressFamilies = [ "AF_UNIX" ]` |
| a secret file | `LoadCredential = "env:/var/lib/<name>-secrets/<name>.env"` |
| a path to write | `ReadWritePaths`, the smallest path |
| a JIT | remove `MemoryDenyWriteExecute`, and say why |

## Prove it

1. Build the system.
2. Score the unit on a test machine or in a VM check: `systemd-analyze security <name>`. Put
   the score before and after in the PR.
3. Run the service and its VM test. Read the journal for `EPERM`, `EACCES` and `SIGSYS`. Each
   one names an item that you must open.
4. Never remove a hardening item only because a test fails. Find the one permission that the
   service needs and open only that.
