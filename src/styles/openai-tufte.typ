// openai-tufte — OpenAI blog aesthetic over the Tufte handout.
// Söhne body (Inter fallback), white page, near-black text, geometric
// upright headings, OpenAI green link.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "tufte-original.typ": tufte-original

#let openai-tufte = merge-config(tufte-original, (
    name: "openai-tufte",
    page: (fill: none),
    fonts: (
        body:   stacks.sohne,
        sans:   stacks.sohne,
        mono:   stacks.sohne-mono,
        header: stacks.sohne,
    ),
    sizes: (body: 10.5pt),
    headings: (
        h1: (weight: "semibold", style: "normal", size: 1.5em),
        h2: (weight: "semibold", style: "normal", size: 1.2em),
        h3: (weight: "medium",   style: "normal", size: 1em),
    ),
    margin-note: (font: stacks.sohne, style: "normal"),
    title-block: (font: auto, weight: "semibold", meta-style: "normal"),
    text: (
        fill: rgb("#0d0d0d"),
        first-line-indent: 0em,
        par-spacing: 1em,
        leading: auto,
    ),
    link: (fill: rgb("#10a37f"), underline: false),
    css: auto,
))
