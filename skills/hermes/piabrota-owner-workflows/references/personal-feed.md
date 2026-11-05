# A personal, scored feed (RSS/Atom digest) for the owner

Use for "build me an RSS feed", "trending repos or podcasts", "watch X for me" or any digest
built from many public sources. Check the `watchers` and `rss-feeds` skills first: they poll one
source and dedupe. A custom script is justified only for what they lack (one score over many
sources, one dedupe across sources, an Atom output); say that in the PR.

## 1. Find the interests from evidence, not from guess

- Count terms in the owner's own messages, read-only:
  `sqlite3.connect("file:<HERMES_HOME>/state.db?mode=ro", uri=True)`, table `messages`,
  `role='user'`. Use a regex lexicon, count messages per topic, keep only the aggregates.
- Label each interest with its origin: `chat` (measured in his messages) or `profile` (stated in
  the public `hermes/AGENTS.md`). Never copy a message, a count or a private fact into a public
  repo; the docs table shows topic and origin only.
- Give each interest a weight 1 to 5 and word-boundary terms. Short terms such as `omp` or `nix`
  need `\b`, or they match inside other words.

## 2. Probe every source before it enters the config

- For each candidate print: HTTP status, format (atom/rss/json), item count, newest item date.
  Do it in one threaded script and keep the result file in the workspace.
- A source stays out when it answers 4xx/5xx, is not a feed, or is stale. Write each rejected
  source, with the reason, in the doc: the next session must not re-test it blindly, and the owner
  sees the gaps. A 429 from one host (Reddit) means one request per run, never a loop.
- Official-agency sources need a verified feed or API first. Do not add an unverified alert source.
- Find podcast feeds with the iTunes search API
  (`itunes.apple.com/search?term=...&entity=podcast`, field `feedUrl`), then probe the URL: the
  stored `feedUrl` can be dead. Check the newest episode date.
- "Trending" has no official feed. GitHub search needs no token for a few queries: use
  `topic:<x> created:>YYYY-MM-DD` (new projects, the best "building in public" signal) and
  `pushed:>date stars:a..b` (active, noisy). Wait 7 s between queries (10 a minute anonymous). Run
  each query once and read the top rows before you keep it; drop or widen a query that returns 0 or
  1 rows. HN has `hnrss.org` feeds with `q=` and `points=`; retry once on 502, they are flaky.

## 3. Build rules for the script (give them to omp)

- Podcast feeds are 4 to 5 MB with hundreds of items, newest first. Read at most about 1.5 MB and
  use `iterparse`; keep the complete `item`/`entry` elements and ignore a cut at the end. Test with
  a fixture cut in the middle of an item.
- One failing source never stops the run: record it in `health.json` and in one line of the digest.
  Exit 1 only when every source failed or a write failed.
- Stable ids (`tag:` plus a hash of the normalised link), atomic writes, a state file of items
  already sent, and empty stdout when nothing is new (a no_agent cron job posts stdout).
- Discord: wrap links in `<...>` so no preview opens, and cut the digest at 1,900 characters on
  whole items.
- Standard library only; tests make no network call (pass the fetch function in). Keep every
  function simple: the CI smell report counts (`references/code-smell-refactor.md`).

## 3b. Run it on the real network before the PR, and read the distribution

Offline tests pass while the design is still wrong. After the first omp run, build once with
`--no-state --out <workspace dir>` (outputs only; the state stays empty, so the first scheduled
digest is not empty). Then count entries and scores per group and per source, and fix what the
numbers show with a second, small omp run:

- Date a GitHub search item by `pushed_at`, not `created_at`: an old repository that is still
  active otherwise ranks as new.
- A global item cap lets the heaviest group take most slots and starve the others (podcasts). Give
  each group a first-pass quota, a per-group share in the digest, and fill the rest by score.
- A weekly show scores low on recency. Mark the curated podcast feeds `pinned` with a small
  per-source keep, so their newest episodes always appear.
- Add a per-source title exclude list for noise such as nightly `canary` release tags.
- Flaky hosts (`hnrss.org` 502, a chart timeout) are normal: they must show in the digest error
  line and `health.json`, never stop the run.
- Parse the Atom file: feed and every entry have `id`, `title`, `updated`, `link`; ids are unique.

## 4. Wire it into Hermes

- Files install through `hermesHomeFiles."scripts/<name>.py" = ./path;` and
  `hermesHomeFiles."<dir>/<file>.toml" = ./path;` in `hermes.nix`. A merge deploys and restarts the
  unit. Cron jobs are created at run time (`hermes cron create`), not in Nix; a `.py` script runs
  with the Hermes Python, `no_agent` jobs cost no quota.
- Keep serving separate: the dashboard's nginx cannot read the Hermes home (group-only mode), and
  opening it is a security change. Deliver the digest through the cron job and keep the Atom file
  on the box until the owner decides.

## 5. Overnight or "test it tomorrow" requests

- Do the real run yourself before you hand over, so the outputs exist when he wakes. Schedule a
  one-shot `no_agent` job (`in`/date schedule, `deliver` explicit) for his morning, and read it
  back with the cron doctor. Do not create the recurring job before the merge.
- Before the merge, copy the script and config by hand to the paths `hermesHomeFiles` will use
  (`~/.hermes/scripts/`, `~/.hermes/feeds/`); the deploy overwrites them with the same content.
  Dry-run with the Hermes Python that cron uses
  (`/nix/store/*-hermes-agent-env/bin/python3.*`, `HERMES_HOME` set, `--dry-run`): it proves the
  default paths without writing state. Then
  `hermes cron create "<ISO date with offset>" --name <n> --no-agent --script <file>.py --deliver
  discord --timezone America/Sao_Paulo --repeat 1`, and read it back with `hermes cron list` and
  `hermes cron doctor`.
- State in the first reply what is excluded and why, what needs his yes (a paid or logged-in
  source), and that the feed has no public URL yet.
- Promise only what exists. Schedule the one-shot after the script has run once, never before. When
  a promise lapses (the build run was killed, the script is missing), say so in the first sentence of
  the next message, before the owner asks where the PR is.
