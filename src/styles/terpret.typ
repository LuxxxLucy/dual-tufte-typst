// terpret: modeled on https://luxxxlucy.github.io/projects/2020_terpret/terpret.html.
// The live page uses standard tufte-css (et-book + Gill Sans + Consolas mono),
// 15px html base, with web-style paragraphing (paragraph gap, no first-line
// indent). This style preserves that — same font config as tufte-original;
// only paragraph rhythm and slightly looser margins differ.

#import "../config.typ": merge-config
#import "tufte-original.typ": tufte-original

#let terpret = merge-config(tufte-original, (
    page: (margin-x: 1.1in, margin-y: 1in),
    margin-col: (width: 2.4in, sep: 0.6in),
    text: (
        first-line-indent: 0em,
        par-spacing: 1.3em,
        leading: auto,
    ),
))
