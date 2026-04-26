// claude-tufte — Anthropic blog aesthetic in a Tufte two-column handout.
// Modern sans body (Söhne / Inter system fallback), warm off-white #faf9f5
// page, dark text #1a1a1a, "claude orange" #d97757 reserved for accent.
// Söhne is commercial — falls through to Inter (free) / system-ui.
//
// Inherits tufte-original's geometry/headings; overrides body face,
// page colour, link accent, and switches to web-paragraphing.

#import "../config.typ": merge-config
#import "tufte-original.typ": tufte-original

#let claude-tufte = merge-config(tufte-original, (
    name: "claude-tufte",
    page: (fill: rgb("#faf9f5")),
    fonts: (
        body:   ("Söhne", "Inter", "Helvetica Neue", "Helvetica", "Arial"),
        sans:   ("Söhne", "Inter", "Helvetica Neue", "Helvetica", "Arial"),
        mono:   ("Söhne Mono", "JetBrains Mono", "Menlo", "Monaco"),
        header: ("Söhne", "Inter", "Helvetica Neue"),
    ),
    sizes: (body: 11pt),
    headings: (
        // Sans-friendly: medium weight, upright (LaTeX italic doesn't
        // suit Inter/Söhne). Spacing matches tufte-original.
        h1: (weight: "medium",  style: "normal", size: 1.4em),
        h2: (weight: "medium",  style: "normal", size: 1.2em),
        h3: (weight: "regular", style: "normal", size: 1em),
    ),
    margin-note: (
        font: ("Söhne", "Inter", "Helvetica Neue"),
        style: "normal",
    ),
    title-block: (
        font: auto,
        meta-style: "normal",
    ),
    text: (
        fill: rgb("#1a1a1a"),
        first-line-indent: 0em,
        par-spacing: 1.1em,
        leading: auto,
    ),
    link: (fill: rgb("#d97757"), underline: true),
    css: auto,
))
