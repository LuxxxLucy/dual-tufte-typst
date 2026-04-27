// Compat shim — re-exposes the public API of
// research_statement/tufte-handout.typ on top of `tufte()` + config.
//
// Lets a document written for the standalone handout template compile
// against this dual-output template unchanged. Used by tests/reproductions/
// to drive the originals through `tufte()` for both PDF and HTML output.
//
// Usage from a reproduction wrapper:
//
//   #import "../../../src/tufte-handout-compat.typ": *
//   #include "source.typ"

#import "lib.typ": tufte, sidenote as _dual-sidenote, marginnote
#import "@preview/marginalia:0.3.1": note as _m-note, notefigure as _m-notefigure, wideblock as _m-wideblock

// Re-export marginalia primitives so docs that `import *` still see them.
#let note = _m-note
#let notefigure = _m-notefigure
#let wideblock = _m-wideblock

// `template(title:, name:, date:, email:, wrapper:, doc)` — handout signature.
// Maps `name` → `author`, ignores `wrapper` (our `tufte()` applies its own
// heading rules from config). Pass-through for `bib` etc. via `..rest`.
#let template(
    title: none,
    name: none,
    email: none,
    date: none,
    wrapper: none,
    config: (:),
    doc,
) = {
    show: tufte.with(
        title: title,
        author: name,
        email: email,
        date: date,
        // The standalone handout calibrates against the `jialin` look
        // (web-handout body 9pt, Gill Sans title); pin it so reproductions
        // remain stable when the dual-template default changes.
        style: "jialin",
        config: config,
    )
    doc
}

// Sidenote / margin-note in the handout are single-positional; ours match.
#let sidenote(body) = _dual-sidenote(body)
#let margin-note(body) = marginnote(body)

// Inline note in the main column — small italic block, not a margin note.
// Defined inline by the handout; mirror it here.
#let main-note(content) = {
    pad(left: 0.5em,
        block(width: 100%, {
            set text(size: 0.75em, font: "Gill Sans", style: "italic")
            set align(left)
            content
        })
    )
    v(0.5em)
}

// Debug note — only renders when compiled with `--input debug=on`.
#let debug-note(content) = {
    if sys.inputs.keys().contains("debug") {
        block(width: 100%, {
            set text(size: 0.75em, style: "italic", fill: rgb(0, 0, 255))
            set align(left)
            v(-0.4em)
            h(3em)
            content
        })
    }
}

// Title-block helper exported by the handout. Most docs let `template`
// render the title for them, but a few call it directly.
#let show_header(title, name: none, date: none, email: none) = {
    block(width: 100%)[
        #h(-0.1em)
        #text(weight: "regular", 1.8em)[#title]
        #if name != none {
            v(0.3em)
            text(0.7em, font: "Gill Sans")[#name]
        }
        #if email != none {
            text(0.7em, font: "Gill Sans")[#h(1.2em) #email]
        }
        #if date != none {
            text(0.7em, font: "Gill Sans")[#h(1.2em) #date]
        }
        #v(3em)
    ]
}

// Cite shorthands.
#let citet(..citation) = cite(..citation, form: "prose")
#let citep(..citation) = cite(..citation, form: "normal")

// Gray-shaded box. Intentionally shadows Typst's built-in `box` (the
// original handout does too).
#let box(contents) = {
    rect(
        fill: rgb(242, 242, 242),
        stroke: 0.5pt,
        width: 100%,
        align(center)[#contents],
    )
}

#let figure-caption(content) = {
    set text(size: 0.7em, style: "italic")
    align(center)[#content]
}

#let nonumeq(eq) = math.equation(block: true, numbering: none, eq)
#let numeq(eq) = math.equation(block: true, numbering: none, eq)
