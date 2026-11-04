# Reviewing the owner's PR with one-click suggestions

Use when the owner says "review PR N" and "add the suggestion directly so I can approve in 1 click".

## Procedure

1. **Scope first.** `gh pr view N --json title,state,mergeable,mergeStateStatus,baseRefOid,headRefOid,files,reviews,comments`
   and `gh pr checks N`. Save the diff to scratch (`gh pr diff N > pr.diff`) and read it by file
   with `awk` on the `diff --git` headers, `cut -c1-220`. A big PR (1,000+ lines) holds generated
   files, PNGs and prose: read the code, workflows, scripts and checklist first, and say in the
   review which parts you did not read.
2. **Read the PR body's own claims** ("tested", "not run", "do not merge before X") and check
   them against the diff. Open items the body admits (a placeholder host name) are worth one line
   in the review, not a long argument.
3. **Check a claim against upstream source before you flag it.** Example: before you say a route is
   unprotected, find its HTTP method in the local source (`grep -rn '<route>' --include=*.py`).
   Put what held up under "Checked and fine": the owner learns what you verified.
4. **Pick the quick wins.** A suggestion is a change that the owner can apply with one click and
   that leaves the PR consistent: one file, a few lines, no value you had to guess, and no prose
   in the docs that would become false. If a fix needs a number or a name only the owner knows, or
   it makes a docs row wrong, write it in the review body as a decision, not as a suggestion.
5. **Get the exact lines of the head version**, not of the diff:
   `gh api 'repos/<o>/<r>/contents/<path>?ref=<headRefOid>' --jq .content | base64 -d > f` and
   `sed -n 'Np' f`. A new file is all in the diff, so any line takes a suggestion. For a changed
   file the line must be inside a diff hunk.
6. **Post one review**, event `COMMENT` (never `APPROVE` or `REQUEST_CHANGES`: the owner approves),
   with `commit_id` set to the head SHA and a `comments` array; each comment has `path`, `line`,
   `side: RIGHT` and a body with a fenced block that starts with the word `suggestion`. The block
   replaces the whole line (or lines) at `line`, so repeat the original line when you only add
   lines after it. Keep the original indentation.
7. **Signature.** The review body and every inline comment end with the signature line from
   SOUL.md. Review text is English and plain, like a PR.
8. **Verify.** `gh api repos/<o>/<r>/pulls/N/comments --jq '.[]|"\(.path):\(.line) \(.body|contains("suggestion"))"'`
   must list each comment with `true`. Give the owner the review URL.

## Posting without python3 on the terminal

The terminal tool may have no `python3`. Write the review body to a Markdown file with the file
tool and build the JSON with jq:
`jq -Rs '{commit_id:"<headRefOid>", event:"COMMENT", body:.}' body.md > review.json`, then
`gh api repos/<o>/<r>/pulls/N/reviews --method POST --input review.json --jq .html_url`. For inline
`comments`, build the JSON in `execute_code` (it has Python). A body in shell quoting with
backticks and quotes breaks: JSON from a file avoids that. When no fix is a safe one-click
suggestion, post a body-only review (no `comments` array) and say why in its first line.

## Review body shape

First line: what you read and did not read, and what you did not build or run. Then the inline
suggestions in one sentence. Then "needs your decision" items, numbered, each with the reason and
the cost of ignoring it. Then "checked and fine". Last, what stays unverified (for example a
GitHub Actions expression that only a real run proves).

## When the owner then says "fix it yourself"

The PR branch is the owner's (`claude/...`) and you may push only `hermes/*`. Do not ask for a
wider push right and do not look for a way around it. Instead:

1. `git fetch --depth 1 origin <pr-branch>`, then `git switch -c hermes/<slug> FETCH_HEAD`. Refetch
   first: the owner may already have applied some of your suggestions (read `git log` and the
   files before you redo a fix).
2. Open your PR with `--base <pr-branch>` (a stacked PR). The owner merges it into the PR with one
   click. Say this in the first lines of your reply, before the work starts.
