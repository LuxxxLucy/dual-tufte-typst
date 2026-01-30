// PDF-specific implementation

#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#import "common.typ": *

// State to control figure caption vertical offset for main-figure
#let figure-dy-state = state("figure-dy", 0pt)

#let sidenote-pdf(numbered, dy, body) = {
    let dy-value = if dy == auto { 0pt } else { dy }
    if numbered {
        context {
            let num = sidenote-counter.display()
            super(num)
            note(
                dy: dy-value,
                counter: none,
                text-style: (size: font-sizes.tiny),
            )[#super(num) #body]
            sidenote-counter.step()
        }
    } else {
        note(
            dy: dy-value,
            counter: none,
            text-style: (size: font-sizes.tiny),
        )[#body]
    }
}

#let main-figure-pdf(content, caption, dy) = {
    let dy-value = if dy == auto { 0pt } else { dy }
    figure-dy-state.update(dy-value + 1em)
    figure(content, caption: caption)
    figure-dy-state.update(0pt)
}

#let margin-figure-pdf(content, caption, dy) = {
    let dy-value = if dy == auto { 0pt } else { dy }
    notefigure(
        content,
        caption: caption,
        dy: dy-value,
        counter: none,
    )
}

#let full-width-figure-pdf(content, caption) = {
    wideblock(side: "outer", figure(content, caption: caption))
}

#let epigraph-pdf(quote, author) = {
    block(inset: (left: 2em, right: 1em, top: 2em, bottom: 2em), {
        set text(style: "italic", size: 10pt)
        set par(leading: 0.6em)
        quote
        if author != none {
            linebreak()
            align(right)[#text(style: "normal", size: font-sizes.small, [— ] + author)]
        }
    })
}

#let new-thought-pdf(body) = {
    h(-0.3em)
    set text(size: font-sizes.large)
    smallcaps(body)
}

#let full-width-pdf(body) = wideblock(side: "outer", body)

#let sidecite-pdf(key, dy) = {
    let dy-value = if dy == auto { 0pt } else { dy }
    context {
        let num = sidenote-counter.display()
        super(num)
        note(
            dy: dy-value,
            counter: none,
            text-style: (size: font-sizes.tiny),
        )[#super(num) #cite(key, form: "full")]
        sidenote-counter.step()
    }
}

#let sans-pdf(body) = {
  set text(font: sans-font)
  body
}

#let render-title-block-pdf(title, author, date) = {
    if title != none {
        set par(first-line-indent: 0em)
        text(font: body-font, size: font-sizes.huge, style: "italic", weight: "bold", title)
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
    // Marginalia config - matches Tufte layout (1in left, 3in right)
    let marginalia-config = (
        inner: (far: 1in, width: 0in, sep: 0in),  // No inner margin notes
        outer: (far: 0.5in, width: 2in, sep: 0.5in),  // Right margin for notes
        top: 1in,
        bottom: 1in,
        book: false,  // Single-sided like Tufte handout
    )

    // Apply marginalia setup via show rule
    show: marginalia.setup.with(..marginalia-config)

    set page(paper: paper)

    let use-custom-fonts = fonts != auto
    let body-font-family = if use-custom-fonts { fonts.body } else { body-font }
    let sans-font-family = if use-custom-fonts { fonts.sans } else { sans-font }
    let mono-font-family = if use-custom-fonts { fonts.mono } else { mono-font }

    set text(fill: luma(20%))
    set par(first-line-indent: 1em)
    set super(size: 0.65em, baseline: -0.4em)
    set list(indent: 1em, body-indent: 1em, spacing: 0.5em)

    show link: set text(fill: blue)

    show heading.where(level: 1): it => {
        set par(first-line-indent: 0em)
        set text(font: body-font-family, size: font-sizes.huge, style: "italic", weight: "bold")
        v(2em, weak: true)
        block[
          #it.body
        ]
        v(0.5em)
    }

    show heading.where(level: 2): it => {
        set par(first-line-indent: 0em)
        set text(font: body-font-family, size: font-sizes.larger, style: "italic", weight: "regular")
        v(1.5em, weak: true)
        block[
          #it.body
        ]
        v(0.8em)
    }

    show heading.where(level: 3): it => {
        set par(first-line-indent: 0em)
        set text(font: body-font-family, size: font-sizes.large, style: "italic", weight: "regular")
        v(1em, weak: true)
        block[
          #it.body
        ]
        v(0.4em)
    }

    show raw.where(block: true): it => {
        set par(leading: 0.25em)
        block(inset: (left: 2em, right: 0.9em, top: 0.5em, bottom: 0.5em), it)
    }
    show raw.where(block: false): set text(font: mono-font-family)

    show quote.where(block: true): it => {
        block(inset: (left: 2em, right: 1em), {
            set text(size: 10pt)
            set par(leading: 0.6em)
            it.body
            if it.attribution != none {
                linebreak()
                align(right)[#text(size: font-sizes.small, [— ] + it.attribution)]
            }
        })
    }

    show figure: it => {
        context {
            let dy-offset = figure-dy-state.get()
            if it.caption != none and dy-offset != 0pt {
                // Main figure: caption before body with dy offset
                note(
                    dy: dy-offset,
                    counter: none,
                    text-style: (size: font-sizes.small, font: sans-font),
                )[#it.caption]
                it.body
            } else {
                // Other figures: default behavior (body then caption)
                it.body
                if it.caption != none {
                    note(
                        dy: 0pt,
                        counter: none,
                        text-style: (size: font-sizes.small, font: sans-font),
                    )[#it.caption]
                }
            }
        }
    }

    show footnote: it => sidenote-pdf(true, auto, it.body)

    sidenote-counter.update(1)
    render-title-block-pdf(title, author, date)
    render-abstract-pdf(abstract)
    render-toc-pdf(toc)
    body
}
