// HTML target. Emits canonical tufte-css markup.
// Reference: https://edwardtufte.github.io/tufte-css/ (1.8.0).

// Inner span style for newthought: explicit font-variant ensures small
// caps render even without the tufte stylesheet.
#let _NEWTHOUGHT_INNER = "font-variant-caps: small-caps"

// Single per-document counter for id uniqueness; per-kind numbering
// is not needed.
#let _id-counter = counter("dual-tufte-id")

#let _MN-GLYPH = "⊕"

#let _in-frame = state("dual-tufte-in-frame", false)

// label+input wrapped in `box[...]` so Typst doesn't break the
// surrounding paragraph between the toggle and the trailing visible
// `<span>`. The span sits as a sibling outside the box.
#let _toggle(prefix, glyph: "", label-class: "margin-toggle") = context {
    _id-counter.step()
    let id = prefix + str(_id-counter.get().first())
    box[
        #html.elem("label", attrs: (("for"): id, ("class"): label-class))[#glyph]
        #html.elem("input", attrs: (("type"): "checkbox", ("id"): id, ("class"): "margin-toggle"))[]
    ]
}

// A block element inside the note <span> closes the enclosing <p> and drops
// the note into the main column, so blocks become block-level spans.
// Figures, code blocks and block math split the paragraph before any show
// rule runs; they stay unsupported.
#let _note-body(body) = {
    let div(style: "", body) = html.elem("span", attrs: (("style"): "display: block; " + style))[#body]
    show parbreak: div(style: "height: 0.6rem;")[]
    show enum: it => {
        let n = if it.start == auto { 0 } else { it.start - 1 }
        for item in it.children {
            let given = item.at("number", default: auto)
            n = if given == auto { n + 1 } else { given }
            div[#numbering(it.numbering, n) #item.body]
        }
    }
    show list: it => for item in it.children { div[#sym.bullet #item.body] }
    show align: it => div(style: if it.alignment.x == none { "" } else { "text-align: " + repr(it.alignment.x) + ";" })[#it.body]
    body
}

#let _sidenote-triplet(body) = {
    _toggle("sn-", label-class: "margin-toggle sidenote-number")
    html.elem("span", attrs: (("class"): "sidenote"))[#_note-body(body)]
}

#let _marginnote-triplet(body) = {
    _toggle("mn-", glyph: _MN-GLYPH)
    html.elem("span", attrs: (("class"): "marginnote"))[#_note-body(body)]
}

#let sidenote-html(numbered, body) = {
    if numbered { _sidenote-triplet(body) } else { _marginnote-triplet(body) }
}

// Margin figure: image + caption live inside the marginnote span (not
// wrapped in <figure>), matching web-tufte-typst.
#let margin-figure-html(content, caption) = _marginnote-triplet({
    box[#content]
    if caption != none { html.elem("span", attrs: (("class"): "figure-caption"))[#caption] }
})

#let epigraph-html(quote, author) = {
    html.elem("div", attrs: (("class"): "epigraph"))[
        #html.elem("blockquote")[
            #html.p(quote)
            #if author != none { html.elem("footer")[#author] }
        ]
    ]
}

#let new-thought-html(body) = {
    html.elem("span", attrs: (("class"): "newthought"))[
        #html.elem("span", attrs: (("style"): _NEWTHOUGHT_INNER))[#body]
    ]
}

#let full-width-html(body) = html.elem("div", attrs: (("class"): "fullwidth"))[#body]

#let sidecite-html(key) = _sidenote-triplet(cite(key, form: "full"))

#let sans-html(body) = html.elem("p", attrs: (("class"): "sans"))[#body]

#let _format-meta-parts(author, email, date) = {
    let parts = ()
    if author != none { parts.push(author) }
    if email != none { parts.push(email) }
    if date != none {
        parts.push(if type(date) == datetime { date.display() } else { date })
    }
    parts
}

