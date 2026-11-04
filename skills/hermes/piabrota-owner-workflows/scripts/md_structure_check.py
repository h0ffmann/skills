#!/usr/bin/env python3
"""Compare a Markdown file with its rewrite: what must not change, and a size/length report.

Usage: python3 md_structure_check.py SOURCE.md REWRITE.md
Exit 1 when fenced code, headings or table shape differ, or inline code, links, HTML tags or
numbers were lost or added. Run it with the Python of `execute_code` when the terminal has none.
"""
import collections
import re
import sys

FENCE = re.compile(r"^```.*?^```", re.S | re.M)


def parts(text):
    nocode = FENCE.sub("", text)
    prose = re.sub(r"`[^`\n]+`", "", nocode)
    return {
        "fences": FENCE.findall(text),
        "headings": [l for l in nocode.splitlines() if re.match(r"#{1,6} ", l)],
        "tables": [b.count("\n") + 1 for b in re.findall(r"(?:^\|.*\n?)+", nocode, flags=re.M)],
        "inline": collections.Counter(re.findall(r"`[^`\n]+`", nocode)),
        "links": collections.Counter(re.findall(r"\]\(([^)\s]+)", nocode)),
        "html": collections.Counter(re.findall(r"<[^>]+>", nocode)),
        "numbers": collections.Counter(re.findall(r"\b\d[\d.,:/-]*\b", prose)),
    }


def metrics(text):
    nocode = re.sub(r"```.*?```", "", text, flags=re.S)
    lines = [l for l in nocode.splitlines() if not l.lstrip().startswith(("|", "#", "<", "!["))]
    prose = " ".join(lines)
    prose = re.sub(r"`[^`]*`", "X", prose)
    prose = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", prose)
    prose = re.sub(r"[*_]", "", prose)
    words = [len(s.split()) for s in re.split(r"(?<=[.!?])\s+", prose) if len(s.split()) > 2]
    return {
        "chars": len(text),
        "sentences": len(words),
        "over_25_words": sum(n > 25 for n in words),
        "semicolons": prose.count(";"),
        "bold_spans": len(re.findall(r"\*\*[^*]+\*\*", text)),
    }


def main(src, out):
    a, b = open(src, encoding="utf-8").read(), open(out, encoding="utf-8").read()
    pa, pb = parts(a), parts(b)
    failed = False
    for key in ("fences", "headings", "tables"):
        same = pa[key] == pb[key]
        failed |= not same
        print(key, "IDENTICAL" if same else f"DIFFERENT {len(pa[key])} -> {len(pb[key])}")
    for key in ("inline", "links", "html", "numbers"):
        lost, added = pa[key] - pb[key], pb[key] - pa[key]
        failed |= bool(lost or added)
        print(key, "IDENTICAL" if not (lost or added) else f"lost={dict(list(lost.items())[:8])} added={dict(list(added.items())[:8])}")
    print("before", metrics(a))
    print("after ", metrics(b))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:3]))
