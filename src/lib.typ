// ============================================================================
// Dual-format Tufte Typst Template
// Single-file implementation for both PDF and HTML output
//
// Author: Jialin Lu <luxxxlucy@gmail.com>
// ============================================================================
//
// Description:
//   A Typst template that exports to both PDF and HTML formats with
//   Tufte-style typography and margin notes. Inspired by Edward Tufte's
//   design principles for presenting information.
//
// File Structure:
//   1. Imports & Dependencies
//   2. Target Detection (PDF vs HTML)
//   3. Typography Constants (fonts, sizes)
//   4. State Management (counters)
//   5. Margin Notes (sidenote, marginnote)
//   6. Shared Setup (common styles for both formats)
//   7. PDF Setup (PDF-specific configuration)
//   8. HTML Setup (HTML-specific configuration)
//   9. Main Template (tufte function)
//
// References:
//   Tufte LaTeX:  https://github.com/Tufte-LaTeX/tufte-latex
//   Tufte CSS:    https://github.com/edwardtufte/tufte-css
//   
//   Tufte using Typst (PDF):
//     - tufte-memo:    https://github.com/nogula/tufte-memo
//     - tufte-typst:   https://github.com/fredguth/tufte-typst
//     - toffee-tufte:  https://codeberg.org/jianweicheong/toffee-tufte
//     - bookly:        https://github.com/maucejo/bookly
//
//   Tufte using Typst (HTML):
//     - tufted:        https://github.com/vsheg/tufted
//     - tufted-blog:   https://github.com/Yousa-Mirage/Tufted-Blog-Template
//
// ============================================================================

// Import drafting package for PDF margin notes
#import "@preview/drafting:0.2.2": margin-note, set-page-properties, set-margin-note-defaults

// ============================================================================
// TARGET DETECTION
// ============================================================================

#let is-html() = {
  sys.inputs.at("target", default: "pdf") == "html"
}

#let is-pdf() = not is-html()

// ============================================================================
// TYPOGRAPHY
// ============================================================================

// Font stacks with fallbacks (Tufte-style typography)
#let body-font = ("ET Book", "Palatino", "Georgia")    // Serif for body text
#let sans-font = ("Gill Sans", "Helvetica")             // Sans-serif for captions, notes
#let mono-font = ("Monaco", "Courier New")              // Monospace for code

// Font size scale
#let font-sizes = (
  tiny: 8pt,      // Sidenotes, footnotes
  small: 9pt,     // Small text, captions
  normal: 11pt,   // Body text and H3 (though we should not really expect H3 as recommended by Tufte)
  large: 13pt,    // H2 headings
  larger: 16pt,   // H1 headings
)

// ============================================================================
// STATE
// ============================================================================

#let sidenote-counter = counter("sidenote")
#let margin-figure-counter = counter("margin-figure")  // Reserved for Phase 4 (figures)

// ============================================================================
// MARGIN NOTES
// ============================================================================

// Sidenote paragraph formatting (tight line spacing per Tufte LaTeX)
#let sidenote-par-settings(content) = {
  set par(leading: 0.55em, spacing: 0.5em)
  content
}

// Helper: Render numbered sidenote for HTML
#let render-html-sidenote(num, body) = {
  html.sup(num)
  html.span(class: "marginnote", {
    html.sup(num)
    [ ]
    body
  })
}

// Helper: Render numbered sidenote for PDF
#let render-pdf-sidenote(num, body, dy) = {
  super(num)
  text(size: font-sizes.tiny, margin-note(
    sidenote-par-settings({
      super(num)
      [ ]
      body
    }),
    dy: dy,
  ))
}

