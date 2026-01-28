// Dual-format Tufte Typst Template
// Single-file implementation for both PDF and HTML output
// Author: Jialin Lu <luxxxlucy@gmail.com>

// Import drafting package for PDF margin notes
#import "@preview/drafting:0.2.2": margin-note, set-page-properties, set-margin-note-defaults

// Target detection
#let is-html() = sys.inputs.at("target", default: "pdf") == "html"

// Typography & constants

// Font stacks with fallbacks (Tufte-style typography)
#let body-font = ("ET Book", "Palatino", "Georgia")
#let sans-font = ("Gill Sans", "Helvetica")
#let mono-font = ("Monaco", "Courier New")

// Font size scale
#let font-sizes = (
  tiny: 8pt,
  small: 9pt,
  normal: 11pt,
  large: 13pt,
  larger: 16pt,
)

// Layout constants
#let full-width-size = 100% + 2in  // 3in right margin - 1in gap

// State counters
#let sidenote-counter = counter("sidenote")

// Common styles (shared by both formats)

/// Tight paragraph formatting for sidenotes and captions
#let tight-par(content) = {
  set par(leading: 0.55em, spacing: 0.5em)
  content
}

/// Apply common typography and styles shared by both PDF and HTML
#let apply-common-styles(body) = {
  // Base font and size
  set text(font: body-font, size: font-sizes.normal)

  // Heading styles: all levels use italic, regular weight (Tufte style)
  show heading.where(level: 1): it => {
    set text(font: body-font, size: font-sizes.larger, style: "italic", weight: "regular")
    set block(above: 4em, below: 1.5em)
    it
  }

  show heading.where(level: 2): it => {
    set text(font: body-font, size: font-sizes.large, style: "italic", weight: "regular")
    set block(above: 2.1em, below: 1.4em)
    it
  }

  show heading.where(level: 3): it => {
    set text(font: body-font, size: font-sizes.normal, style: "italic", weight: "regular")
    set block(above: 2em, below: 1.4em)
    it
  }

  // Figure caption styling
  show figure.caption: set text(font: sans-font, size: font-sizes.small)
  show figure.caption: set align(left)

  body
}

// PDF-specific implementation

#let _sidenote-pdf(numbered, dy, body) = {
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

#let _margin-figure-pdf(content, caption, dy) = {
  text(size: font-sizes.tiny, margin-note({
    set text(font: sans-font, size: font-sizes.small)
    figure(content, caption: caption)
  }, dy: dy))
}

#let _full-width-figure-pdf(content, caption) = {
  block(width: full-width-size, figure(content, caption: caption))
}

#let _epigraph-pdf(quote, author) = {
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

#let _new-thought-pdf(body) = {
  h(-1em)
  smallcaps(body)
}

#let _full-width-pdf(body) = {
  block(width: full-width-size, body)
}

#let _sidecite-pdf(key, dy) = {
  sidenote-counter.step()
  context {
    let num = sidenote-counter.display()
    super(num)
    text(size: font-sizes.tiny, margin-note(
      tight-par([#super(num) #cite(key)]),
      dy: dy
    ))
  }
}

/// Render title block for PDF output
#let _render-title-block-pdf(title, author, date) = {
  if title != none {
    set align(center)
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

/// Render abstract for PDF output
#let _render-abstract-pdf(abstract) = {
  if abstract != none {
    set align(center)
    set par(first-line-indent: 0em)

    text(font: body-font, size: font-sizes.small, smallcaps[Abstract])

    v(0.5em)

    block(
      width: 80%,
      inset: (left: 10%, right: 10%),
      {
        set align(left)
        text(font: body-font, size: font-sizes.small, style: "italic", abstract)
      }
    )

    v(1.5em)
  }
}

/// Render table of contents for PDF output
#let _render-toc-pdf(toc) = {
  if toc == true {
    outline(title: [Contents], indent: auto, depth: 2)
    v(1.5em)
  }
}

/// PDF-specific setup and styling
#let setup-pdf(paper, title, author, date, abstract, toc, body) = {
  // Page setup
  set page(
    paper: paper,
    margin: (left: 1in, right: 3in, top: 1in, bottom: 1in),
  )

  // Configure drafting package for margin notes
  set-page-properties()
  set-margin-note-defaults(
    stroke: none,
    side: right,
    margin-right: 2in,
    margin-left: 1in,
  )

  // PDF-specific text styling
  set text(fill: luma(20%))
  set par(first-line-indent: 1em, leading: 1.4em)
  set super(size: 0.65em, baseline: -0.4em)

  // Link styling
  show link: set text(fill: blue)

  // List styling
  set list(indent: 1em, body-indent: 1em, spacing: 0.5em)

  // Code block styling
  show raw.where(block: true): it => {
    set block(above: 1em, below: 1em)
    set text(font: mono-font, size: 10pt)
    it
  }
  show raw.where(block: false): set text(font: mono-font)

  // Standard figures: caption in margin (Tufte style)
  show figure: it => {
    it.body
    if it.caption != none {
      text(size: font-sizes.small, margin-note(tight-par(it.caption), dy: -1.7em))
    }
  }

  // Convert footnotes to sidenotes
  show footnote: it => _sidenote-pdf(true, -1.7em, it.body)

  // Reset sidenote counter to ensure first sidenote is numbered 1
  sidenote-counter.update(0)

  // Render document structure
  _render-title-block-pdf(title, author, date)
  _render-abstract-pdf(abstract)
  _render-toc-pdf(toc)

  apply-common-styles(body)
}

