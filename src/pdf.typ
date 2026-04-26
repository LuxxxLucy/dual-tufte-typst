// PDF target — handout style on top of the marginalia package.

#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#import "config.typ": default-config

#let _config-state = state("dual-tufte-config", default-config)
#let _cfg() = _config-state.get()

// figure show-rule reads this to decide caption dy offset.
#let figure-dy-state = state("figure-dy", 0pt)
// Set inside `margin-figure-pdf` (which calls marginalia.notefigure, and
// notefigure internally uses figure(...)). Without this gate, our show rule
// stomps on notefigure's own caption rendering and the caption disappears.
#let _in-margin-figure = state("in-margin-figure", false)

#let _dy(dy) = if dy == auto { 0pt } else { dy }

#let _margin-text-style(cfg) = (
    size: cfg.margin-note.size,
    font: cfg.margin-note.font,
    style: cfg.margin-note.style,
)
#let _margin-par-style(cfg) = (leading: cfg.margin-note.leading)
// Shared caption text style — every figure caption (regular, main-figure,
// margin-figure, full-width) routes through this so font / style / size
// stay consistent across figure kinds. Tufte-LaTeX:
// `\@tufte@caption@font = \@tufte@marginfont`, so the caption inherits
// the margin-note font.
#let _caption-style(cfg) = (
    size: cfg.sizes.small,
    font: cfg.margin-note.font,
    style: cfg.margin-note.style,
)

// Body-font superscript, sized independently for the anchor (smaller —
// reads as a reference mark in body text) and the margin-side label
// (larger — needs to stand out against the smaller margin text).
#let _sn-num(size, font, i) = super(
    typographic: false,
    baseline: -0.5em,
    size: size,
    text(font: font, numbering("1", ..i)),
)
#let _sn-margin-mark(cfg) = (..i) => [#_sn-num(cfg.sidenote-number.margin-size, cfg.fonts.body, i.pos())#h(cfg.margin-note.marker-sep)]
#let _sn-anchor-mark(cfg) = (..i) => _sn-num(cfg.sidenote-number.anchor-size, cfg.fonts.body, i.pos())

#let sidenote-pdf(numbered, dy, body) = context {
    let cfg = _cfg()
    let kw = if numbered {
        (numbering: _sn-margin-mark(cfg), anchor-numbering: _sn-anchor-mark(cfg))
    } else {
        (counter: none,)
    }
    note(
        dy: _dy(dy),
        text-style: _margin-text-style(cfg),
        par-style: _margin-par-style(cfg),
        ..kw,
    )[#body]
}

#let main-figure-pdf(content, caption, dy) = {
    figure-dy-state.update(_dy(dy))
    figure(content, caption: caption)
    figure-dy-state.update(0pt)
}

#let margin-figure-pdf(content, caption, dy) = context {
    _in-margin-figure.update(true)
    notefigure(
        content,
        caption: caption,
        dy: _dy(dy),
        counter: none,
        text-style: _caption-style(_cfg()),
    )
    _in-margin-figure.update(false)
}

// Full-width figure spans the main column + margin; caption hoisted into
// the right margin column via marginalia.note so it sits inside the
// margin like main-figure captions (matches tufte-css `.fullwidth figcaption`
// which floats right with margin-right: 24%).
#let full-width-figure-pdf(content, caption) = context {
    let cfg = _cfg()
    wideblock(side: "outer", content)
    if caption != none {
        note(dy: 0pt, counter: none, text-style: _caption-style(cfg))[#caption]
    }
}

#let epigraph-pdf(quote, author) = context {
    let cfg = _cfg()
    block(inset: (left: 2em, right: 1em, top: 2em, bottom: 2em), {
        set text(style: "italic", size: cfg.sizes.normal * 1.25)
        set par(leading: 0.6em)
        quote
        if author != none {
            linebreak()
            align(right)[#text(style: "normal", size: cfg.sizes.small, [— ] + author)]
        }
    })
}

// Synthetic small-caps. `smallcaps()` and `text(features: ("smcp",))`
// silently no-op when the font lacks smcp glyphs (typst#7009 — open;
// docs say synthesis is "not yet implemented"). ETBook/Palatino on
// macOS fall in that bucket. Recipe: uppercase lowercase runs and
// shrink them so original capitals retain full body size — proper
// small-caps appearance on any font.
#let new-thought-pdf(body) = context {
    let nt = _cfg().newthought
    show regex("\p{Ll}+"): m => text(size: nt.lowercase-scale * 1em, upper(m.text))
    text(size: nt.size, tracking: nt.tracking, body)
}

#let full-width-pdf(body) = wideblock(side: "outer", body)

#let sidecite-pdf(key, dy) = context {
    let cfg = _cfg()
    note(
        dy: _dy(dy),
        numbering: _sn-margin-mark(cfg),
        anchor-numbering: _sn-anchor-mark(cfg),
        text-style: _margin-text-style(cfg),
        par-style: _margin-par-style(cfg),
    )[#cite(key, form: "full")]
}

#let sans-pdf(body) = context {
    set text(font: _cfg().fonts.sans)
    body
}

#let _render-header(title, cfg) = {
    if title == none { return }
    set text(
        size: cfg.header.size,
        weight: cfg.header.weight,
        tracking: cfg.header.tracking,
        font: cfg.fonts.header,
    )
    // Push the header out into the right margin column rather than over
    // the main column.
    let push = -(cfg.margin-col.width + cfg.margin-col.sep / 2)
    pad(right: push, align(right, if cfg.header.upper { upper(title) } else { title }))
    v(2.5em)
}

