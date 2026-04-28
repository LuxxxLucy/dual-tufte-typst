// Dual-Tufte-Typst
//
// A dual-format template for Tufte's design principles.
// Compile this file to PDF or HTML—same source, both outputs.

#import "../src/lib.typ": tufte, sidenote, marginnote, main-figure, margin-figure, full-width-figure, epigraph, new-thought, full-width, sidecite

// `--input style=<name>` selects a registered style (jialin,
// tufte-original, envision, terpret, orange-happy, bluewhite). The
// gallery uses this to render the same document under every style.
#show: tufte.with(
  title: [Dual-Tufte-Typst: Tufte Style for Both PDF and HTML],
  author: "Jialin Lu",
  date: [2026-01-28 (last updated: #datetime.today().display())],
  style: sys.inputs.at("style", default: "jialin"),
)

A Typst template produces Tufte handout in both PDF and HTML from a single source.#sidenote[PDF uses the `marginalia` package for margin notes; HTML generates Tufte CSS markup. Same API, both outputs.] Tufte's style is known for simplicity, sidenotes over footnotes, and tight integration of graphics with text.

If you see improvements, contributions are welcome on the GitHub project: #link("https://github.com/LuxxxLucy/dual-tufte-typst")[dual-tufte-typst].

#epigraph(
  [The web is not print. Webpages are not books. Therefore, the goal is not "websites should look like Tufte's books" but "here are techniques Tufte developed that we've found useful in print; maybe you can make them useful on the web."],
  author: [Dave Liepmann, Tufte CSS],
)

= Getting Started

Copy `src/` to your project and add to your document:

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(
  title: [Your Title],
  author: "Your Name",
)

Content with #sidenote[margin notes].
```

The `tufte.with()` function accepts additional parameters:

```typst
#show: tufte.with(
  title: [Document Title],
  author: "Author Name",
  email: "you@example.com",
  date: datetime.today(),
  abstract: [Brief document summary...],
  toc: true,
  lang: "en",
  bib: bibliography("refs.bib"),             // runs after body
  config: (page: (paper: "us-letter")),
)
```

Pick a style by name, or pass `--input style=<name>` at the command line:

```typst
#show: tufte.with(title: [...], style: "envision")
```

```bash
typst compile --input style=envision --input target=html --features html doc.typ out.html
```

Registered styles: `tufte-original`, `envision`, `jialin`, `terpret`, `orange-happy`, `bluewhite`. Each style record can also carry a `css:` field listing one or more stylesheet URLs that the HTML target injects (`envision` loads tufte.min.css plus rstudio's envisioned overlay this way). Override the active style's CSS for a single document with the `html-css:` parameter:

```typst
#show: tufte.with(
  title: [...],
  style: "tufte-original",
  html-css: ("https://my-cdn.example/custom-tufte.css",),
)
```

Compile with:

```bash
typst compile document.typ                                          # PDF
typst compile --input target=html --features html document.typ out.html  # HTML
```

View source alongside output to learn the features.

= Fundamentals

== Sections and Headings

Organize your document with titles and headings. The document title is set via `tufte.with(title: ...)`. Use `=` for sections and `==` for subsections. Third-level headings (`===`) exist but are discouraged in the Tufte philosophy.#sidenote[Tufte: "The Feynman lectures write about all of physics in 1800 pages using only 2 levels of headings. Undergraduate Caltech physics is complicated material, but it didn't require elaborate hierarchy."]

#new-thought[In his later books], Tufte starts sections with vertical space, a non-indented paragraph, and the first few words in small caps. Use `new-thought` for this. Be consistent: don't alternate headers and `new-thought`. Pick one.

== Text

Body text uses ET Book (or Palatino/Georgia fallback), with slightly muted colors for reduced contrast.#sidenote[PDF: `fill: luma(20%)`. HTML: `#111` on `#fffff8` background.] Links appear as #link("#")[underlined text], matching body color rather than distracting blue.

Standard formatting: _emphasis_, *strong*, `code`. Math is covered in its own section below.

= Sidenotes

#new-thought[Sidenotes are the signature] Tufte element.#sidenote[This is a sidenote.] They display in the margin rather than forcing readers to the page bottom. On small screens (HTML), they collapse to toggleable content.

Sidenotes have two parts: a superscript reference number inline, and the note content in the margin. The template handles both automatically.

If you want a sidenote without numbering, use a margin note.#marginnote[This is a margin note. No number precedes it.] On large screens, margin notes are sidenotes without reference numbers. On small screens, they toggle with ⊕ instead of a number.

Regular Typst footnotes convert to sidenotes automatically.#footnote[Like this one!]

For citations, use `sidecite()` to place the reference in the margin alongside the text.#sidecite(<tufte2001>) This keeps the text flowing while providing immediate access to sources without jumping to a bibliography.

= Figures

Tufte emphasizes tight integration of graphics with text—figures stay with the discussion, not relegated to separate pages.

== Standard Figures

Most figures sit in the text column with captions in the margin using `main-figure`:

