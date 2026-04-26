// tufte-original — Tufte-LaTeX `tufte-handout` ported to Typst.
//
// Authoritative source: .refs/style-research/tufte-common.def +
// tufte-handout.cls. The handout class loads `article` at 10pt and
// overrides every typographic dimension via `\@startsection`,
// `\setlength`, and the `\@tufte@*` commands. All numbers below are
// quoted from those files (line numbers in comments).
//
// This style is the pivot. Other PDF styles in this directory derive
// from it via `merge-config(tufte-original, <delta>)` so the layout
// invariants (geometry, leading, heading shape) stay coherent across
// the whole gallery and only intentional differences (body font,
// accent color) drift.

#let tufte-original = (
    name: "tufte-original",
    page: (
        // tufte-common.def:446
        //   left=1in, top=1in, textwidth=26pc, marginparsep=2pc,
        //   marginparwidth=12pc.  26pc=4.333in, 2pc=0.333in, 12pc=2in.
        paper: "us-letter",
        margin-x: 1in,
        margin-y: 1in,
        // Off-white book paper, matches tufte-css `body` background.
        fill: rgb("#fffff8"),
    ),
    margin-col: (
        width: 2in,
        sep: 0.333in,
    ),
    fonts: (
        // Tufte body face. The bundled `et-book` `.ttf`s register under
        // family `ETBembo` (per their `name` table), so listing "ETBook"
        // first would always miss; we go straight to ETBembo, then
        // Palatino on macOS / Georgia on Windows.
        body:   ("ETBembo", "Palatino", "Georgia"),
        sans:   ("Gill Sans", "Helvetica"),
        mono:   ("Menlo", "Monaco", "Courier"),
        header: ("ETBembo", "Palatino"),
    ),
    sizes: (
        // \normalsize = 10pt / 14pt leading (tufte-common.def:367-374)
        body: 10pt,
        // \footnotesize = 8pt / 10pt (tufte-common.def:388-389)
        tiny: 0.8em,
        small: 0.8em,
        normal: 1em,
        // \large = 11pt/15pt; \Large = 12pt/16pt (lines 401-402)
        large: 1.2em,    // h2 (\subsection)
        larger: 1.4em,   // h1 (\section); \LARGE = 14pt/18pt
        huge: 1.4em,     // title block (\LARGE)
        header: 8pt,
    ),
    headings: (
        // tufte-common.def:1622-1647. \section is `\Large\itshape` (12pt
        // italic), \subsection is `\large\itshape` (11pt italic). Both
        // are roman family, italic shape — *not* sans, not bold.
        //
        // Original LaTeX \titlespacing values (in 1ex≈5pt at 10pt body):
        //   section:    top 3.5ex+1ex-0.2ex,  bottom 2.3ex+0.2ex
        //   subsection: top 3.25ex+1ex-0.2ex, bottom 1.5ex+0.2ex
        //
        // Translated to em over a 10pt body, then trimmed because Typst
        // adds them on both sides of every heading (LaTeX `\@startsection`
        // collapses adjacent skips, Typst doesn't). Sequential h1→h2
        // ("Fundamentals" → "Sections and Headings") needs the gap kept
        // small; v-after on h1 + v-before on h2 stack additively.
        h1: (weight: "regular", size: 1.2em, style: "italic", v-before: 1.4em, v-after: 0.3em),
        h2: (weight: "regular", size: 1.1em, style: "italic", v-before: 0.4em, v-after: 0.2em),
        // \subsubsection is *disabled* in tufte-handout (lines 1651-1659).
        // We keep an h3 rule because Typst documents need three levels;
        // mirror \paragraph's runin italic style at body size.
        h3: (weight: "regular", size: 1em,   style: "italic", v-before: 0.4em, v-after: 0.1em),
    ),
    margin-note: (
        // \@tufte@marginfont = \normalfont\footnotesize (line 471) —
        // 8pt/10pt, roman, upright. NOT italic, NOT sans. The italic
        // / sans variants come from tufte-css and the `sfsidenotes`
        // option respectively, neither is the handout default.
        size: 0.8em,         // 8pt over 10pt body
        font: ("ETBembo", "Palatino", "Georgia"),
        style: "normal",
        leading: 0.4em,      // (10pt - 8pt) leading shoulder
        marker-sep: 0.3em,
    ),
    sidenote-number: (
        // tufte-common.def:975 — superscript at \footnotesize (8pt).
        // Anchor and margin glyph render the same in print Tufte.
        anchor-size: 0.7em,
        margin-size: 0.85em,
    ),
    newthought: (
        // tufte-common.def:779-782 — `\noindent\textsc{#1}`. Body-size
        // small caps, no tracking, no enlargement. The `\tuftebreak`
        // before is a vertical break, handled by Typst's own par flow.
        size: 1em,
        tracking: 0em,
        lowercase-scale: 0.78,
    ),
    header: (
        size: 8pt,
        weight: "regular",
        tracking: 1.5pt,
        upper: true,
    ),
    title-block: (
        // \maketitle (lines 1561-1589): \LARGE\itshape title (14pt),
        // \Large\itshape author/date (12pt), with parskip=4pt between.
        size: 1.4em,             // \LARGE
        weight: "regular",
        font: auto,              // body font (ETBook/Palatino italic)
        meta-size: 1.2em,        // \Large
        meta-style: "italic",
        meta-sep: 0pt,
        v-after: 1.5em,
    ),
    text: (
        fill: rgb("#111111"),
        // \parindent = 1pc = 12pt (tufte-common.def:420). 1pc/10pt = 1.2em.
        first-line-indent: 1.2em,
        // \parskip = 0pt (line 421). Paragraph break is a fresh indent,
        // no extra vertical gap.
        par-spacing: 0pt,
        // \normalbaselineskip = 14pt for 10pt body (line 375). Typst's
        // default leading is tighter (~0.65em); set it explicitly to
        // match the LaTeX render.
        leading: 0.4em,  // baseline-to-baseline 14pt = 10pt + 4pt shoulder
        // Handout default justification = justified (line 199 + 130).
        justify: true,
    ),
    link: (fill: rgb("#111111"), underline: true),
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
)