3. Fix what is mechanical and checkable (commands, doc claims in both languages, contradictions
   between docs). Leave out and name for the owner: anything in `.github/workflows` (a diff for the
   owner), a Nix design change you cannot evaluate here, a value only the owner knows (a host
   name), and a change that raises your own limits or edits your own brief (`hermes/AGENTS.md`,
   `SOUL.md`): guardrails only get stronger, so the owner chooses the numbers.
4. Do the edits with omp (see `omp-harness.md`, "Fix runs") and review the diff before the commit.
5. In the stacked PR body, say that the base is the owner's branch, that the merge deploys
   nothing by itself, and the merge order (stacked PR first). List what is not in it: workflow
   edits, Nix design changes, values only the owner knows.
6. Later, re-check the owner's PR (`mergeStateStatus`): `main` moves, and a PR of your own that
   merged in between can cause the conflict. See `host-cutover.md` for the diagnosis.
7. Write the PR's Tested section with who did what ("Hermes read the diff", "omp made the
   edits"). Never write "a person read" for a check you did.

## What to look for in nix-os host and deploy PRs

- **CI that did not run.** In nix-os `nix flake check` runs only on `workflow_dispatch`, so a PR
  shows it as skipped. A PR body that says "CI's flake check builds it" is true only after a
  dispatch: look for one with `gh run list --branch <b> --json event,status` and
  `gh api repos/<o>/<r>/actions/runs/<id>/jobs`, and report it as pending until it ends. Name
  every new check or system that nobody has built yet.
- **nginx headers.** A `location` with its own `add_header` drops every server-level `add_header`:
  a fix that scopes a header to one location must repeat the others. Relaxing a security header
  (`X-Frame-Options`, CSP) for the whole host to serve one page is a decision to raise: scope it
  to that page's location, and give no one-click suggestion because the two edits must land
  together.
- **A text swap in a bundle** (`sub_filter` on a JS literal): confirm the literal and its uses in
  the pinned upstream source, that `sub_filter_types` covers the served MIME types, that gzip
  is on at the edge when `Accept-Encoding` is cleared, and that any guard check greps the files
  nginx really rewrites (a source map can satisfy a loose `grep -r`).
- **A page framed by upstream's iframe**: read the iframe's `sandbox` flags. Without
  `allow-popups-to-escape-sandbox`, `target=_blank` links open sandboxed; say it is untested.
- A resource cap removed with the move to a bigger host: other services share the cgroup and the
  box; a runaway task can starve sshd and trigger the deploy rollback.
- A placeholder host name left in a file the first deploy reads.
- A rate limit that treats a page load and a login guess the same.
- Branch name against the repo's `claude/<project>-<goal-slug>` rule.
- Workflow matrix and secret-map expressions: say they are unverified until the first real run.
- A cutover checklist: two consumers of one bot token (Telegram, Discord, Slack alike) must never
  run together; check the order of stop, copy, start. Then test each command in your head:
  - a shell glob after `sudo` expands as the unprivileged user, so it stays literal inside a
    root-only directory (use `sudo find ... -exec`);
  - a `tar | ssh tar` pipe needs `set -o pipefail` and a file-count check, or a failed source
    leaves a partial copy with exit 0;
  - extracting over a target that already ran the service mixes two SQLite databases and their
    WAL files: move the old state aside first;
  - the NixOS module deep-merges Nix settings into the existing `config.yaml` and never deletes a
    key, so a copied file keeps limits that the new Nix no longer sets (exclude it from the copy);
  - cron jobs run in their own user scope and outlive `systemctl stop` of the unit: stop the
    user manager and check `pgrep -u <user>`.
- A service bound to loopback with its own auth gate off, behind nginx auth: nginx rules do not
  apply to a local process, and the backend may hand its session token to a local client. The
  doc claim "no secret reaches the browser" then holds only for browser clients.
- Scheduled workflows and docs that still name only the old host after the system is split into
  several `nixosConfigurations` (`cves.yml`, `flake-update.yml`) and stale AGENTS.md rows, wiki
  pages and the agent's own brief: grep the repo for the old host's figures (`minimal`,
  `MemoryMax=1G`, `1 vCPU`).
