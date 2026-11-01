# Drawings

Writing standard: ASD-STE100.

## `waza.svg`

技 (*waza*, skill), by Matheus Hoffmann (@h0ffmann), 2026. It is the only drawing in this
repository. The Nix files in `drawings/` write it in two formats from one geometry.

| File | Command | What it is |
|---|---|---|
| `waza.svg` | `just drawing` | The README drawing |
| `waza.desmos.json` | `just drawing` | The same drawing as a Desmos graph state |

`just check` runs the tests (`lib.runTests` in `drawings/default.nix`). The tests check the numbers,
the structure of the seven strokes and the Desmos expressions. Each expression, read back from its
LaTeX, must stay within 0.01 of the line it stands for. `just check` also compares the committed
files with a new evaluation.

**What it shows.** The character 技, *waza*, "skill" or "technique", brushed in its seven strokes
in the standard order. On the left is the hand radical 扌: a horizontal, a vertical with a hook and
a rising stroke. On the right is 支: a horizontal, a short vertical, then 又 with its two crossing
strokes.

**Why this kanji.** A skill is a technique that a hand learns. The hand radical 扌 says so in the
character itself.

**How it is drawn.** Each stroke is a list of points placed by hand, with a brush width at each
point. A Catmull-Rom spline connects the points. Each piece of the spline is a cubic Bézier
curve. Each curve is one Desmos parametric expression, `(a+bt+ct^{2}+dt^{3}, …)` for `0 ≤ t ≤ 1`.
The pen is `drawings/pen.nix`. The drawing is `drawings/waza.nix`. Both are pure Nix. Nix
evaluates them without a build. The flake has one input: `nixpkgs-lib`.

**The look.** One ink: `#1f2328` on light pages and `#e6edf3` on dark pages
(`prefers-color-scheme`). The ends are round. There is nothing else.

### Open the Desmos file

The file is a Desmos graph state (`version` 11). Desmos has y up. Thus each y value is `240 - y` of
the SVG. The canvas is 240 × 240.

1. Open `https://www.desmos.com/calculator`.
2. Open the browser console.
3. Run `Calc.setState(<the content of waza.desmos.json>)`.

⚠ Not checked in Desmos itself. The check is local.

### Credits

- The stroke order of 技 follows KanjiVG (`kanji/06280.svg`, © Ulrich Apel, CC BY-SA 3.0). It is a
  reference only. The points and the widths here are drawn by hand. No KanjiVG path is copied.
- The pen and the method come from h0ffmann/pirsig, through `drawings/pen.nix` of piabrota/nix-os.
- The look comes from h0ffmann/picasso.
