// bluewhite: pure, elegant, heaven-like. Single-family Source Serif 4 for
// body and headings (optical-size axis carries the contrast); celestial
// gray-blue links and marginalia accents on a near-white warm paper.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "_html_overlay.typ": html-overlay
#import "tufte-original.typ": tufte-original

#let _bg = "#FBFAF7"
#let _fg = "#1F2330"
#let _link = "#3B5A86"
#let _heading = "#16203A"
#let _note = "#7A8BA6"

#let bluewhite = merge-config(tufte-original, (
    page: (fill: rgb(_bg)),
    fonts: (
        body:   stacks.source-serif,
        sans:   stacks.source-serif,
        mono:   stacks.jetbrains-mono,
        header: stacks.source-serif,
    ),
    headings: (
        h1: (weight: "semibold", style: "normal"),
        h2: (weight: "semibold", style: "normal"),
        h3: (weight: "regular",  style: "italic"),
    ),
    margin-note: (font: stacks.source-serif, style: "italic"),
    title-block: (font: stacks.source-serif, weight: "semibold", meta-style: "italic"),
    text: (fill: rgb(_fg)),
    quote: (size: 1.1em, leading: 0.55em),
    link: (fill: rgb(_link), underline: false),
    "html-color-scheme": "light",
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
    "html-extra-css": html-overlay(
        import-css: "@import url('https://fonts.googleapis.com/css2?family=Source+Serif+4:ital,opsz,wght@0,8..60,300..700;1,8..60,300..700&family=JetBrains+Mono:wght@400;500&display=swap');",
        body-font: "'Source Serif 4', Georgia, serif",
        heading-font: "'Source Serif 4', Georgia, serif",
        mono-font: "'JetBrains Mono', ui-monospace, monospace",
        bg: _bg, fg: _fg, link: _link, heading-color: _heading, note-color: _note,
        link-underline: false,
        body-size: "1.05rem", body-line-height: "1.6",
        quote-size: "1.5rem", quote-line-height: "2.1rem",
        extra: " body { font-optical-sizing: auto; }"
            + " article blockquote, article blockquote p { color: " + _note + "; font-style: italic; }",
    ),
))
