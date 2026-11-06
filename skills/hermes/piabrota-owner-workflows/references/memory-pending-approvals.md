# Staged memory writes and the memory size cap

## Pending approvals ("approve all in memory pending")

When write approval is on, a background review stages its proposed memory edits instead of applying them.
The store is one JSON file per proposal in `$HERMES_HOME/pending/memory/<id>.json`
(`tools/write_approval.py` is the code): `summary`, `origin` (`background_review`), `created_at` and
`payload.operations[]` (`add`, `patch` with `old_text` and `content`, `remove` with `old_text`).

Procedure:
1. List the files oldest first and print each operation compactly:
   `jq -r '.payload.operations[]|"\(.action) | OLD: \(.old_text//"-")[0:70] | NEW: \(.content//"-")"' <file>`.
   Read the current `memories/MEMORY.md` too. Print only these; run from a neutral directory (a repo's
   AGENTS.md floods the output).
2. The proposals overlap: several rewrite the same entry, and a later `patch` targets text an earlier `remove`
   already deleted. Do not replay them one by one. Work out the NET result per entry (newest wording wins)
   and say which proposals you merged.
3. Compute the final size before you write (the cap is in characters, entries joined by `\n§\n`). If it
   is over, tighten the wording of existing entries; keep every fact, and tell the owner which entries you shortened.
4. Apply the net result in ONE `memory` batch call (`operations`: patches by `old_text` span, removes, adds).
   The cap is checked on the final state only. A patch's `old_text` is a span inside an entry, so the date prefix stays.
5. Delete the applied files from `pending/memory/` and `ls` the folder to show it is empty. Without that
   they stay listed as pending.
6. Tell the owner what was added, shortened and REMOVED. A proposed `remove` of a still-true note (a plan, an
   issue number) is his call once he said "approve all": do it, name it, and offer to put it back.

Hermes has a review surface of its own (a slash command) that this route did not use; applying through
the memory tool and clearing the staged files is what was checked end to end.

## The size cap

`memory.memory_char_limit` (default 2200, about 800 tokens) and `memory.user_char_limit` (default 1375)
in `hermes_cli/config_defaults.py`. The text of both files enters the system prompt of every session, so a
higher cap costs tokens in every turn and counts against the owner's usage. Procedures and lessons belong
in skills (loaded only when relevant), not in memory. Where `config.yaml` comes from a Nix module, a new cap
is a PR to that repository, never a hand edit. Offer it with the cost; do not change it unasked.
