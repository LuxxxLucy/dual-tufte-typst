// envision: rstudio/tufte's "envisioned" overlay (rstudio.github.io/tufte/envisioned/).
// Roboto Condensed body on warm #fefefe page. Inherits tufte-original sizes
// and headings; only fonts and colours differ.

#import "../config.typ": merge-config
#import "_stacks.typ" as stacks
#import "tufte-original.typ": tufte-original

#let envision = merge-config(tufte-original, (
    // envisioned.css ships no dark-mode rules; force light so dark-OS
    // browsers don't recolor surrounding chrome over a light page.
    "html-color-scheme": "light",
    page: (fill: rgb("#fefefe")),
    fonts: (
        body:   stacks.roboto-condensed,
        sans:   stacks.roboto-condensed,
        mono:   ("Roboto Mono", "Menlo", "Monaco", "Courier New"),
        header: stacks.roboto-condensed,
    ),
    margin-note: (
        font: stacks.roboto-condensed,
        style: "normal",
    ),
    title-block: (font: stacks.roboto-condensed),
    text: (fill: rgb("#222222")),
    link: (fill: rgb("#222222"), underline: true),
    css: (
        "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
        "https://cdn.jsdelivr.net/gh/rstudio/tufte@main/inst/rmarkdown/templates/tufte_html/resources/envisioned.css",
    ),
    // Tufte-css's gradient underline clashes with Roboto descenders.
    "html-extra-css": "a:link, a:visited { text-shadow: none; background-image: none; text-decoration: underline; text-decoration-skip-ink: auto; text-underline-offset: 0.15em; color: inherit; }",
))
