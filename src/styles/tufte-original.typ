// tufte-original — Tufte-LaTeX `tufte-handout` ported to Typst.
// Source: .refs/style-research/tufte-common.def + tufte-handout.cls.
// All numbers below quote those files by line number.
//
// Pivot style. Other PDF styles `merge-config(tufte-original, <delta>)`
// so geometry, leading, and heading shape stay coherent gallery-wide.

#import "_stacks.typ" as stacks

#let tufte-original = (
    name: "tufte-original",
    // Geometry from tufte-common.def:446 — left=1in, textwidth=26pc
    // (4.33in), marginparsep=2pc (0.33in), marginparwidth=12pc (2in).
    page: (
        paper: "us-letter",
        margin-x: 1in,
        margin-y: 1in,
        fill: rgb("#fffff8"),
    ),
    margin-col: (
        width: 2in,
        sep: 0.333in,
    ),
    // Bundled `et-book` .ttfs register under family `ETBembo` (per their
    // `name` table), so listing "ETBook" first would always miss.
    fonts: (
        body:   stacks.etbembo,
        sans:   stacks.gillsans,
        mono:   stacks.menlo-mono,
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
    // tufte-common.def:1622-1647 — \section = \Large\itshape (12pt
    // italic), \subsection = \large\itshape (11pt italic). LaTeX
    // \titlespacing values trimmed for Typst because `\@startsection`
    // collapses adjacent skips; Typst stacks v-after + v-before
    // additively, so sequential h1→h2 ("Fundamentals" → "Sections and
    // Headings") needs the gap kept small. \subsubsection is disabled
    // in the handout class; h3 mirrors \paragraph at body size.
    headings: (
        h1: (weight: "regular", size: 1.2em, style: "italic", v-before: 1.4em, v-after: 0.3em),
        h2: (weight: "regular", size: 1.1em, style: "italic", v-before: 0.4em, v-after: 0.2em),
        h3: (weight: "regular", size: 1em,   style: "italic", v-before: 0.4em, v-after: 0.1em),
    ),
    // \@tufte@marginfont = \normalfont\footnotesize (line 471) — 8pt
    // roman upright. Italic / sans variants are tufte-css and the
    // `sfsidenotes` option, not the handout default.
    margin-note: (
        size: 0.8em,
        font: stacks.etbembo,
        style: "normal",
        leading: 0.4em,
        marker-sep: 0.3em,
    ),
    // tufte-common.def:975 — superscript at \footnotesize.
    sidenote-number: (
        anchor-size: 0.7em,
        margin-size: 0.85em,
    ),
    // tufte-common.def:779-782 — `\noindent\textsc{#1}`. Body-size,
    // no tracking; lowercase-scale fakes small caps for fonts without
    // smcp glyphs (see new-thought-pdf).
    newthought: (
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
    // \maketitle (1561-1589): \LARGE italic title (14pt), \Large italic
    // author/date (12pt), parskip=4pt between.
    title-block: (
        size: 1.4em,
        weight: "regular",
        font: auto,
        meta-size: 1.2em,
        meta-style: "italic",
        meta-sep: 0pt,
        v-after: 1.5em,
    ),
    // \parindent = 1pc = 12pt (line 420), \parskip = 0pt (line 421),
    // \normalbaselineskip = 14pt (line 375), justified (line 199).
    text: (
        fill: rgb("#111111"),
        first-line-indent: 1.2em,
        par-spacing: 0pt,
        leading: 0.4em,
        justify: true,
    ),
    link: (fill: rgb("#111111"), underline: true),
    css: ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",),
)
