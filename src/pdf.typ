// PDF-specific implementation

#import "@preview/drafting:0.2.2": margin-note, set-page-properties, set-margin-note-defaults
#import "common.typ": *

#let sidenote-pdf(numbered, dy, body) = {
    if numbered {
        sidenote-counter.step()
        context {
            let num = sidenote-counter.display()
            super(num)
            text(size: font-sizes.tiny, margin-note(tight-par([#super(num) #body]), dy: dy))
        }
    } else {
        text(size: font-sizes.tiny, margin-note(tight-par(body), dy: dy))
    }
}

#let margin-figure-pdf(content, caption, dy) = {
    margin-note({
        set text(font: sans-font, size: font-sizes.small)
        figure(content, caption: caption)
    }, dy: dy)
}

#let full-width-figure-pdf(content, caption) = {
    block(width: full-width-size, figure(content, caption: caption))
}

#let epigraph-pdf(quote, author) = {
    block(width: 55%, inset: (left: 2em), {
        set text(style: "italic", size: font-sizes.normal)
        set par(leading: 1.2em)
        quote
        if author != none {
            linebreak()
            text(style: "normal", size: font-sizes.small, [— ] + author)
        }
    })
}

#let new-thought-pdf(body) = {
    h(-1em)
    smallcaps(body)
}

#let full-width-pdf(body) = block(width: full-width-size, body)

#let sidecite-pdf(key, dy) = {
    sidenote-counter.step()
    context {
        let num = sidenote-counter.display()
        super(num)
        text(size: font-sizes.tiny, margin-note(tight-par([#super(num) #cite(key, form: "full")]), dy: dy))
    }
}

#let render-title-block-pdf(title, author, date) = {
    if title != none {
        set par(first-line-indent: 0em)
        text(font: body-font, size: font-sizes.larger, style: "italic", title)
        if author != none {
            v(0.5em)
            text(font: body-font, size: font-sizes.normal, author)
        }
        if date != none {
            v(0.3em)
            text(font: body-font, size: font-sizes.small, date.display())
        }
        v(2em)
    }
}

#let render-abstract-pdf(abstract) = {
    if abstract != none {
        set par(first-line-indent: 0em)
        text(font: body-font, size: font-sizes.small, style: "italic", abstract)
        v(1.5em)
    }
}

#let render-toc-pdf(toc) = {
    if toc == true {
        outline(title: [Contents], indent: auto, depth: 2)
        v(1.5em)
    }
}

#let setup-pdf(paper, title, author, date, abstract, toc, fonts, body) = {
    set page(paper: paper, margin: (left: 1in, right: 3in, top: 1in, bottom: 1in))

    set-page-properties()
    set-margin-note-defaults(stroke: none, side: right, margin-right: 2in, margin-left: 1in)

    let use-custom-fonts = fonts != auto
    let body-font-family = if use-custom-fonts { fonts.body } else { body-font }
    let sans-font-family = if use-custom-fonts { fonts.sans } else { sans-font }
    let mono-font-family = if use-custom-fonts { fonts.mono } else { mono-font }

    set text(fill: luma(20%))
    set par(first-line-indent: 1em, leading: 1.4em)
    set super(size: 0.65em, baseline: -0.4em)
    set list(indent: 1em, body-indent: 1em, spacing: 0.5em)

    show link: set text(fill: blue)

    show raw.where(block: true): it => {
        set block(above: 1em, below: 1em)
        set text(font: mono-font-family, size: 10pt)
        it
    }
    show raw.where(block: false): set text(font: mono-font-family)

    show figure: it => {
        it.body
        if it.caption != none {
            text(size: font-sizes.small, margin-note(tight-par(it.caption), dy: auto))
        }
    }

    show footnote: it => sidenote-pdf(true, auto, it.body)

    sidenote-counter.update(0)
    render-title-block-pdf(title, author, date)
    render-abstract-pdf(abstract)
    render-toc-pdf(toc)
    apply-common-styles(body, body-font-family: body-font-family, sans-font-family: sans-font-family)
}
