---
name: pr-images
description: "Open or update a bilingual PR like bipr, with before and after images in its body. Use for each PR that changes an image, a drawing, a page or a screen, or for /bipri."
disable-model-invocation: true
---

# pr-images

This skill is `bipr` with images. Do all the steps of `bipr`, in its order. Then do the steps
below. A change with no visible effect uses `bipr` only.

## 1. Capture before and after

1. Render the state of the base branch (`origin/<base>`) and the state of `HEAD`. Use the same
   size and the same background. Use the Playwright Chromium for SVG, HTML and pages.
2. Save the images in `docs/screenshots/<topic>/`: `before.png` and `after.png`. When the image
   proves a rule (a size, a grid, a ratio), add a third image that shows the proof.
3. Commit the images on the same branch. An image outside the repository does not go in the PR.
4. Keep the licence check of the repository green for each new file.

## 2. Write the body

Add an **Imagens** section to the pt-BR half and an **Images** section to the English half,
after **O que mudou** and **What changed**:

```
**Images**

| Before | After |
|---|---|
| ![before](<url of before.png>) | ![after](<url of after.png>) |

<one sentence: what the proof image shows>
```

- The URL of an image is `https://github.com/<owner>/<repo>/blob/<branch>/<path>?raw=true`.
- The two halves show the same images. Only the text changes language.
- The image does not replace the text. The summary says what changed without the image.

## 3. Footer

The footer is the `footer.md` of `bipr`, unchanged.
