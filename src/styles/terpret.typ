// terpret: tech-nerdy with a hacker / childlike note. Inter body + Space
// Grotesk headings + JetBrains Mono. Warm paper background, ink-blue
// headings, GitHub-blue links. Inspired by
// https://luxxxlucy.github.io/projects/2020_terpret/terpret.html.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "_html_overlay.typ": html-overlay
#import "tufte-original.typ": tufte-original

#let _bg = "#FAF7F0"
#let _fg = "#1B1B1F"
#let _link = "#1F6FEB"
#let _heading = "#0F2A4A"
#let _note = "#4A4A52"

#let terpret = merge-config(tufte-original, (
    page: (fill: rgb(_bg)),
    fonts: (
        body:   stacks.inter,
        sans:   stacks.inter,
        mono:   stacks.jetbrains-mono,
        header: stacks.space-grotesk,
    ),
    headings: (
        h1: (weight: "medium",   style: "normal"),
        h2: (weight: "medium",   style: "normal"),
        h3: (weight: "medium",   style: "normal"),
    ),
    margin-note: (font: stacks.inter, style: "normal"),
    title-block: (font: stacks.space-grotesk, weight: "medium", meta-style: "normal"),
    text: (fill: rgb(_fg)),
    quote: (size: 1em, leading: 0.5em),
    link: (fill: rgb(_link), underline: true),
    "html-color-scheme": "light",
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
    "html-extra-css": html-overlay(
        import-css: "@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Space+Grotesk:wght@500;700&family=JetBrains+Mono:wght@400;700&display=swap');",
        body-font: "'Inter', system-ui, sans-serif",
        heading-font: "'Space Grotesk', 'Inter', system-ui, sans-serif",
        mono-font: "'JetBrains Mono', ui-monospace, monospace",
        bg: _bg, fg: _fg, link: _link, heading-color: _heading, note-color: _note,
        link-underline: true,
        body-size: "1.05rem", body-line-height: "1.55",
        extra: " article h2 { border-bottom: 1px solid #D8D2C2; padding-bottom: 0.2em; }"
            + " code:not(pre code) { background: #F1ECDC; padding: 0.1em 0.3em; border-radius: 3px; font-size: 0.92em; }",
    ),
))
