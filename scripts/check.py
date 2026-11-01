#!/usr/bin/env python3
"""check: the token budget, the structure and the ASD-STE100 form of this repository.

An agent loads the `name` and `description` of each skill at the start of each session. It loads
the body of a skill only when it uses the skill, and a file next to the body only when the body
names it. Thus a short description saves tokens in every session, and a short body saves tokens
in every use. This script makes the budgets hard limits.

    python3 scripts/check.py            # fails on a broken rule, prints the budget
    python3 scripts/check.py --self-test

Standard library only. Files copied as is (see AS_IS) get warnings, not failures.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"

# Budgets. A token is about 4 characters of English.
DESC_MAX = 300          # characters in one description: loaded in every session
DESC_TOTAL_MAX = 12000  # characters in all descriptions together
BODY_MAX = 150          # lines in one SKILL.md: loaded in each use
DOC_MAX = {"AGENTS.md": 200, "README.md": 220}  # lines: loaded or read often
WORDS_MAX = 25          # words in one sentence (ASD-STE100, descriptive text)
LINKS_MAX_DOC = 25      # Markdown links in one top-level document

# Copied as is from their source. Their text and language stay as the source has them.
AS_IS = {
    "skills/writing/ptbr", "skills/writing/ptbr-writer", "skills/writing/ptbr-routing",
    "skills/writing/cientifico", "skills/writing/retorica", "skills/dev-flow/bipr",
    "skills/figures/figure", "skills/figures/archify",
    # Copied as is on the owner's word: ww3-gpu and chaceon, and ponytail-review from havamal.
    "skills/ww3/noaa-notices", "skills/ww3/release", "skills/ww3/wfip", "skills/ww3/ww3-port",
    "skills/ww3/ww3-port-rust", "skills/ww3/ww4-status", "skills/ouroboric/ponytail-review",
}

PHRASAL = re.compile(
    r"\b(set up|sets up|look at|looks at|find out|figure out|point out|carry out|turn on|turn off|"
    r"pick up|fill in|fill out|go through|goes through|come up|break down|end up|spin up|kick off|"
    r"reach out|dive into|look up|look for|give up|make up|leave out|write down|check out|"
    r"deal with|run into|clean up|keep up|show up|sum up|work out)\b", re.I)
MARKETING = re.compile(r"\b(seamless|robust|powerful|cutting-edge|effortless|blazing|world-class|"
                       r"leverage|utilize)\b", re.I)


def front_matter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return {}, text
    fields, key = {}, None
    for line in m.group(1).splitlines():
        kv = re.match(r"^([a-z-]+):\s*(.*)$", line)
        if kv:
            key = kv.group(1)
            fields[key] = kv.group(2).strip().strip('"')
        elif key and line.startswith(" "):
            fields[key] += " " + line.strip()
    return fields, text[m.end():]


def prose(text):
    """Yield (line number, sentence) for prose: no code, tables, HTML or headings."""
    in_code = False
    for n, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code or not s or s[0] in "|<#>" or s.startswith("---"):
            continue
        s = re.sub(r"`[^`]*`", "X", s)
        s = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", s)
        s = re.sub(r"^([-*]|\d+\.)\s+", "", s)
        for part in re.split(r"(?<=[.!?:])\s+", s):
            if part:
                yield n, part


def ste(text):
    """Return the ASD-STE100 findings of a text, as strings."""
    found = []
    plain = re.sub(r"```.*?```", "", text, flags=re.S)
    plain = re.sub(r"`[^`]*`", "", plain)
    plain = "\n".join(l for l in plain.splitlines() if not l.lstrip().startswith(("|", "<")))
    for rx, what in ((re.compile(";"), "semicolon"), (PHRASAL, "phrasal verb"),
                     (MARKETING, "marketing word"), (re.compile("—"), "em dash")):
        for m in rx.finditer(plain):
            line = plain[: m.start()].count("\n") + 1
            found.append(f"{what} '{m.group(0)}' (line ~{line})")
    lines = text.splitlines()
    for n, sentence in prose(text):
        # A list item that continues on the next lines is one sentence. Join it.
        words = len(sentence.split())
        if words > WORDS_MAX:
            found.append(f"{words} words in one sentence (line {n}): {sentence[:60]}...")
    return found


def check(root=ROOT):
    fails, warns, budget = [], [], []
    names = {}
    total_desc = 0
    skills = sorted((root / "skills").glob("*/*/SKILL.md"))
    for path in skills:
        rel = str(path.parent.relative_to(root))
        as_is = rel in AS_IS
        report = warns if as_is else fails
        text = path.read_text(encoding="utf-8")
        fields, body = front_matter(text)
        name = path.parent.name
        if name in names:
            fails.append(f"{rel}: the name '{name}' is also {names[name]}")
        names[name] = rel
        if fields.get("name", name) != name:
            report.append(f"{rel}: name '{fields.get('name')}' is not the folder name")
        desc = fields.get("description", "")
        if not desc:
            report.append(f"{rel}: no description")
        lazy = fields.get("disable-model-invocation") == "true"
        if not lazy:
            total_desc += len(desc)
        if len(desc) > DESC_MAX:
            report.append(f"{rel}: description has {len(desc)} characters, the limit is {DESC_MAX}")
        lines = len(text.splitlines())
        if lines > BODY_MAX:
            report.append(f"{rel}: SKILL.md has {lines} lines, the limit is {BODY_MAX}")
        if not as_is:
            if re.search(r"\]\(https?://|<https?://", body):
                fails.append(f"{rel}: a link in a skill body (hard rule 2)")
            if re.search(r"^@\S", body, re.M):
                fails.append(f"{rel}: an @import loads a file eagerly. Name the file instead")
            for f in ste(text):
                fails.append(f"{rel}: {f}")
        budget.append((rel, len(desc), lines, lazy))
    if total_desc > DESC_TOTAL_MAX:
        fails.append(f"all descriptions: {total_desc} characters, the limit is {DESC_TOTAL_MAX}")
    for doc, limit in DOC_MAX.items():
        p = root / doc
        if not p.exists():
            continue
        text = p.read_text(encoding="utf-8")
        if len(text.splitlines()) > limit:
            fails.append(f"{doc}: {len(text.splitlines())} lines, the limit is {limit}")
        links = len(re.findall(r"\]\(", text))
        if links > LINKS_MAX_DOC:
            fails.append(f"{doc}: {links} links, the limit is {LINKS_MAX_DOC}")
        for f in ste(text):
            fails.append(f"{doc}: {f}")
    for p in sorted(list((root / "docs").rglob("*.md")) + list((root / "skills").glob("*/README.md"))
                    + list((root / "agents").glob("README.md"))):
        for f in ste(p.read_text(encoding="utf-8")):
            fails.append(f"{p.relative_to(root)}: {f}")
    return fails, warns, budget, total_desc


def self_test():
    assert ste("Start the job.") == []
    assert any("semicolon" in f for f in ste("Start it; stop it."))
    assert any("phrasal" in f for f in ste("Set up the job."))
    assert any("words" in f for f in ste(" ".join(["word"] * 30) + "."))
    assert ste("```\nset up; " + "x " * 40 + "\n```\n") == []
    fields, _ = front_matter("---\nname: a\ndescription: b c\n---\nbody\n")
    assert fields == {"name": "a", "description": "b c"}
    print("check self-test: ok")


def main():
    if "--self-test" in sys.argv:
        self_test()
        return 0
    fails, warns, budget, total = check()
    eager = sum(1 for b in budget if not b[3])
    print(f"{len(budget)} skills, {eager} loaded at session start, "
          f"{total} description characters (about {total // 4} tokens in each session)")
    for w in warns:
        print(f"warning (copied as is): {w}")
    for f in fails:
        print(f"FAIL: {f}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
