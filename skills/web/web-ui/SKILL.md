---
name: web-ui
description: "Change or review what a visitor sees on a site. Look first, plan with the design tokens, build, then test with worst-case data and screenshots. Use for each visible change, or when a page looks plain or generated."
---

# web-ui

The site's `DESIGN.md` holds the tokens and the components. This skill is the recipe. Where the
two disagree, `DESIGN.md` wins.

## House rules

1. **No framework and no build step that the page does not need.** Gleam with Lustre
   (prerendered) or plain HTML and CSS. No Tailwind, no React, no CDN font, no CDN script.
2. **Lower case** in the copy, except acronyms, when the site uses that style.
3. **One accent colour.** Data colours (a score, a severity) are data. They never decorate.
4. **No em dash in copy.** Use a period, a colon or a comma.
5. **Copy**: English in ASD-STE100 (`ste100`), pt-BR with `ptbr-writer` at the `leve` level.
6. **No tracking**: no cookies of your own, no pixel, no third-party request that the privacy
   text does not name.
7. **Accessible**: contrast 4.5:1 or more, a name on each control, icons `aria-hidden` with a
   word next to them, the page works at 390 px wide, `prefers-reduced-motion` stops motion.

## The recipe

1. **Look first.** Build and serve the site. Take screenshots at 390 × 844 and 1280 × 800 with
   Playwright. Write five concrete problems or fewer.
2. **Plan.** Use the tokens of `DESIGN.md`. A new token needs a job that no token does. Add it to
   `DESIGN.md` first.
3. **Build** the smallest change.
4. **Pre-flight**, before you call it done:
   - **AI tells**: a hero with a gradient blob, a bento grid, emoji as icons, a second accent,
     shadows on things that do not float, a pill-shaped card, centred everything.
   - **States**: hover, focus, active, disabled, loading, empty and error for each control.
   - **Motion**: 200 ms or less for a response, ease-out, transform and opacity only. A motion
     needs a reason.
   - **Worst-case data**: a very long name, an unbreakable email, a one-letter name, a missing
     field, zero items, 40 items, a huge number, non-Latin text, emoji. Render them behind a
     clear "demo data" label. Fix what breaks.
5. **Verify.** Run the site checks of the repository. Take the screenshots again.
6. **PR.** Use `pr-images`. No screenshot, not done.

## Red flags

A hex code in a rule, a second accent, a serif that `DESIGN.md` does not name, a font or icon
from a CDN, a control styled on its own, a restyle without opening the page, a token in a
committed file.