/// Sidenote - a numbered or unnumbered note in the margin
///
/// Parameters:
/// - numbered: Whether to display a number (default: true)
/// - dy: Vertical offset to align note with text (default: -1.7em)
///       Negative value aligns note upward with the superscript reference
/// - body: The content of the sidenote
#let sidenote(numbered: true, dy: -1.7em, body) = context {
  if is-html() {
    // HTML rendering
    if numbered {
      sidenote-counter.step()
      render-html-sidenote(sidenote-counter.display(), body)
    } else {
      html.span(class: "marginnote", body)
    }
  } else {
    // PDF rendering using drafting package
    // Note: wrap margin-note() in text() to prevent newline after superscript
    if numbered {
      sidenote-counter.step()
      render-pdf-sidenote(sidenote-counter.display(), body, dy)
    } else {
      text(size: font-sizes.tiny, margin-note(sidenote-par-settings(body), dy: dy))
    }
  }
}

/// Margin note - an unnumbered note in the margin
#let marginnote(dy: -1.7em, body) = sidenote(numbered: false, dy: dy, body)

// ============================================================================
// SHARED SETUP
// ============================================================================

/// Apply common typography and styles shared by both PDF and HTML
/// This sets base font, size, heading styles, and footnote conversion
#let apply-common-styles(body) = {
  // Base font and size (color/fill is format-specific)
  set text(
    font: body-font,
    size: font-sizes.normal,
  )
  
  
  // Heading styles: H1 regular, H2/H3 italic
  show heading.where(level: 1): it => {
    set text(font: body-font, size: font-sizes.larger, style: "italic" ,weight: "regular")
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
  
  // Convert footnotes to sidenotes
  show footnote: it => sidenote(numbered: true, it.body)
  
  body
}

// ============================================================================
// PDF SETUP
// ============================================================================

/// PDF-specific setup and styling
#let setup-pdf(paper, body) = {
  // Page setup
  set page(
    paper: paper,
    margin: (
      left: 1in,
      right: 3in,
      top: 1in,
      bottom: 1in,
    ),
  )

  // Configure drafting package for margin notes
  set-page-properties()
  set-margin-note-defaults(
    stroke: none,
    side: right,
    margin-right: 2in,  // Width of margin area for notes
    margin-left: 1in,   // Distance from text edge to note start
  )

  // PDF-specific text color
  set text(fill: luma(20%))

  // PDF-specific paragraph formatting
  set par(
    first-line-indent: 1em,
    leading: 1.4em,
  )
  
  // Superscript styling for sidenote numbers
  set super(
    size: 0.65em,
    baseline: -0.4em,
  )

  // Link styling
  show link: set text(fill: blue)
  
  // List styling
  set list(
    indent: 1em,
    body-indent: 1em,
    spacing: 0.5em,
  )
  
  // Code block styling
  show raw.where(block: true): it => {
    set block(above: 1em, below: 1em)
    set text(font: mono-font, size: 10pt)
    it
  }
  
  show raw.where(block: false): set text(font: mono-font)

  apply-common-styles(body)
}

// ============================================================================
// HTML SETUP
// ============================================================================

/// HTML-specific setup and styling
#let setup-html(title, lang, body) = {
  let doc-title = if title != none { title } else { "Document" }

  let html-css = (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
  )
  let html-js = ()

  // Apply common styles first, then HTML-specific overrides
  let styled-body = {
    // HTML-specific text color
    set text(fill: rgb("#111"))

    // HTML-specific paragraph spacing
    set par(spacing: 1.4em)
    
    // HTML-specific text elements
    show link: set text(fill: rgb("#111"))
    show list: set block(width: 50%)
    
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

        for (js-link) in html-js {
          html.script(src: js-link)
        }
      })
    },
  )
}

// ============================================================================
// MAIN TEMPLATE
// ============================================================================

/// Main Tufte template function
/// Automatically detects output format and applies appropriate styling
///
/// Parameters:
/// - title: Document title
/// - author: Author name(s) (string or array)
/// - date: Document date (datetime)
/// - abstract: Abstract content
/// - lang: Document language (default: "en")
/// - toc: Show table of contents (default: false)
/// - paper: Paper size for PDF (default: "us-letter")
/// - bib: Bibliography
/// - body: Document content
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
    setup-html(title, lang, body)
  } else {
    setup-pdf(paper, body)
  }
}
