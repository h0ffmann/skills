---
name: update-skills
description: "Use when asked to update the piabrota/skills repository."
disable-model-invocation: true
license: MPL-2.0
---

# update-skills

## When to Use

Use this skill when the owner asks you to add, change, sync or fix a skill in piabrota/skills. Use it also when you finish a skill and must send it there.

The repository piabrota/skills holds the skills of the owner. Two kinds of change exist. Pick one first.

1. A skill that Hermes made or changed. Its folder is `skills/hermes/<name>/`. A job copies it. Do not edit that folder by hand.
2. Any other skill in the repository. Change it with a normal pull request from a clone.

## Which skills the export takes

The script `~/.hermes/scripts/export-skills.sh` takes a skill only when its origin is one of these:

- Made by Hermes on this box (a folder in `~/.hermes/skills/` that is not bundled and not from the hub).
- A skill of the pirsig plugins.
- A skill in the `hermes/skills/` folder of nix-os.

Bundled, hub, catalog and other plugin skills are written by other people. The script leaves them out.

The script keeps only the keys of the Agent Skills format in the front matter. It adds `disable-model-invocation: true`. It adds one row to `skills/hermes/README.md` and one line to `www/tags.txt`.

## Export a Hermes skill

1. Write or change the skill in `~/.hermes/skills/`. Keep the body at 150 lines or fewer. Put long data in `references/`.
2. Run the dry run. Nothing is pushed.

   ```
   DRY_RUN=1 OUT_PATCH=/var/lib/hermes/workspace/skills-export.patch bash ~/.hermes/scripts/export-skills.sh
   ```

   It prints the files that the commit would change. The patch is the full commit.
3. Do the checks in "Check before the push" on the exported files.
4. Run the real export.

   ```
   bash ~/.hermes/scripts/export-skills.sh
   ```

   It prints one line with the pull request URL.
5. If a pull request from a branch `hermes/skills-export*` is open, the export updates that pull request. It does not open a second one. Tell the owner which pull request changed.

The cron job `skills-export` runs the same script every day. It prints nothing when there is nothing to do. Do not make a second job.

If the output says that the App has no installation or that there is no token file, tell the owner. Do not look for another token.

## Find what changed

The background review writes its edits under `~/.hermes/skills/`. To list the skills that changed after a date, run `find ~/.hermes/skills -name SKILL.md -newermt '<date>'`. Do the same for the `hermes/skills/` folder of the nix-os clone.

After a dry run, the clone `/var/lib/hermes/workspace/skills-src` holds the commit on a local branch. A later `git apply --check` of the same patch there says that the files already exist. This is expected.

## Change the export script

The master copy is `/var/lib/hermes/workspace/export-skills/export-skills.sh`. Edit it there. Then copy it to `~/.hermes/scripts/export-skills.sh`, and run the dry run. The token file for the App is `/run/hermes-github/piabrota`. Never read or print it.

The secret scan of the script skips plain placeholders such as `xxxx`, `...` and `your-`. A skill folder from an external directory sits at depth 2 or 3.

## A separate pull request for one skill

Use this when the owner wants a new pull request, and an export pull request is open.

1. Run the dry run. It leaves the clone on the branch `hermes/skills-export-dry`.
2. In the clone `/var/lib/hermes/workspace/skills-src`, fetch main and switch to a new branch from it:
   `git fetch --depth 1 origin main`, then `git switch -c hermes/<goal> origin/main`.
3. Take only that skill from the dry-run branch: `git checkout hermes/skills-export-dry -- skills/hermes/<name>`.
4. Copy the row of that skill from `skills/hermes/README.md` and its line from `www/tags.txt` on the dry-run branch.
5. Check, commit, push and open the pull request as in "Commit and pull request".
6. Write in the pull request that another pull request adds lines at the same place of the README and the tags file. The second merge needs a rebase.

## Change a skill that is not in skills/hermes

1. Reuse the clone `/var/lib/hermes/workspace/skills-src`. Do not make a new clone.
2. Fetch main and switch to a branch `hermes/<goal>` from it.
3. Read `AGENTS.md` of the repository before you edit. The repository wins over this skill.
4. Obey these rules of the repository:
   - Write English in ASD-STE100: short sentences, active voice, no semicolons, no phrasal verbs.
   - A description has 300 characters or fewer. A body has 150 lines or fewer.
   - A skill body has no links, no credits and no history. Credits go in `README.md`.
   - Search `skills/` for a skill with the same job before you add one. Two skills with one job are a defect.
   - A new skill needs a row in `README.md` and a line in `www/tags.txt`.
   - A skill that the repository copies as is keeps its text. The list is `AS_IS` in the file `check.py` of the repository.
   - Never edit a skill of another author unless the owner asks.
5. For a skill with code or a long procedure, use the `skill-validator` skill.

## Check before the push

Python is not on the PATH. Use the one from nixpkgs, with a cache folder that the sandbox can write.

```
export XDG_CACHE_HOME=/var/lib/hermes/.hermes/cache/scratch/nixcache
(cd scripts && nix run nixpkgs#python3 -- check.py)
nix run nixpkgs#python3 -- skills/dev-flow/agentskills-checker/scripts/agentskills_check.py skills/<category>
```

Both must exit 0. Warnings for files copied as is are allowed. Report every warning to the owner.

Then check these by hand:

- The body names no script that is missing in the skill folder. The checker warns about it.
- The added lines hold no token, key, account ID, IP address or e-mail. The repository is public.
- Search for token shapes only. A search that holds the names of secret files starts the deny list and does not run.

## Commit and pull request

1. Write the commit message in English. End it with the trailer `Tested: <the command and its result>`. Add no agent trailer.
2. Run `git add`, `git commit` and `git push origin hermes/<goal>` as three separate calls. The deny list blocks them in one command.
3. Open the pull request with `gh pr create --base main --head hermes/<goal>`. Use the sections Summary, What changed and Tested. Write ASD-STE100.
4. Never push to main. Never merge. Never force-push.
5. Say in the pull request that the skill is public after the merge, and that the owner must read it first.

## Report to the owner

Give the pull request URL, the checks with their results, each warning, and what you did not check. Say if the export updated an old pull request instead of opening a new one.

## Pitfalls

- A body over 150 lines costs tokens in each use. Split it into `references/` files.
- Edits in `skills/hermes/` by hand are lost when the export runs again. Change the source skill in `~/.hermes/skills/`.
- A dry run changes only the local clone. It pushes nothing and calls no `gh` command.
- The export needs the GitHub App token file. Without it the script waits and prints one line.
