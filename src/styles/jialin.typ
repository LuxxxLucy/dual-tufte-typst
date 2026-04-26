// jialin — Mr. Lucy's web-handout look. Layered on `tufte-original` so
// the layout invariants (geometry, leading ratios, heading shape, caption
// font selection) stay consistent across the gallery; this file only
// declares the *intentional* deltas vs. the LaTeX-faithful baseline:
//
//   * 9pt body (matches the bezierlogue handout — ETBembo reads tighter
//     at 10pt than ETBook does in print).
//   * Gill Sans for the title block + running header (web-handout
//     convention; LaTeX uses italic body serif).
//   * Web-style paragraphing: no first-line indent, gap between paragraphs
//     instead.
//   * Italic Gill Sans margin/sidenote/caption (mirrors `sfsidenotes`
//     option in tufte-handout, but italic for visual softness).

#import "../config.typ": merge-config
#import "tufte-original.typ": tufte-original

#let jialin = merge-config(tufte-original, (
    name: "jialin",
    page: (
        margin-x: 0.68in,
        margin-y: 2cm,
        fill: none,
    ),
    margin-col: (
        width: 2.25in,
        sep: 0.7in,
    ),
    sizes: (
        body: 9pt,
        // Section heads scaled down a little since body shrank.
        large: 1.1em,
        larger: 1.2em,
        huge: 1.8em,
        header: 5pt,
    ),
    headings: (
        h1: (weight: "extralight", size: 1.2em, style: "italic", v-before: 0.35em, v-after: -0.3em),
        h2: (weight: "extralight", size: 1em,   style: "italic", v-before: 0.4em,  v-after: 0.1em),
        h3: (weight: "extralight", size: 1em,   style: "italic", v-before: 0.4em,  v-after: 0.1em),
    ),
    margin-note: (
        size: 0.65em,
        font: ("Gill Sans", "Helvetica"),
        style: "italic",
        leading: 0.5em,
        marker-sep: 0.4em,
    ),
    fonts: (
        sans: ("Gill Sans", "Helvetica"),
        header: ("Berkeley Mono", "Menlo", "Monaco"),
    ),
    header: (
        size: 5pt,
        weight: "bold",
        tracking: 1.25pt,
        upper: true,
    ),
    title-block: (
        size: 1.8em,
        font: ("Gill Sans", "Helvetica"),
        meta-size: 0.85em,
        meta-style: "normal",
        meta-sep: 1.2em,
        v-after: 2em,
    ),
    text: (
        fill: luma(20%),
        first-line-indent: 0em,
        par-spacing: auto,
        leading: auto,
    ),
    link: (fill: blue, underline: true),
))
