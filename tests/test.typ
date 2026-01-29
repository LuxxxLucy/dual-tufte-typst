// Comprehensive example using the Dual-Format Tufte Typst Template
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

#import "../src/lib.typ": tufte, sidenote, marginnote, main-figure, margin-figure, full-width-figure, epigraph, new-thought, full-width, sidecite

#show: tufte.with(
  title: [Tufte Typst],
  author: "Jialin Lu",
  date: datetime.today(),
  abstract: [This document demonstrates the dual-format Tufte template for Typst, which produces elegant documents in both PDF and HTML formats following Edward Tufte's design principles. The template emphasizes readable typography, generous use of sidenotes, and careful integration of text and graphics.],
  toc: true,
)

#pagebreak()

= Introduction

#new-thought[This document demonstrates] the dual-format Tufte Typst template, a single-source solution for creating elegant documents in both PDF and HTML formats.#sidenote[The template automatically detects the output format and applies appropriate styling. Compile with `typst compile` for PDF or add `--format html` for HTML output.] The template follows the design principles established by Edward Tufte in his influential books on information visualization.#sidecite(<tufte2001>)

The Tufte style is characterized by:

- Wide right margins for sidenotes, citations, and small figures
- Numbered sidenotes instead of footnotes
- Elegant serif typography optimized for readability
- Careful integration of graphics with text
- Full-width figures for data-dense visualizations

This implementation provides a unified API that works seamlessly across both output formats, eliminating the need to maintain separate document sources.

== Getting Started

To use this template, import the library and apply the `tufte` show rule:

```typst
#import "@local/dual-typst:0.1.0": tufte, sidenote, main-figure,
  margin-figure, full-width-figure

#show: tufte.with(
  title: [Your Title],
  author: "Your Name",
  date: datetime.today(),
)

Your content here with #sidenote[margin notes].
```

The template automatically handles format detection and styling based on compilation options. All functions work identically in both PDF and HTML outputs.

= Fundamentals

== Sections and Headings

The template supports three levels of headings, all styled in italic following Tufte's typographic principles.#sidenote[Tufte uses italic headings rather than bold, creating a more refined appearance that distinguishes section breaks without overwhelming the text.] Each level has appropriate sizing and spacing.

=== Third-Level Heading

Third-level headings use the same base font size as body text but remain italic to maintain visual hierarchy. They work well for detailed subsections.

#new-thought[New thoughts] mark the beginning of a new idea without requiring a formal heading. The opening words appear in small capitals, creating a subtle visual break that signals a conceptual shift while maintaining narrative flow.

== Typography and Text

The template employs ET Book#sidenote[ET Book is a digital revival of the Monotype Bembo typeface, carefully optimized for screen display while maintaining the elegance of classic book typography.] for body text with Palatino and Georgia as fallbacks. Sans-serif elements use Gill Sans with Helvetica as fallback, while code uses Monaco or Courier New.

Text can include _italic emphasis_, *bold text*, and `inline code`. Links are styled appropriately: #link("https://typst.app")[Typst homepage]. Mathematical notation works seamlessly: $E = m c^2$ for inline math, and display equations like:

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $

Regular Typst footnotes#footnote[Like this footnote!] are automatically converted to numbered sidenotes, maintaining the Tufte aesthetic across both formats.

= Sidenotes: A Defining Feature

#new-thought[Sidenotes are perhaps] the most distinctive element of Tufte's design.#sidecite(<tufte2001>) They place supplementary information, citations, and commentary in the wide margin rather than at the page bottom or document end. This keeps related information close to the relevant text, making it easy to glance at a note without losing your place.

The template provides several margin elements:

- *Numbered sidenotes*#sidenote[Created with the `sidenote` function. Numbers increment automatically.] for references and supplementary information
- *Margin notes*#marginnote[Created with `marginnote`. These have no numbers and work well for brief asides.] for informal annotations
- *Margin citations*#sidecite(<tufte2006>) that combine reference numbers with bibliographic information
- *Margin figures* for small supporting graphics

Multiple sidenotes on the same line are handled gracefully,#sidenote[First note.] with appropriate spacing#sidenote[Second note.] maintained in both formats.

= Epigraphs

Epigraphs provide thematic quotations at section openings. They use italic text with proper attribution:

#epigraph(
  [The purpose of visualization is insight, not pictures.],
  author: [Ben Shneiderman],
)

Epigraphs can appear anywhere in the document, though they're most effective at the beginning of major sections. They add contextual depth without interrupting the main narrative.

#epigraph(
  [Clutter and confusion are not attributes of data—they are shortcomings of design.],
  author: [Edward Tufte],
)

= Figures and Images

Tufte-style layouts offer three distinct ways to present visual information, each optimized for different content types. All figures automatically receive "Figure X:" numbering and proper positioning in both PDF and HTML outputs.

