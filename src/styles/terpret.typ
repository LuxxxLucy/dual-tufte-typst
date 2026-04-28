// terpret: modeled on https://luxxxlucy.github.io/projects/2020_terpret/terpret.html.
// Sans body (Colfax → Public Sans free fallback), Input mono, link colour
// inherits from body. Inherits all of tufte-original's geometry, sizes,
// and paragraphing — only fonts (and quote-size compensation for sans)
// differ.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "tufte-original.typ": tufte-original

#let terpret = merge-config(tufte-original, (
    fonts: (
        body:   stacks.public-sans,
        sans:   stacks.public-sans,
        mono:   stacks.input-mono,
        header: stacks.public-sans,
    ),
    headings: (
        h1: (weight: "semibold", style: "normal"),
        h2: (weight: "semibold", style: "normal"),
        h3: (weight: "medium",   style: "normal"),
    ),
    margin-note: (font: stacks.public-sans, style: "normal"),
    title-block: (font: auto, weight: "semibold", meta-style: "normal"),
    quote: (size: 1em, leading: 0.5em),
    link: (fill: rgb("#111111"), underline: true),
    "html-color-scheme": "light",
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
    "html-extra-css": "@import url('https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600&display=swap');"
        + "body, .sidenote, .marginnote, .sidenote-number, figcaption,"
        + " h1, h2, h3, h4, h5, h6, .subtitle, .newthought {"
        + " font-family: 'Public Sans', 'Colfax', 'Helvetica Neue', Helvetica, Arial, sans-serif; }"
        + "h1, h2 { font-style: normal; font-weight: 600; }"
        + "h3 { font-style: normal; font-weight: 500; }"
        + "article blockquote, article blockquote p { font-size: 1.4rem; line-height: 2rem; }",
))
