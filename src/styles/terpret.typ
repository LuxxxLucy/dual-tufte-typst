// terpret — modeled on https://luxxxlucy.github.io/projects/2020_terpret/terpret.html
// Hybrid serif body (et-book) + Colfax sans + Input mono, 12pt body.
// Bright blue link colour (no underline). Inherits tufte-original's
// geometry and heading shape; only the body size, fonts, link colour
// and web-paragraphing differ.

#import "../config.typ": merge-config
#import "tufte-original.typ": tufte-original

#let terpret = merge-config(tufte-original, (
    name: "terpret",
    page: (
        margin-x: 1.1in,
        margin-y: 1in,
    ),
    margin-col: (
        width: 2.4in,
        sep: 0.6in,
    ),
    fonts: (
        body:   ("et-book", "ETBook", "ETBembo", "Palatino", "Book Antiqua", "Georgia"),
        sans:   ("Colfax", "Neue Helvetica", "Helvetica Neue", "Helvetica", "Arial"),
        mono:   ("Input", "SF Mono", "Menlo", "Monaco", "Courier"),
        header: ("Colfax", "Helvetica Neue", "Helvetica"),
    ),
    sizes: (body: 12pt),
    margin-note: (
        font: ("et-book", "ETBook", "Palatino"),
        style: "italic",
    ),
    text: (
        first-line-indent: 0em,
        par-spacing: 1.3em,
        leading: auto,
    ),
    link: (fill: rgb("#0055ff"), underline: false),
    css: auto,
))
