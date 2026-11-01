# Writing standard: ASD-STE100. Works with just 1.21 or newer.
set positional-arguments

# Show the recipes
default:
    @just --list

# Run all checks: budgets, ASD-STE100, script self-tests, the drawing, the site, the DeepWiki file
check: deepwiki-check site
    python3 scripts/check.py --self-test
    python3 scripts/check.py
    bash skills/research/citation-score/scripts/citation-score.sh --self-test
    python3 skills/dev-flow/voice-note/scripts/transcribe.py --self-test
    python3 skills/notes/zk-method/scripts/zk_lint.py "$(mktemp -d)" > /dev/null
    test "$(nix eval --json .#drawing.failures)" = "[]"
    nix eval --raw .#drawing.svg | cmp - docs/drawings/waza.svg
    nix eval --raw .#drawing.desmos | cmp - docs/drawings/waza.desmos.json
    git diff --exit-code --stat -- docs/site
    test -z "$(git ls-files --others --exclude-standard docs/site)"

# Write the plain HTML view of the skills into docs/site/ (needs Gleam and Erlang)
site:
    cd www && gleam run

# Write the README drawing again from drawings/waza.nix
drawing:
    nix eval --raw .#drawing.svg > docs/drawings/waza.svg
    nix eval --raw .#drawing.desmos > docs/drawings/waza.desmos.json

# Link each skill into one flat skills folder (default: ~/.claude/skills)
link dest="~/.claude/skills":
    #!/usr/bin/env bash
    set -euo pipefail
    dest="${1:-$HOME/.claude/skills}"
    dest="${dest/#\~/$HOME}"
    mkdir -p "$dest"
    for d in skills/*/*/; do
      n="$(basename "$d")"
      ln -sfn "$PWD/${d%/}" "$dest/$n"
      echo "$dest/$n"
    done

# Check .devin/wiki.json against the DeepWiki limits
deepwiki-check:
    jq -r -f scripts/deepwiki-check.jq .devin/wiki.json