// HTML-specific implementation

#let _sidenote-html(numbered, body) = {
  if numbered {
    sidenote-counter.step()
    context {
      let num = sidenote-counter.display()
      html.sup(num)
      html.span(class: "marginnote", [#super(num) #body])
    }
  } else {
    html.span(class: "marginnote", body)
  }
}

#let _margin-figure-html(content, caption) = {
  html.span(class: "marginnote", figure(content, caption: caption))
}

#let _full-width-figure-html(content, caption) = {
  html.figure(class: "fullwidth", {
    content
    if caption != none {
      html.figcaption(caption)
    }
  })
}

#let _epigraph-html(quote, author) = {
  html.div(class: "epigraph", {
    html.blockquote({
      html.p(quote)
      if author != none {
        html.footer(author)
      }
    })
  })
}

#let _new-thought-html(body) = {
  html.span(class: "newthought", body)
}

#let _full-width-html(body) = {
  html.div(class: "fullwidth", body)
}

#let _sidecite-html(key) = {
  sidenote-counter.step()
  context {
    let num = sidenote-counter.display()
    html.sup(num)
    html.span(class: "marginnote", [#super(num) #cite(key)])
  }
}

/// Render title block for HTML output
#let _render-title-block-html(title, author, date) = {
  if title != none {
    html.h1(class: "title", title)
  }

  if author != none {
    html.p(class: "author", author)
  }

  if date != none {
    html.p(class: "date", date.display())
  }
}

/// Render abstract for HTML output
#let _render-abstract-html(abstract) = {
  if abstract != none {
    html.section(class: "abstract", {
      html.h2[Abstract]
      html.p(abstract)
    })
  }
}

/// Render table of contents for HTML output
#let _render-toc-html(toc) = {
  if toc == true {
    html.nav(class: "toc", {
      html.h2[Contents]
      html.p[The table of contents will display section headings from this document.]
    })
  }
}

/// HTML-specific setup and styling
#let setup-html(title, author, date, abstract, toc, lang, body) = {
  let doc-title = if title != none { title } else { "Document" }

  let html-css = (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
  )

  // Apply HTML-specific overrides
  let styled-body = {
    set text(fill: rgb("#111"))
    set par(spacing: 1.4em)

    show link: set text(fill: rgb("#111"))
    show list: set block(width: 50%)

    // Standard figures: caption in margin
    show figure.caption: it => html.span(
      class: "marginnote",
      it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body,
    )

    show figure: it => {
      html.figure({
        it.caption
        it.body
      })
    }

    // Convert footnotes to sidenotes
    show footnote: it => _sidenote-html(true, it.body)

    // Reset sidenote counter to ensure first sidenote is numbered 1
    sidenote-counter.update(0)

    // Render document structure
    _render-title-block-html(title, author, date)
    _render-abstract-html(abstract)
    _render-toc-html(toc)

    apply-common-styles(body)
  }

  html.html(
    lang: lang,
    {
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        html.title(doc-title)
        for (css-link) in html-css {
          html.link(rel: "stylesheet", href: css-link)
        }
      })

      html.body({
        html.article(
          html.section(styled-body),
        )
      })
    },
  )
}

// Public API (dispatches to format-specific implementations)

/// Sidenote - numbered or unnumbered margin note
#let sidenote(numbered: true, dy: -1.7em, body) = context {
  if is-html() {
    _sidenote-html(numbered, body)
  } else {
    _sidenote-pdf(numbered, dy, body)
  }
}

/// Margin note - unnumbered sidenote
#let marginnote(dy: -1.7em, body) = sidenote(numbered: false, dy: dy, body)

/// Margin figure - figure placed entirely in margin
#let margin-figure(content, caption: none, dy: -1.7em) = context {
  if is-html() {
    _margin-figure-html(content, caption)
  } else {
    _margin-figure-pdf(content, caption, dy)
  }
}

/// Full-width figure - spans text area and margin
#let full-width-figure(content, caption: none) = context {
  if is-html() {
    _full-width-figure-html(content, caption)
  } else {
    _full-width-figure-pdf(content, caption)
  }
}

/// Epigraph - a blockquote with optional attribution
#let epigraph(quote, author: none) = context {
  if is-html() {
    _epigraph-html(quote, author)
  } else {
    _epigraph-pdf(quote, author)
  }
}

/// New thought - small caps section opener
#let new-thought(body) = context {
  if is-html() {
    _new-thought-html(body)
  } else {
    _new-thought-pdf(body)
  }
}

/// Full-width block
#let full-width(body) = context {
  if is-html() {
    _full-width-html(body)
  } else {
    _full-width-pdf(body)
  }
}

/// Margin citation
#let sidecite(key, dy: -1.7em) = context {
  if is-html() {
    _sidecite-html(key)
  } else {
    _sidecite-pdf(key, dy)
  }
}

// Main template

/// Main Tufte template - auto-detects PDF/HTML format
#let tufte(
  title: none,
  author: none,
  date: none,
  abstract: none,
  lang: "en",
  toc: false,
  paper: "us-letter",
  bib: none,
  body
) = {
  set text(lang: lang)

  if is-html() {
    setup-html(title, author, date, abstract, toc, lang, body)
  } else {
    setup-pdf(paper, title, author, date, abstract, toc, body)
  }

  // Add bibliography at the end if provided
  if bib != none {
    bib
  }
}
