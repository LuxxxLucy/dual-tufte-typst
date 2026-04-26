// Smoke-test the tufte-handout-compat shim — original handout API on top
// of our dual-output template.
#import "../../../../src/tufte-handout-compat.typ": *

#show: template.with(
    title: "Handout compat smoke",
    name: "Jialin Lu",
    date: "2026-04",
)

Body using the handout's `sidenote` shape#sidenote[Single-positional sidenote, just like the original handout.] should compile through the dual template.

= Heading via handout `template`

A second paragraph; `template` swaps `name`→`author` so the byline still renders.
