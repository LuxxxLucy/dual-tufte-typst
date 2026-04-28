// orange-happy: humanistic warm. Newsreader body + Fraunces headings on
// cream paper, burnt-orange ink links. Aim is a hand-bound book under
// lamp light, not a corporate sans on white.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "_html_overlay.typ": html-overlay
#import "tufte-original.typ": tufte-original

#let _bg = "#f7f3ea"
#let _fg = "#2b2620"
#let _link = "#c2410c"
#let _heading = "#1f1a14"
#let _note = "#6b5d4f"

#let orange-happy = merge-config(tufte-original, (
    page: (fill: rgb(_bg)),
    fonts: (
        body:   stacks.newsreader,
        sans:   stacks.newsreader,
        mono:   stacks.jetbrains-mono,
        header: stacks.fraunces,
    ),
    headings: (
        h1: (weight: "semibold", style: "normal"),
        h2: (weight: "semibold", style: "normal"),
        h3: (weight: "medium",   style: "italic"),
    ),
    margin-note: (font: stacks.newsreader, style: "italic"),
    title-block: (font: stacks.fraunces, weight: "semibold", meta-style: "italic"),
    text: (fill: rgb(_fg)),
    quote: (size: 1.1em, leading: 0.55em),
    link: (fill: rgb(_link), underline: true),
    "html-color-scheme": "light",
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
    "html-extra-css": html-overlay(
        import-css: "@import url('https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,400;0,6..72,500;0,6..72,600;1,6..72,400&family=Fraunces:opsz,wght@9..144,500;9..144,600&family=JetBrains+Mono:wght@400;500&display=swap');",
        body-font: "'Newsreader', Georgia, serif",
        heading-font: "'Fraunces', 'Newsreader', Georgia, serif",
        mono-font: "'JetBrains Mono', ui-monospace, monospace",
        bg: _bg, fg: _fg, link: _link, heading-color: _heading, note-color: _note,
        link-underline: true,
        body-size: "1.05rem", body-line-height: "1.6",
        quote-size: "1.5rem", quote-line-height: "2.1rem",
        extra: " body { font-optical-sizing: auto; }"
            + " article blockquote, article blockquote p { color: #5a4f42; font-style: italic; border-left: none; }"
            + " article blockquote { padding-left: 1.5em; padding-right: 1.5em; }"
            + " hr { border: none; border-top: 1px solid #d9cdb8; width: 40%; margin: 2em auto; }",
    ),
))
