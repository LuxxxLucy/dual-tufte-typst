// claude-tufte — Anthropic blog aesthetic over the Tufte handout.
// Söhne body (Inter fallback), warm #faf9f5 page, dark text #1a1a1a,
// claude-orange #d97757 link accent.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "tufte-original.typ": tufte-original

#let claude-tufte = merge-config(tufte-original, (
    name: "claude-tufte",
    page: (fill: rgb("#faf9f5")),
    fonts: (
        body:   stacks.sohne,
        sans:   stacks.sohne,
        mono:   stacks.sohne-mono,
        header: stacks.sohne,
    ),
    sizes: (body: 11pt),
    headings: (
        // Sans-friendly: medium upright (LaTeX italic doesn't suit Inter/Söhne).
        h1: (weight: "medium",  style: "normal", size: 1.4em),
        h2: (weight: "medium",  style: "normal", size: 1.2em),
        h3: (weight: "regular", style: "normal", size: 1em),
    ),
    margin-note: (font: stacks.sohne, style: "normal"),
    title-block: (font: auto, meta-style: "normal"),
    text: (
        fill: rgb("#1a1a1a"),
        first-line-indent: 0em,
        par-spacing: 1.1em,
        leading: auto,
    ),
    link: (fill: rgb("#d97757"), underline: true),
    css: auto,
))
