// envision — rstudio/tufte's "envisioned" overlay (rstudio.github.io/tufte/envisioned/).
// Thin overlay on tufte-original: Roboto Condensed body, warm #fefefe page,
// #222 text. Heading + sidenote-marker fonts follow `cfg.fonts.body` /
// `cfg.margin-note.font` from pdf.typ, so the body swap covers them too.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "tufte-original.typ": tufte-original

#let envision = merge-config(tufte-original, (
    name: "envision",
    page: (fill: rgb("#fefefe")),
    fonts: (
        body:   stacks.roboto-condensed,
        sans:   stacks.roboto-condensed,
        mono:   stacks.roboto-mono,
        header: stacks.roboto-condensed,
    ),
    // CSS renders 1.4rem on 15px screen base; for print, 9pt + tightened
    // leading (sans reads larger than serif at the same point).
    sizes: (body: 9pt),
    margin-note: (
        font: stacks.roboto-condensed,
        style: "normal",
    ),
    title-block: (font: stacks.roboto-condensed),
    text: (
        fill: rgb("#222222"),
        leading: 0.3em,
    ),
    link: (fill: rgb("#222222"), underline: true),
    css: auto,
))
