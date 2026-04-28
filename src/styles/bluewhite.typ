// bluewhite: minimal white + blue accent, Inter sans body.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "_inter_overlay.typ": inter-overlay
#import "tufte-original.typ": tufte-original

#let bluewhite = merge-config(tufte-original, (
    page: (fill: none),
    fonts: (
        body:   stacks.inter,
        sans:   stacks.inter,
        mono:   stacks.inter-mono,
        header: stacks.inter,
    ),
    headings: (
        h1: (weight: "semibold", style: "normal"),
        h2: (weight: "semibold", style: "normal"),
        h3: (weight: "medium",   style: "normal"),
    ),
    margin-note: (font: stacks.inter, style: "normal"),
    title-block: (font: auto, weight: "semibold", meta-style: "normal"),
    text: (
        fill: rgb("#0d0d0d"),
        first-line-indent: 0em,
        par-spacing: 1em,
        leading: auto,
    ),
    link: (fill: rgb("#0066cc"), underline: false),
    "html-color-scheme": "light",
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
    "html-extra-css": inter-overlay(
        bg: "#ffffff", fg: "#0d0d0d", link: "#0066cc",
        heading-weight: 600, link-underline: false,
    ),
))
