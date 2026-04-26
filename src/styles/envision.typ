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
    // tufte.css first, envisioned.css overlay second (cascade order: the
    // overlay swaps body font, bg, colour and `.numeral`, `.sidenote-number`
    // font; its `@import` pulls Roboto Condensed).
    css: (
        "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
        "https://cdn.jsdelivr.net/gh/rstudio/tufte@main/inst/rmarkdown/templates/tufte_html/resources/envisioned.css",
    ),
    // Override tufte-css link underline (gradient clashes with Roboto descenders).
    "html-extra-css": "a:link, a:visited { text-shadow: none; background-image: none; text-decoration: underline; text-decoration-skip-ink: auto; text-underline-offset: 0.15em; color: inherit; }",
))
