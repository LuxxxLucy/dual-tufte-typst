// terpret: modeled on https://luxxxlucy.github.io/projects/2020_terpret/terpret.html
// ETBembo body, Colfax sans, Input mono, 12pt, blue link, web-paragraphing.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "tufte-original.typ": tufte-original

#let _colfax = ("Colfax", "Neue Helvetica", "Helvetica Neue", "Helvetica", "Arial")

#let terpret = merge-config(tufte-original, (
    page: (margin-x: 1.1in, margin-y: 1in),
    margin-col: (width: 2.4in, sep: 0.6in),
    fonts: (
        body:   stacks.etbembo,
        sans:   _colfax,
        mono:   ("Input", "SF Mono", "Menlo", "Monaco", "Courier"),
        header: _colfax,
    ),
    sizes: (body: 12pt),
    margin-note: (font: stacks.etbembo, style: "italic"),
    text: (
        first-line-indent: 0em,
        par-spacing: 1.3em,
        leading: auto,
    ),
    link: (fill: rgb("#0055ff"), underline: false),
    css: auto,
))
