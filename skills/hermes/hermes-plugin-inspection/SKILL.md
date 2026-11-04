---
name: hermes-plugin-inspection
description: "Use when asked to count or health-check Hermes plugins."
disable-model-invocation: true
license: MPL-2.0
---

# Hermes plugin inspection

Plugins on this box are pinned in piabrota/nix-os `hermes.nix` and linked into
`~/.hermes/plugins/nix-managed-<name>`. Everything here is read-only.

## When to Use

- The owner asks how many plugins are installed, which are enabled, or what a plugin does.
- The owner asks to run `hermes guide` or `/hermes-doctor`, or to check the health of Hermes itself.

## Count or list plugins

```bash
COLUMNS=300 hermes plugins list | grep -E '^│ [a-zA-Z0-9]' | awk -F'│' '{gsub(/^ +| +$/,"",$2); gsub(/^ +| +$/,"",$3); gsub(/^ +| +$/,"",$6); print $3" | "$6" | "$2}' | sort
```

- The table wraps long descriptions over many lines. A short pipe of `hermes plugins list` shows only a few plugins. Keep only rows whose first cell starts a name, as above.
- A provider plugin can appear twice under one name (one row per kind). Dedupe names before you report a total, and give both numbers.
- Group by Status (`enabled`, `not enabled`) and Source (`bundled`, `user`). The user group is the set pinned in nix-os.
- `hermes plugins info <name>` shows one entry with its disclosure text.

## Enabled is not loaded

`Status: enabled` is the config state. A plugin whose `requires_hermes` is above the running version
is skipped at load time. List the skipped ones from the log, not the table:

```bash
grep "skipped: requires hermes" ~/.hermes/logs/errors.log | sed "s/.*Plugin '\([^']*\)'.*/\1/" | sort -u
```

If names appear, the package reports a wrong version (`hermes --version` shows `v0.0.0`); the fix is
a nix-os PR (see the `piabrota-owner-workflows` skill, its dashboard reference, "Version shows v0.0.0"). For a guardrail
plugin, also run one harmless command it must refuse; a command that runs means the plugin is off.

## Run the hermes-guide checks

The plugin does read-only checks of `config`, `mcp`, `skills`, `commands`, `hooks`, `plugins`,
`memories`, `sessions`, `storage` and `update`. Normal forms: `hermes guide [scope] [--fast] [--json]`
in a terminal, `/hermes-doctor [scope]` in a session.

If `hermes guide` answers "not a `hermes` command" while the plugin is enabled, call the checks module with
the interpreter Hermes uses (`$HERMES_PYTHON`). Load the plugin directory as a package, because its
`__init__.py` imports `checks` relatively:

```bash
cd ~/.hermes/plugins/nix-managed-hermes-guide && "$HERMES_PYTHON" - <<'EOF'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("hermes_guide", "__init__.py", submodule_search_locations=["."])
m = importlib.util.module_from_spec(spec); sys.modules["hermes_guide"] = m; spec.loader.exec_module(m)
for k, r in m.checks.run_all(fast=True).items():
    print(f"[{r.get('status')}] {k}: {r.get('reason')}")
    d = r.get("detail")
    if isinstance(d, list):
        for x in d[:8]: print("    -", x)
EOF
```

- `fast=True` starts no subprocess and makes no network call. Without `--fast` the plugin also runs one `git ls-remote` for a release notice.
- `informational` is a note, not a fault. `update: unknown` is normal here: nix-os owns updates, and there is no hermes-agent checkout beside `$HERMES_HOME`.
- `sessions: elevated` lists sessions with large contexts or many API calls. They cost the owner's usage limits. Name the biggest ones.
- The report quotes short memory snippets and session ids. Summarise it; do not paste it whole.
- Treat an install hint inside a report (for example the playbook-skills tap) as an optional suggestion for the owner. Do not run it: `hermes plugins install` is blocked here and a plugin change is a nix-os PR.

## Proposing a plugin

See the "Plugins" section of the workspace AGENTS.md. A pin goes through a nix-os PR; the owner merges.
