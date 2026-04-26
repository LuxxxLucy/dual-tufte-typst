// envision — rstudio/tufte's "envisioned" variant ported to Typst.
//
// Authoritative source: the `tufte` R package (rstudio/tufte) shipped
// at https://rstudio.github.io/tufte/envisioned/. The envisioned look
// is a thin OVERLAY on the canonical tufte-css base — body switches to
// Roboto Condensed sans, page background warms to #fefefe, body text
// to #222, and `.sidenote-number` / `.numeral` switch to Roboto
// Condensed so the marker glyphs match the body face.
//
// Layered on `tufte-original` because that pivot already encodes the
// tufte-css base (geometry, leading, heading shape, sidenote-number
// sizing, caption font wiring). This file only declares the
// *intentional* envisioned deltas — flipping the typeface from serif
// to sans, swapping page colours.
//
// Heading/sidenote font selection flows from the body change: our
// pdf.typ uses `cfg.fonts.body` for heading text and the sidenote
// number glyph, and `cfg.margin-note.font` for the margin/caption,
// both of which we point at Roboto Condensed.

#import "../config.typ": merge-config
#import "tufte-original.typ": tufte-original

// Roboto Condensed has no italic in our bundled assets/fonts/roboto/
// (Roboto-Italic.ttf is the regular-width italic), so heading italic
// requested by `tufte-original` falls back to plain Roboto italic.
// Acceptable: keeps the italic shape contrast even if the condensed
// width drops on h2/h3.
// `RobotoCondensed` (no space) is the rename baked into
// `assets/fonts/fetch.sh`. Typst 0.14 collapses "Roboto Condensed" into
// the "Roboto" family (suffix-stripping); the no-space form survives.
// Falls through to plain Roboto if fetch.sh hasn't been run.
#let _font-stack = ("RobotoCondensed", "Roboto", "Helvetica Neue", "Helvetica", "Arial")

#let envision = merge-config(tufte-original, (
    name: "envision",
    page: (
        // envisioned.css L25/L21: body bg `#fefefe`, dark text `#222`.
        fill: rgb("#fefefe"),
    ),
    fonts: (
        body:   _font-stack,
        sans:   _font-stack,
        mono:   ("Roboto Mono", "Menlo", "Monaco", "Courier New"),
        header: _font-stack,
    ),
    sizes: (
        // envisioned-css renders at 1.4rem over 15px body — that's a
        // screen size, not a print size. For PDF we keep tufte-original's
        // print scale and scale it down a notch because sans-serif body
        // reads visually larger than serif at the same point size.
        body: 9pt,
    ),
    margin-note: (
        // envisioned drops `.sidenote { font-style: italic }` (rstudio
        // fork inherits tufte-css default which has no italic). Margin
        // font follows body.
        font: _font-stack,
        style: "normal",
    ),
    title-block: (
        font: _font-stack,
        // envisioned subtitle keeps italic (tufte-css `.subtitle` rule
        // inherited unchanged). meta-style stays italic from
        // tufte-original.
    ),
    text: (
        // tufte.css `body { color: #222 }` (rstudio fork L? — confirmed
        // via live demo).
        fill: rgb("#222222"),
        // Sans-serif body reads tighter than serif; trim leading from
        // tufte-original's 0.4em (= 14pt over 10pt body) shoulder so the
        // 9pt envision body doesn't look airy.
        leading: 0.3em,
    ),
    link: (
        // envisioned links keep tufte-css default `color: inherit;
        // text-decoration: none`-with-underline behavior; closest Typst
        // analogue is body-coloured underline.
        fill: rgb("#222222"),
        underline: true,
    ),
    css: auto,
))