#let _render-title-block(title, author, email, date, cfg) = {
    if title == none { return }
    set par(first-line-indent: 0em)
    let title-text-args = (
        weight: cfg.title-block.weight,
        size: cfg.title-block.size,
    )
    if cfg.title-block.font != auto {
        title-text-args.insert("font", cfg.title-block.font)
    }
    let meta-style = cfg.title-block.at("meta-style", default: "normal")
    // tufte-original keeps metadata in the body serif (italic, matching
    // tufte-css `.subtitle`). Other styles default to sans Gill Sans.
    let meta-font = if meta-style == "italic" { cfg.fonts.body } else { cfg.fonts.sans }
    let meta-args = (size: cfg.title-block.meta-size, font: meta-font, style: meta-style)
    block(width: 100%)[
        #h(-0.1em)
        #text(..title-text-args, title)
        #if author != none {
            v(0.3em)
            text(..meta-args, author)
        }
        #if email != none {
            text(..meta-args)[#h(cfg.title-block.meta-sep)#email]
        }
        #if date != none {
            let d = if type(date) == datetime { date.display() } else { date }
            text(..meta-args)[#h(cfg.title-block.meta-sep)#d]
        }
        #v(cfg.title-block.v-after)
    ]
}

#let _render-abstract(abstract, cfg) = {
    if abstract == none { return }
    set par(first-line-indent: 0em)
    text(font: cfg.fonts.body, size: cfg.sizes.small, style: "italic", abstract)
    v(1.5em)
}

#let _render-toc(toc) = {
    if toc != true { return }
    outline(title: [Contents], indent: auto, depth: 2)
    v(1.5em)
}

// Heading rule factory. h1 gets a small negative h() so the italic body
// doesn't visually creep right of the baseline; h2/h3 don't need it.
#let _heading-rule(spec, lead-kern: 0em) = it => {
    set par(first-line-indent: 0em)
    text(weight: spec.weight, size: spec.size, style: spec.style, {
        v(spec.v-before)
        if lead-kern != 0em { h(lead-kern) }
        it.body
        v(spec.v-after)
    })
}

#let setup-pdf(config, title, author, email, date, abstract, toc, body) = {
    let cfg = config
    _config-state.update(cfg)

    set page(
        paper: cfg.page.paper,
        fill: cfg.page.at("fill", default: none),
        header: if title != none { _render-header(title, cfg) },
    )

    show: marginalia.setup.with(
        inner: (far: cfg.page.margin-x, width: 0pt, sep: 0pt),
        outer: (far: cfg.page.margin-x, width: cfg.margin-col.width, sep: cfg.margin-col.sep),
        top: cfg.page.margin-y,
        bottom: cfg.page.margin-y,
        book: false,
    )

    set text(
        font: cfg.fonts.body,
        size: cfg.sizes.body,
        fill: cfg.text.fill,
        // Hyphenation explicit so it stays on even if a doc passes a
        // `lang:` Typst's auto-resolver can't load patterns for. Belt and
        // suspenders against tight justified columns producing visible
        // inter-word stretch (no microtype-equivalent in Typst — issue
        // typst#638 — so good hyphenation is the only knob we have).
        hyphenate: true,
    )
    set par(
        first-line-indent: cfg.text.first-line-indent,
        justify: cfg.text.at("justify", default: true),
    )
    let leading = cfg.text.at("leading", default: auto)
    if leading != auto { set par(leading: leading) }
    if cfg.text.par-spacing != auto {
        set par(spacing: cfg.text.par-spacing)
    }
    set list(indent: 1em, body-indent: 1em)
    set enum(indent: 1em, body-indent: 1em)
    show enum: set par(justify: true)
    show list: set par(justify: true)

    if cfg.link.underline { show link: underline }
    show link: set text(fill: cfg.link.fill)

    set math.equation(numbering: "(1)")

    show raw.where(block: true): it => {
        set par(leading: 0.25em)
        block(inset: (left: 2em, right: 0.9em, top: 0.5em, bottom: 0.5em), it)
    }
    show raw.where(block: false): set text(font: cfg.fonts.mono)

    show quote.where(block: true): it => {
        block(inset: (left: 2em, right: 1em), {
            set text(size: cfg.sizes.normal * 1.25)
            set par(leading: 0.6em)
            it.body
            if it.attribution != none {
                linebreak()
                align(right)[#text(size: cfg.sizes.small, [— ] + it.attribution)]
            }
        })
    }

    // Hoist figure caption into the margin, aligned near the top of the
    // figure body (emit caption BEFORE body so marginalia anchors to the
    // figure's top line). `figure-dy-state` adds a per-call dy shift.
    //
    // Skip when inside marginalia.notefigure (margin-figure-pdf), which
    // owns its caption rendering — our rule would stomp it and the
    // caption would disappear.
    //
    // Caption font follows margin-note (matches tufte-LaTeX:
    // \@tufte@caption@font = \@tufte@marginfont). `it.caption` includes
    // the supplement + counter (e.g. "Figure 1: ...") so figure numbering
    // remains visible.
    show figure: it => context {
        if _in-margin-figure.get() { return it }
        let extra-dy = figure-dy-state.get()
        if it.caption != none {
            note(dy: extra-dy + 1em, counter: none, text-style: _caption-style(cfg))[#it.caption]
        }
        it.body
    }

    show footnote: it => sidenote-pdf(true, auto, it.body)

    show heading.where(level: 1): _heading-rule(cfg.headings.h1, lead-kern: -0.1em)
    show heading.where(level: 2): _heading-rule(cfg.headings.h2)
    show heading.where(level: 3): _heading-rule(cfg.headings.h3)

    _render-title-block(title, author, email, date, cfg)
    _render-abstract(abstract, cfg)
    _render-toc(toc)
    body
}
