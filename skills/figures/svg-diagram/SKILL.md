---
name: svg-diagram
description: "Draw an architecture or repository map as one hand-written SVG for a README: a dark grid card, one colour for each kind of part, a legend. Use when Mermaid is too plain. For a figure with a reading card, use figure."
---

# svg-diagram

GitHub does not render d2, PlantUML or Excalidraw, and it draws Mermaid plainly. Thus a README
diagram can be one hand-written SVG in `docs/img/`. The SVG is its own source. It has no build
step and no generator.

Embed it: `<p align="center"><img src="./docs/img/<name>.svg" alt="<what it shows>" width="860" /></p>`

## Steps

1. **Read the prose next to the diagram.** Draw only what it says, with 12 boxes or fewer. Name
   each box and each arrow with the words of the reader. Each arrow has one label.
2. **Make the layout before the markup.** The `viewBox` is 1000 wide. Columns go from left to
   right in the direction of the flow. Give each box its x, y, w and h, and each arrow its path.
   Keep 40 px between boxes and 110 px between columns with a labelled arrow. A character of
   11 px monospace is about 6.7 px wide.
3. **Write the SVG in this order** (the document order is the paint order):
   1. `<style>`, and `<defs>` with the grid pattern and one arrow marker for each arrow colour.
   2. The card: `<rect rx="18" fill="#020617"/>`, then the same rect with the grid.
   3. The title (a dot and one line). Then the boundaries: dashed `8,5`, a faint fill, a label
      at the top left.
   4. **The arrows**, so that the boxes paint over their ends. Use orthogonal paths (`H`, `V`).
   5. **The boxes**: an opaque `#0b1222` rect first, then the tinted rect on it.
   6. The legend, below all boundaries.
4. **Two languages, two files.** `<name>.svg` and `<name>.pt-BR.svg` have the same geometry.
   Translate the words. Shorten a label that does not fit. Never move a box.
5. **Examine it.** Render a page that holds only the `<img>` with headless Chromium at 1000 px.
   Fix each text that crosses a box edge or another label.

## Design system

| Kind | Fill | Stroke |
|---|---|---|
| the product, a backend | `rgba(6,78,59,0.55)` | `#34d399` |
| a page that people visit | `rgba(8,51,68,0.55)` | `#22d3ee` |
| a store | `rgba(76,29,149,0.5)` | `#a78bfa` |
| models, compute | `rgba(120,53,15,0.45)` | `#fbbf24` |
| shared tools | `rgba(124,45,18,0.45)` | `#fb923c` |
| science, research | `rgba(131,24,67,0.5)` | `#f472b6` |
| a source, other | `rgba(30,41,59,0.7)` | `#94a3b8` |

- Boxes: `rx="8"`, stroke 1.6. Name 15 px bold `#f8fafc`. Sub-lines 11.5 px `#94a3b8`.
- Arrows 1.8 px: `#7dd3fc` solid for a forward flow, `#c4b5fd` dashed `6,4` for a flow back,
  `#94a3b8` dashed `6,4` for a read that is not pinned.
- Edge labels 11 px with `paint-order: stroke; stroke: #020617; stroke-width: 5px`.
- Font: `"JetBrains Mono", ui-monospace, Menlo, Consolas, monospace`. An SVG in `<img>` cannot
  load web fonts. Make the layout for the widest fallback.
- Nothing external: no `<script>`, no `<image href>`, no font link. GitHub removes them.
