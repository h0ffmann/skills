#!/usr/bin/env python3
"""agentskills_check: check skill folders against the Agent Skills specification.

    python3 agentskills_check.py <path>...           # a skill folder, or a folder of skills
    python3 agentskills_check.py --strict <path>...  # a warning is a failure too
    python3 agentskills_check.py --self-test

Standard library only, so it parses the small strict YAML subset that the specification needs.
It prints one line `ERROR|WARN <SKILL.md path>: <message>` for each finding, then a summary.
Exit 0: no failure. Exit 1: a failure. Exit 2: wrong arguments.
"""

import re
import sys
import tempfile
import unicodedata
from pathlib import Path

NAME_MAX = 64
DESCRIPTION_MAX = 1024
COMPATIBILITY_MAX = 500
LINES_MAX = 500
TOKENS_MAX = 5000
CHARS_PER_TOKEN = 4

SPEC_FIELDS = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
# Fields that a client reads at the top level. They are not in the specification, and a move into
# `metadata` turns them off. Thus they are warnings, not errors.
CLIENT_FIELDS = {"disable-model-invocation"}

PLAIN_START_BAD = tuple("[]{}&*!|>'\"%@`#,?")
FILE_REF = re.compile(r"(?<![\w./-])((?:scripts|references|assets)/[\w./-]*\w)")


class YamlError(ValueError):
    pass


def double_quoted(text):
    out, i = [], 1
    escapes = {'"': '"', "\\": "\\", "/": "/", "n": "\n", "t": "\t"}
    while i < len(text):
        c = text[i]
        if c == '"':
            if text[i + 1:].strip():
                raise YamlError(f"text after the closing quote: {text[:40]}")
            return "".join(out)
        if c == "\\":
            i += 1
            if i == len(text) or text[i] not in escapes:
                raise YamlError(f"bad escape in a double-quoted value: {text[:40]}")
            c = escapes[text[i]]
        out.append(c)
        i += 1
    raise YamlError(f"no closing double quote: {text[:40]}")


def single_quoted(text):
    body = text.strip()
    if len(body) < 2 or not body.endswith("'") or "'" in body[1:-1].replace("''", ""):
        raise YamlError(f"bad single-quoted value: {text[:40]}")
    return body[1:-1].replace("''", "'")


def plain(text):
    """A plain value. Strict parsers reject `: ` in it, and lenient parsers accept it."""
    if text.startswith(PLAIN_START_BAD):
        raise YamlError(f"a plain value cannot start with {text[0]!r}. Quote it")
    if ": " in text or text.endswith(":"):
        raise YamlError(f"a colon in a plain value. Quote it: {text[:40]}")
    if " #" in text:
        raise YamlError(f"' #' starts a comment in a plain value. Quote it: {text[:40]}")
    return text


def scalar(text):
    if text.startswith('"'):
        return double_quoted(text)
    if text.startswith("'"):
        return single_quoted(text)
    return plain(text)


def parse_map(lines):
    """Parse the top level of a frontmatter block into a dict of strings and string maps."""
    fields, i = {}, 0
    while i < len(lines):
        line = lines[i]
        i += 1
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if "\t" in line[: len(line) - len(line.lstrip())]:
            raise YamlError(f"a tab in the indent: {line[:40]}")
        m = re.match(r"^([A-Za-z0-9_-]+):(?:[ ]+(.*))?$", line)
        if not m:
            raise YamlError(f"not `key: value`: {line[:40]}")
        key, value = m.group(1), (m.group(2) or "").strip()
        if key in fields:
            raise YamlError(f"the key '{key}' occurs two times")
        block = []
        while i < len(lines) and (not lines[i].strip() or lines[i][0] == " "):
            block.append(lines[i])
            i += 1
        if re.fullmatch(r"[>|][+-]?", value):
            joiner = " " if value[0] == ">" else "\n"
            fields[key] = joiner.join(b.strip() for b in block if b.strip())
        elif not value and any(b.strip() for b in block):
            indent = min(len(b) - len(b.lstrip()) for b in block if b.strip())
            fields[key] = parse_map([b[indent:] for b in block])
        else:
            rest = [b.strip() for b in block if b.strip()]
            fields[key] = scalar(" ".join([value] + rest)) if value else ""
    return fields


