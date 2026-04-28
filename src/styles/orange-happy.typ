// orange-happy: warm cream + orange accent, Inter sans body.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "_inter_overlay.typ": inter-overlay
#import "tufte-original.typ": tufte-original

#let orange-happy = merge-config(tufte-original, (
    page: (fill: rgb("#faf9f5")),
    fonts: (
        body:   stacks.inter,
        sans:   stacks.inter,
        mono:   stacks.inter-mono,
        header: stacks.inter,
    ),
    headings: (
        h1: (weight: "medium",  style: "normal"),
        h2: (weight: "medium",  style: "normal"),
        h3: (weight: "regular", style: "normal"),
    ),
    margin-note: (font: stacks.inter, style: "normal"),
    title-block: (font: auto, meta-style: "normal"),
    text: (
        fill: rgb("#1a1a1a"),
        first-line-indent: 0em,
        par-spacing: 1.1em,
        leading: auto,
    ),
    quote: (size: 1em, leading: 0.5em),
    link: (fill: rgb("#d97757"), underline: true),
    "html-color-scheme": "light",
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
    "html-extra-css": inter-overlay(
        bg: "#faf9f5", fg: "#1a1a1a", link: "#d97757",
        heading-weight: 500, link-underline: true,
    ),
))