#main-figure(
  image("../assets/images/exports-imports.png", width: 100%),
  caption: [Exports and imports to and from Denmark & Norway from 1700 to 1780. From Tufte's _Visual Display of Quantitative Information_, page 92.],
)

== Margin Figures

#margin-figure(
  image("../assets/images/rhino.png", width: 100%),
  caption: [Dürer's 1515 rhinoceros woodcut, from Tufte's _Visual Explanations_.],
)

Smaller graphics fit entirely in the margin. Text flows uninterrupted while the figure provides visual context. Works well for portraits, icons, or supporting details.

== Full-Width Figures

Data-dense visualizations may require the full page width:

#full-width-figure(
  image("../assets/images/napoleons-march.png", width: 100%),
  caption: [Minard's 1869 map of Napoleon's Russian campaign. Tufte called it "probably the best statistical graphic ever drawn."],
)

= Epigraphs

Epigraphs introduce sections with thematic quotations:

#epigraph(
  [The English language becomes ugly and inaccurate because our thoughts are foolish, but the slovenliness of our language makes it easier for us to have foolish thoughts.],
  author: [George Orwell, "Politics and the English Language"],
)

#epigraph(
  [For a successful technology, reality must take precedence over public relations, for Nature cannot be fooled.],
  author: [Richard P. Feynman],
)

= Mathematics

Inline math sits in running text, e.g. $E = m c^2$, $alpha + beta = gamma$, or a triangle-inequality bound $norm(u + v) <= norm(u) + norm(v)$. Greek and common symbols use Typst names: $alpha, beta, gamma, pi, infinity, partial, nabla, plus.minus, tilde.equiv$.

Display math centers on its own line and auto-numbers#sidenote[Numbering set in `setup-html` / `setup-pdf` via `set math.equation(numbering: "(1)")`. Override locally with another `set math.equation(...)` rule.]:

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $

Aligned multi-line derivations use `&` to mark the alignment column:

$ (a + b)^2 &= (a + b)(a + b) \
            &= a^2 + 2 a b + b^2 $

Sums and products with bounds:

$ sum_(k=1)^n k = n(n+1)/2, quad product_(k=1)^n k = n! $

Fractions, roots, and matrices:

$ phi = (1 + sqrt(5)) / 2, quad
  A = mat(
    cos theta, -sin theta;
    sin theta,  cos theta
  ) $

Cases and piecewise definitions:

$ abs(x) = cases(
    x   & "if " x >= 0,
    -x  & "if " x < 0,
  ) $

In HTML output every equation renders as inline SVG via `html.frame` (`typst/typst#5512`); SVG glyphs use `currentColor` to follow the surrounding text colour but carry no MathML accessibility data and are not selectable as text.

= Code

Code blocks use monospace typography:

```clojure
;; Applying a function to every item
(map tufte-css blog-posts)

;; Side-effecty loop, formatted for readability
(doseq [[[a b] [c d]] (map list
                           (sorted-map :1 1 :2 2)
                           (sorted-map :3 3 :4 4))]
  (prn (* b d)))
```

Inline code like `tufte.with()` integrates naturally with prose.

= Lists and Block Quotes

Lists work as expected in Typst:

Unordered lists for non-sequential items:
- First item shows basic usage
- Second item demonstrates continuation#sidenote[Even sidenotes work within lists.]
- Third item completes the example

Ordered lists for sequential steps:
+ Compile your document to PDF
+ Compile the same source to HTML
+ Compare the outputs side-by-side

Block quotes set off extended quotations with appropriate attribution:

#quote(block: true, attribution: [Edward Tufte])[
  Above all else show the data.
]

#quote(block: true, attribution: [Edward Tufte, _Visual Display of Quantitative Information_])[
  Graphical excellence is that which gives to the viewer the greatest number of ideas in the shortest time with the least ink in the smallest space.
]

= Full-Width Content

#full-width[
Content sometimes needs more horizontal space. Full-width blocks extend across text column and margin. Research suggests 50–75 characters per line optimizes reading comfort—but tables or specifications sometimes benefit from extra width. Use sparingly.
]

= Dual-Format Notes

The template detects output format at compile time via `sys.inputs.target`. Each function dispatches to format-specific implementations:

- *PDF*: Uses `marginalia` package for margin notes and wide blocks
- *HTML*: Generates Tufte CSS-compatible markup with proper classes

The unified API means you write once:

```typst
#sidenote[Works identically in PDF and HTML.]
#margin-figure(image("fig.png"), caption: [Caption text.])
#full-width[Extended content here.]
```

= Conclusion

Many thanks to Edward Tufte for leading the way with his work. This project builds on Tufte-LaTeX, Tufte CSS, and various Typst implementations by the community.#sidenote[See `src/lib.typ` header for full references.]

The source of this document demonstrates every feature. View it alongside the rendered output—in both PDF and HTML—to see how each element translates across formats.

#bibliography("../refs.bib", style: "chicago-author-date")
