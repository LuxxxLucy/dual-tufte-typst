// Dual-format Tufte Typst Template
//
// A Typst template implementing Edward Tufte's design principles with
// dual-format output: PDF and HTML from a single source.
//
// Author: Jialin Lu <luxxxlucy@gmail.com>
// License: MIT
//
// References:
//   Tufte LaTeX:
//     - https://github.com/Tufte-LaTeX/tufte-latex
//
//   Tufte CSS:
//     - https://github.com/edwardtufte/tufte-css
//
//   Tufte using Typst (PDF output):
//     - https://github.com/nogula/tufte-memo
//     - https://github.com/fredguth/tufte-typst
//     - https://codeberg.org/jianweicheong/toffee-tufte
//     - https://github.com/maucejo/bookly
//
//   Tufte using Typst (HTML output):
//     - https://github.com/vsheg/tufted
//     - https://github.com/Yousa-Mirage/Tufted-Blog-Template

#import "common.typ": sidenote-counter, resolve-font, default-body-font, default-sans-font, default-mono-font
#import "pdf.typ"
#import "html.typ"

#let is-html() = sys.inputs.at("target", default: "pdf") == "html"

// Public API

#let sidenote(numbered: true, dy: auto, body) = context {
    if is-html() {
        html.sidenote-html(numbered, body)
    } else {
        pdf.sidenote-pdf(numbered, dy, body)
    }
}

#let marginnote(dy: auto, body) = sidenote(numbered: false, dy: dy, body)

#let margin-figure(content, caption: none, dy: auto) = context {
    if is-html() {
        html.margin-figure-html(content, caption)
    } else {
        pdf.margin-figure-pdf(content, caption, dy)
    }
}

#let full-width-figure(content, caption: none) = context {
    if is-html() {
        html.full-width-figure-html(content, caption)
    } else {
        pdf.full-width-figure-pdf(content, caption)
    }
}

#let epigraph(quote, author: none) = context {
    if is-html() {
        html.epigraph-html(quote, author)
    } else {
        pdf.epigraph-pdf(quote, author)
    }
}

#let new-thought(body) = context {
    if is-html() {
        html.new-thought-html(body)
    } else {
        pdf.new-thought-pdf(body)
    }
}

#let full-width(body) = context {
    if is-html() {
        html.full-width-html(body)
    } else {
        pdf.full-width-pdf(body)
    }
}

#let sidecite(key, dy: auto) = context {
    if is-html() {
        html.sidecite-html(key)
    } else {
        pdf.sidecite-pdf(key, dy)
    }
}

// Main template

#let tufte(
    title: none,
    author: none,
    date: none,
    abstract: none,
    lang: "en",
    toc: false,
    paper: "us-letter",
    bib: none,
    html-css: auto,
    body-font: auto,
    sans-font: auto,
    mono-font: auto,
    body
) = {
    set text(lang: lang)

    if is-html() {
        html.setup-html(title, author, date, abstract, toc, lang, html-css, body)
    } else {
        let fonts = if body-font == auto and sans-font == auto and mono-font == auto {
            auto
        } else {
            (
                body: resolve-font(body-font, default-body-font),
                sans: resolve-font(sans-font, default-sans-font),
                mono: resolve-font(mono-font, default-mono-font),
            )
        }
        pdf.setup-pdf(paper, title, author, date, abstract, toc, fonts, body)
    }

    if bib != none {
        bib
    }
}
