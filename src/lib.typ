// ============================================================================
// Dual-format Tufte Typst Template
// Single-file implementation for both PDF and HTML output
// ============================================================================
//
// Author: Jialin Lu <luxxxlucy@gmail.com>
//
// Description:
//   A Typst template that exports to both PDF and HTML formats with
//   Tufte-style typography and margin notes. Inspired by Edward Tufte's
//   design principles for presenting information.
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
//
// ============================================================================

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

#let body-font = ("ET Book", "Palatino", "Georgia", "serif")
#let sans-font = ("Gill Sans", "TeX Gyre Heros", "Helvetica", "sans-serif")
#let mono-font = ("Consolas", "Monaco", "monospace")

#let font-sizes = (
  tiny: 8pt,      // Footnotes, sidenotes
  small: 9pt,     // Small text, captions
  normal: 11pt,   // Body text
  large: 13pt,    // H2
  larger: 14pt,   // H1
  huge: 18pt,     // Display text
)

// ============================================================================
// STATE
// ============================================================================

#let sidenote-counter = counter("sidenote")
#let margin-figure-counter = counter("margin-figure")

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

  // PDF base typography
  set text(
    font: body-font,
    size: font-sizes.normal,
    fill: luma(20%),  // Near-black, not pure black
  )

  // PDF paragraph formatting: indent, ragged right
  set par(
    first-line-indent: 1em,  // 11pt for 11pt body
    leading: 1.4em,  // 1.4x leading (15.4pt for 11pt text)
    justify: false,  // Ragged right
  )

  // PDF heading styles
  show heading.where(level: 1): it => {
    set text(size: font-sizes.larger, weight: "regular")
    set block(above: 4em, below: 1.5em)
    it
  }

  show heading.where(level: 2): it => {
    set text(size: font-sizes.large, style: "italic", weight: "regular")
    set block(above: 2.1em, below: 1.4em)
    it
  }

  show heading.where(level: 3): it => {
    set text(size: font-sizes.normal, style: "italic", weight: "regular")
    set block(above: 2em, below: 1.4em)
    it
  }

  // PDF text elements
  show link: set text(fill: blue)  // Colored links in PDF
  
  // PDF list styling: proper spacing, indentation, ragged right
  // According to typography_concerns.md: indent 1em, body-indent 1em, justify false
  // Applies to both unordered (-) and ordered (1., 2., etc.) lists
  set list(
    indent: 1em,      // 11pt indent for list items (Tufte LaTeX: 1pc = 12pt)
    body-indent: 1em, // 11pt indent for list body
    spacing: 0.5em,   // Item spacing (normal paragraph spacing)
  )
  
  // PDF code block styling: proper spacing, font, size
  // According to typography_concerns.md: 10pt (slightly smaller), monospace font
  show raw.where(block: true): it => {
    set block(above: 1em, below: 1em)  // Space above and below code blocks
    set text(font: mono-font, size: 10pt)  // Slightly smaller than body (11pt)
    it
  }
  
  // PDF inline code styling: monospace font, same size as body
  show raw.where(block: false): set text(font: mono-font)

  body
}

// ============================================================================
// HTML SETUP
// ============================================================================

/// HTML-specific setup and styling (following tufted pattern)
#let setup-html(title, lang, body) = {
  let doc-title = if title != none { title } else { "Document" }

  // HTML-specific: CSS and JS (hidden behind target detection)
  let html-css = (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
  )
  let html-js = ()

  // HTML base typography
  set text(
    font: body-font,
    size: font-sizes.normal,
    fill: rgb("#111"),  // Near-black, not pure black
  )

  // HTML paragraph formatting: spacing, no indent
  set par(
    spacing: 1.4em,  // Relative to font size
    justify: false,  // Ragged right
  )

  // HTML heading styles
  show heading.where(level: 1): it => {
    set text(size: font-sizes.larger, weight: "regular")
    set block(above: 4em, below: 1.5em)
    it
  }

  show heading.where(level: 2): it => {
    set text(size: font-sizes.large, style: "italic", weight: "regular")
    set block(above: 2.1em, below: 1.4em)
    it
  }

  show heading.where(level: 3): it => {
    set text(size: font-sizes.normal, style: "italic", weight: "regular")
    set block(above: 2em, below: 1.4em)
    it
  }

  // HTML text elements
  show link: set text(fill: rgb("#111"))  // Inherit text color
  show list: set block(width: 50%)  // Narrower than paragraphs

  // Build HTML structure following tufted pattern
  html.html(
    lang: lang,
    {
      // Head
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        html.title(doc-title)

        // Stylesheets (HTML-specific, hidden behind target detection)
        for (css-link) in html-css {
          html.link(rel: "stylesheet", href: css-link)
        }
      })

      // Body
      html.body({
        // Main content
        html.article(
          html.section(body),
        )

        // JavaScript files (HTML-specific, hidden behind target detection)
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
