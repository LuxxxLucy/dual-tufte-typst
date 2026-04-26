// openai-tufte — OpenAI blog aesthetic in a Tufte two-column handout.
// Söhne sans body (Inter fallback), pure white page, near-black text.
// Geometric headings (semibold, upright); OpenAI green link accent.
// Söhne is commercial — falls through to Inter / system-ui.
//
// Inherits tufte-original's geometry/headings; overrides body face,
// link accent, and switches to web-paragraphing.

#import "../config.typ": merge-config
#import "tufte-original.typ": tufte-original

#let openai-tufte = merge-config(tufte-original, (
    name: "openai-tufte",
    page: (fill: none),
    fonts: (
        body:   ("Söhne", "Inter", "Helvetica Neue", "Helvetica", "Arial"),
        sans:   ("Söhne", "Inter", "Helvetica Neue", "Helvetica", "Arial"),
        mono:   ("Söhne Mono", "JetBrains Mono", "Menlo", "Monaco"),
        header: ("Söhne", "Inter", "Helvetica Neue"),
    ),
    sizes: (body: 10.5pt),
    headings: (
        h1: (weight: "semibold", style: "normal", size: 1.5em),
        h2: (weight: "semibold", style: "normal", size: 1.2em),
        h3: (weight: "medium",   style: "normal", size: 1em),
    ),
    margin-note: (
        font: ("Söhne", "Inter", "Helvetica Neue"),
        style: "normal",
    ),
    title-block: (
        font: auto,
        weight: "semibold",
        meta-style: "normal",
    ),
    text: (
        fill: rgb("#0d0d0d"),
        first-line-indent: 0em,
        par-spacing: 1em,
        leading: auto,
    ),
    link: (fill: rgb("#10a37f"), underline: false),
    css: auto,
))