def frontmatter(text):
    """Return (fields, body). Raise YamlError when the block is missing or invalid."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise YamlError("SKILL.md must start with a `---` line")
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            return parse_map(lines[1:i]), "\n".join(lines[i + 1:])
    raise YamlError("the frontmatter has no closing `---` line")


def check_name(name, folder):
    if not isinstance(name, str) or not name.strip():
        return ["`name` must be a non-empty string"]
    errors = []
    if len(name) > NAME_MAX:
        errors.append(f"`name` has {len(name)} characters, the limit is {NAME_MAX}")
    if not re.fullmatch(r"[a-z0-9-]+", name):
        errors.append(f"`name` '{name}' permits only a-z, 0-9 and hyphens")
    if name.startswith("-") or name.endswith("-"):
        errors.append("`name` must not start or end with a hyphen")
    if "--" in name:
        errors.append("`name` must not have consecutive hyphens")
    if unicodedata.normalize("NFKC", folder) != name:
        errors.append(f"`name` '{name}' is not the folder name '{folder}'")
    return errors


def check_fields(fields, folder):
    errors, warnings = [], []
    for key in sorted(set(fields) - SPEC_FIELDS):
        if key in CLIENT_FIELDS:
            warnings.append(f"`{key}` is a client extension, not in the specification")
        else:
            errors.append(f"`{key}` is not in the specification")
    if "name" in fields:
        errors += check_name(fields["name"], folder)
    else:
        errors.append("`name` is missing")
    description = fields.get("description")
    if "description" not in fields:
        errors.append("`description` is missing")
    elif not isinstance(description, str) or not description.strip():
        errors.append("`description` must be a non-empty string")
    elif len(description) > DESCRIPTION_MAX:
        errors.append(f"`description` has {len(description)} characters, "
                      f"the limit is {DESCRIPTION_MAX}")
    for key in ("license", "compatibility", "allowed-tools"):
        if key in fields and (not isinstance(fields[key], str) or not fields[key].strip()):
            errors.append(f"`{key}` must be a non-empty string")
    compatibility = fields.get("compatibility", "")
    if isinstance(compatibility, str) and len(compatibility) > COMPATIBILITY_MAX:
        errors.append(f"`compatibility` has {len(compatibility)} characters, "
                      f"the limit is {COMPATIBILITY_MAX}")
    metadata = fields.get("metadata", {})
    if not isinstance(metadata, dict) or any(isinstance(v, dict) for v in metadata.values()):
        errors.append("`metadata` must map strings to strings")
    return errors, warnings


def check_body(text, body, folder):
    warnings = []
    lines = len(text.splitlines())
    if lines > LINES_MAX:
        warnings.append(f"SKILL.md has {lines} lines, the specification advises under {LINES_MAX}")
    tokens = len(body) // CHARS_PER_TOKEN
    if tokens > TOKENS_MAX:
        warnings.append(f"the body has about {tokens} tokens, "
                        f"the specification advises under {TOKENS_MAX}")
    for ref in sorted(set(FILE_REF.findall(body))):
        if not (folder / ref).exists():
            warnings.append(f"the body names `{ref}`, and the file does not exist")
        elif ref.count("/") > 1:
            warnings.append(f"`{ref}` is more than one level deep")
    return warnings


def check_skill(folder):
    """Return (errors, warnings) for one skill folder."""
    path = folder / "SKILL.md"
    if not path.is_file():
        return ["SKILL.md is missing"], []
    text = path.read_text(encoding="utf-8")
    try:
        fields, body = frontmatter(text)
    except YamlError as e:
        return [f"frontmatter: {e}"], []
    errors, warnings = check_fields(fields, folder.name)
    return errors, warnings + check_body(text, body, folder)


def skill_folders(path):
    if (path / "SKILL.md").is_file():
        return [path]
    # A symlink to a skill folder counts: `**` does not follow one.
    found = sorted(p.parent for p in path.glob("**/SKILL.md"))
    found += sorted(p.parent for p in path.glob("*/*/SKILL.md"))
    return sorted(set(found)) or [path]


def run(paths, strict):
    folders = sorted({f for p in paths for f in skill_folders(p)})
    errors = warnings = 0
    for folder in folders:
        found_errors, found_warnings = check_skill(folder)
        for message in found_errors:
            print(f"ERROR {folder / 'SKILL.md'}: {message}")
        for message in found_warnings:
            print(f"WARN {folder / 'SKILL.md'}: {message}")
        errors += len(found_errors)
        warnings += len(found_warnings)
    print(f"{len(folders)} skills, {errors} errors, {warnings} warnings")
    return 1 if errors or (strict and warnings) else 0


def self_test():
    def skill(root, name, text):
        folder = Path(root) / name
        folder.mkdir()
        (folder / "SKILL.md").write_text(text, encoding="utf-8")
        return check_skill(folder)

    def has(found, part):
        return any(part in message for message in found)

    with tempfile.TemporaryDirectory() as root:
        good = '---\nname: good\ndescription: "Do a \\"thing\\". Use for: things."\n'
        good += 'license: MIT\nmetadata:\n  author: me\n  version: "1.0"\n---\n\n# good\n'
        assert skill(root, "good", good) == ([], [])
        folded = "---\nname: folded\ndescription: >\n  Two\n  lines.\n---\n"
        assert skill(root, "folded", folded) == ([], [])
        assert frontmatter(folded)[0]["description"] == "Two lines."
        errors, _ = skill(root, "a", "---\nname: b\ndescription: x\n---\n")
        assert has(errors, "not the folder name")
        assert has(skill(root, "c", "---\ndescription: x\n---\n")[0], "`name` is missing")
        assert has(skill(root, "d", "---\nname: d\n---\n")[0], "`description` is missing")
        assert has(skill(root, "e", "# no frontmatter\n")[0], "must start")
        assert has(skill(root, "f", "---\nname: f\n")[0], "no closing")
        errors, _ = skill(root, "BAD--x-", "---\nname: BAD--x-\ndescription: x\n---\n")
        assert has(errors, "a-z") and has(errors, "consecutive") and has(errors, "end with")
        over = "---\nname: g\ndescription: " + "x" * 1025 + "\n---\n"
        assert has(skill(root, "g", over)[0], "1025 characters")
        colon = "---\nname: h\ndescription: Find gaps: all of them.\n---\n"
        assert has(skill(root, "h", colon)[0], "a colon")
        extra = "---\nname: i\ndescription: x\nauthor: me\n---\n"
        assert has(skill(root, "i", extra)[0], "`author` is not")
        twice = "---\nname: j\nname: j\ndescription: x\n---\n"
        assert has(skill(root, "j", twice)[0], "two times")
        nested = "---\nname: k\ndescription: x\nmetadata:\n  a:\n    b: c\n---\n"
        assert has(skill(root, "k", nested)[0], "strings to strings")
        client = "---\nname: l\ndescription: x\ndisable-model-invocation: true\n---\n"
        errors, warnings = skill(root, "l", client)
        assert errors == [] and has(warnings, "client extension")
        missing = "---\nname: m\ndescription: x\n---\nRead `references/none.md`.\n"
        assert has(skill(root, "m", missing)[1], "does not exist")
        long_body = "---\nname: n\ndescription: x\n---\n" + "line\n" * 501
        assert has(skill(root, "n", long_body)[1], "505 lines")
        blank = "---\nname:\n\ndescription: x\n---\n"
        assert has(skill(root, "o", blank)[0], "non-empty")
    print("agentskills_check self-test: ok")


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    flags = set(argv) - set(args)
    if flags - {"--strict", "--self-test"} or (not args and "--self-test" not in flags):
        print(__doc__, file=sys.stderr)
        return 2
    if "--self-test" in flags:
        self_test()
        return 0
    return run([Path(a) for a in args], "--strict" in flags)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
