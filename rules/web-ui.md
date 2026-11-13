---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.html"
  - "**/*.vue"
  - "**/*.svelte"
  - "**/*.astro"
---
# Web UI

- Before building or restyling UI, load `impeccable` (existing product) or `hallmark` (new site / redesign). Decide the visual direction, type pairing, and palette first; write them as CSS custom properties / Tailwind theme tokens, not scattered literals.
- Tailwind v4: theme lives in CSS (`@theme`), not `tailwind.config.js`. Don't fight the project's existing token names.
- Layout must hold at 320, 375, 768, 1024, 1440 px with no horizontal scroll. Check in the browser, not by reasoning.
- Both themes, if the project has dark mode: each must look intentional, not inverted.
- Motion: `transform`/`opacity` only, 150–300 ms for UI feedback, ease-out for entrances, and `prefers-reduced-motion` disables non-essential motion. No scroll listeners where IntersectionObserver or CSS scroll-driven animations work.
- Images: explicit `width`/`height` (or `fill` + sized parent), `next/image` in Next, `priority` only for the LCP image, AVIF/WebP.
- Fonts: at most two families, `next/font` or self-hosted with `font-display: swap`.
- Accessibility is part of "done": real `<button>`/`<a>`, labelled inputs, visible focus ring, contrast ≥ 4.5:1 for body text, alt text that describes purpose, logical heading order.
- Copy is content, not filler: real business details from the project or the user. If you don't have them, leave a clearly marked gap and say so, never invent testimonials, numbers, or addresses.