== Margin Figures

For smaller supplementary visuals that don't require primary focus, margin figures place both image and caption entirely in the margin. Use `margin-figure` for this layout:

#margin-figure(
  image("../assets/images/rhino.png", width: 100%),
  caption: [Albrecht Dürer's 1515 woodcut of a rhinoceros, based on a written description and sketch. The image became iconic despite its anatomical inaccuracies.],
)

This keeps the main text flowing uninterrupted while providing visual context. Margin figures work well for icons, small charts, portraits, or supporting graphics that enhance but don't require immediate attention.

The text continues naturally alongside the margin figure, with the image serving as a visual anchor for the related discussion. This layout maximizes information density while maintaining readability.

== Standard Figures

Standard figures keep the image in the text column while placing the caption in the margin.#sidenote[This is the most common figure layout, balancing visual prominence with efficient use of space. The caption's placement in the margin keeps the text column clean.] Use `main-figure` for this layout.

#main-figure(
  image("../assets/images/exports-imports.png", width: 100%),
  caption: [Exports and imports to and from Denmark & Norway from 1700 to 1780, visualized by William Playfair. This early statistical graphic demonstrates the power of visual representation for understanding complex temporal patterns in trade data.],
)

Playfair's 18th-century chart remains remarkably effective, using area to encode quantity over time. The visual form makes patterns immediately apparent that would require extensive analysis in tabular form.

== Full-Width Figures

When a visualization requires substantial horizontal space—for timelines, wide tables, or detailed diagrams—full-width figures span both the text column and margin. Use `full-width-figure` for this layout:

#full-width-figure(
  image("../assets/images/napoleons-march.png", width: 100%),
  caption: [Charles Joseph Minard's 1869 visualization of Napoleon's disastrous 1812 Russian campaign. The graphic simultaneously depicts six types of information: geography, troop movements, troop strength, temperature, dates, and direction of travel. Edward Tufte called this "probably the best statistical graphic ever drawn." @tufte1983],
)

Minard's masterpiece demonstrates how a single well-designed visualization can convey complex multivariate information more effectively than pages of text. The declining width of the army's path immediately communicates the catastrophic human cost of the campaign.

= Code Examples

The template handles code blocks with appropriate monospace typography and spacing:

```python
def fibonacci(n):
    """Calculate the nth Fibonacci number.

    Demonstrates clean code formatting in the
    Tufte template with proper indentation.
    """
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# The Tufte style keeps code readable
result = fibonacci(10)
print(f"Result: {result}")
```

Inline code like `tufte.with()` uses monospace font and works naturally within sentences. Code blocks receive appropriate spacing and maintain readability across both PDF and HTML outputs.

= Full-Width Content

Sometimes content needs more horizontal space than the standard text column provides. Full-width blocks extend across the entire page:

#full-width[
  This full-width content spans both the text area and margin, providing maximum horizontal space for tables, extended quotations, or any material that benefits from a wider format. The layout creates a visual break from the standard column width while maintaining the document's overall aesthetic. This approach works particularly well for comparison tables, wide mathematical derivations, or detailed technical specifications that would be cramped in the standard column width.
]

After full-width content, the text returns to the standard column width, which research has shown to be optimal for reading comfort.#sidenote[Studies suggest that line lengths between 50-75 characters provide the best reading experience, reducing eye strain and improving comprehension. The Tufte design uses this principle with its narrow text column.]

= Lists and Block Quotes

Unordered lists provide clear presentation of related items:

- Typography emphasizes readability over decoration
- Generous margins accommodate supplementary information
- Graphics integrate seamlessly with text
- Design principles remain consistent across formats

Ordered lists work similarly for sequential information:

1. Import the template library
2. Apply the tufte show rule with desired options
3. Write content using standard Typst syntax
4. Compile to PDF or HTML as needed

Block quotations receive appropriate formatting:

#quote(block: true, attribution: [Edward Tufte])[
  Above all else show the data. Reveal the data at several levels of detail, from a broad overview to the fine structure.
]

= Conclusion

This template demonstrates that thoughtful design principles can translate effectively across multiple output formats. By separating content from presentation and using format-specific implementations behind a unified API, we achieve consistency without sacrificing the strengths of each medium.

The dual-format approach offers practical benefits: maintain a single source document, generate print-ready PDFs and web-accessible HTML from the same content, and ensure consistent styling across both formats. Whether producing academic papers, technical documentation, or data-rich reports, the Tufte style emphasizes what matters most: clear communication through careful integration of text and graphics.#sidenote[The complete source code for this template is available on GitHub, including examples and documentation for all features.]

#bibliography("../refs.bib", style: "chicago-author-date")