#let _render-title-block-html(title, author, email, date) = {
    if title != none { html.elem("h1")[#title] }
    let parts = _format-meta-parts(author, email, date)
    if parts.len() > 0 {
        html.elem("p", attrs: (("class"): "subtitle"))[#parts.join(", ")]
    }
}

// CDN by default. For offline / pinned builds pass `html-css: "tufte.min.css"`.
#let _default-css = ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",)

// Fixes on top of tufte-css: captions sit under the figure as in the PDF
// target instead of floating into the margin; h1..h3 get the column width
// so a heading sidenote lands in the margin; h4/h5 rules tufte-css lacks.
#let _INLINE_STYLE = "figcaption { float: none; clear: both; max-width: 100%; margin: 0.4rem 0 0; }
div.fullwidth > figure { max-width: 100%; }
div.fullwidth > table { width: 100%; }
img { height: auto; }
.figure-caption { display: block; margin-top: 0.4rem; }
.typst-frame use { fill: currentColor; }
p.equation { text-align: center; position: relative; }
p.equation > .equation-number { position: absolute; right: 0; top: 50%; transform: translateY(-50%); }
article h1, article h2, article h3 { max-width: 55%; }
h4 { font-style: italic; font-weight: 400; font-size: 1.4rem; line-height: 2rem; margin-top: 2rem; margin-bottom: 0; }
h5 { font-style: italic; font-weight: 400; font-size: 1.2rem; line-height: 2rem; margin-top: 2rem; margin-bottom: 0; }"

#let _heading-slug(idx) = "h-" + str(idx + 1)

#let toc-html-block() = context {
    let hs = query(heading)
    if hs.len() == 0 { return }
    html.elem("nav", attrs: (("class"): "toc"))[
        #html.elem("h2")[Contents]
        #html.elem("ul", attrs: (("style"): "list-style: none; padding-left: 0;"))[
            #for (i, h) in hs.enumerate() {
                let indent = str((h.level - 1) * 1.2) + "rem"
                html.elem("li", attrs: (("style"): "margin-left: " + indent))[
                    #html.elem("a", attrs: (("href"): "#" + _heading-slug(i)))[#h.body]
                ]
            }
        ]
    ]
}

#let setup-html(cfg, title, author, email, date, abstract, toc, lang, css-urls, head-extra, body) = {
    let doc-title = if title != none { title } else { "Document" }
    let html-css = if css-urls == auto { _default-css }
                   else if type(css-urls) == str { (css-urls,) }
                   else { css-urls }

    _id-counter.update(0)

    let html-text-fill = cfg.at("html-text-fill", default: cfg.text.fill)
    let html-par-spacing = cfg.at("html-par-spacing", default: 1.4em)
    let body-section = html.elem("section")[
        #set text(fill: html-text-fill)
        #set par(spacing: html-par-spacing)
        #set math.equation(numbering: "(1)")
        #set raw(theme: none)
        #show heading: it => context {
            let idx = query(heading).position(h => h.location() == it.location())
            let tag = "h" + str(it.level)
            html.elem(tag, attrs: (("id"): _heading-slug(idx)))[#it.body]
        }
        // typst/typst#5512: no native MathML emit; inline SVG via html.frame.
        // The <p> gives the equation the paragraph type size and centres it
        // as in the PDF target. The frame lays out an unnumbered copy; the
        // original element steps the counter and carries the label.
        #show math.equation: it => context if _in-frame.get() { it } else if it.block {
            html.elem("p", attrs: (("class"): "equation"))[#box(html.frame({
                _in-frame.update(true)
                math.equation(block: true, numbering: none, it.body)
                _in-frame.update(false)
            }))#if it.numbering != none {
                html.elem("span", attrs: (("class"): "equation-number"))[#counter(math.equation).display(it.numbering)]
            }]
        } else { box(html.frame(it)) }
        #show link: set text(fill: cfg.at("html-link-fill", default: html-text-fill))
        #show list: set block(width: 50%)

        #show footnote: it => _sidenote-triplet(it.body)
        // Typst's `line()` is a page-geometry primitive (invisible in
        // HTML by default). Map to <hr/>.
        #show line: it => html.elem("hr")[]
        #show quote: it => html.elem("blockquote")[
            #html.p(it.body)
            #if it.attribution != none { html.elem("footer")[#it.attribution] }
        ]

        #body
    ]

    let article-body = {
        _render-title-block-html(title, author, email, date)
        if abstract != none { html.elem("p")[#abstract] }
        if toc { toc-html-block() }
        body-section
    }

    html.elem("html", attrs: (("lang"): lang))[
        #html.elem("head")[
            #html.elem("meta", attrs: (("charset"): "utf-8"))[]
            #html.elem("meta", attrs: (("name"): "viewport", ("content"): "width=device-width, initial-scale=1"))[]
            // Per-style default via `cfg.html-color-scheme`; CLI override
            // via `--input color-scheme=light` wins for deterministic refs.
            #let scheme = sys.inputs.at(
                "color-scheme",
                default: cfg.at("html-color-scheme", default: "light dark"),
            )
            #html.elem("meta", attrs: (("name"): "color-scheme", ("content"): scheme))[]
            #html.elem("title")[#doc-title]
            // Caller-supplied head injection: any extra `<meta>`, `<link>`,
            // `<script>`, or other head-level content. Construct with
            // `html.elem` so Typst emits real elements rather than escaped
            // text.
            #if head-extra != none { head-extra }
            #for css-link in html-css {
                html.elem("link", attrs: (
                    ("rel"): "stylesheet",
                    ("href"): css-link,
                ))[]
            }
            #html.elem("style")[#_INLINE_STYLE]
            // Emitted last so it wins on source order.
            #let extra = cfg.at("html-extra-css", default: none)
            #if extra != none and extra != "" { html.elem("style")[#extra] }
        ]
        #html.elem("body")[
            #html.elem("article")[#article-body]
        ]
    ]
}
