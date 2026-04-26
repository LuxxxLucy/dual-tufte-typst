// HTML target — emits canonical tufte-css markup.
//
// Reference: https://edwardtufte.github.io/tufte-css/ (1.8.0).
// Cross-reference: github.com/LuxxxLucy/web-tufte-typst (Mr. Lucy's
// already-working Typst→tufte-css repo). The label+input+span triplet
// pattern below is mirrored from there: box wraps only the label/input
// pair so Typst doesn't break the surrounding paragraph at the emission
// point; the visible <span> sits as a sibling outside the box.
//
// Math, real TOC, and in-Typst diagram rendering (CeTZ etc.) are
// out of scope; see status.md "Deferred".

#let _CLS = (
    sidenote: "sidenote",
    marginnote: "marginnote",
    sidenote-num: "sidenote-number",
    margin-toggle: "margin-toggle",
    newthought: "newthought",
    fullwidth: "fullwidth",
    epigraph: "epigraph",
    sans: "sans",
    subtitle: "subtitle",
)

// Single per-document counter — browsers require id uniqueness, not
// per-kind numbering, so one counter + distinct id prefixes (sn-, mn-,
// mn-fig-) is enough.
#let _id-counter = counter("dual-tufte-id")

#let _MN-GLYPH = "⊕"

// Emit `<label class="margin-toggle ..."><input type="checkbox" .../>`
// wrapped in `box[...]`. The box keeps Typst from breaking the surrounding
// paragraph at the emission point — without it, label+input land in their
// own `<p>` and the trailing visible `<span>` opens a fresh paragraph
// after them, severing the inline anchor flow.
#let _toggle(prefix, glyph: "", extra-class: "") = context {
    _id-counter.step()
    let id = prefix + str(_id-counter.get().first())
    let cls = if extra-class != "" { _CLS.margin-toggle + " " + extra-class }
              else { _CLS.margin-toggle }
    box[
        #html.elem("label", attrs: (("for"): id, ("class"): cls))[#glyph]
        #html.elem("input", attrs: (("type"): "checkbox", ("id"): id, ("class"): _CLS.margin-toggle))[]
    ]
}

#let _sidenote-triplet(body) = {
    _toggle("sn-", extra-class: _CLS.sidenote-num)
    html.elem("span", attrs: (("class"): _CLS.sidenote))[#body]
}

#let _marginnote-triplet(body) = {
    _toggle("mn-", glyph: _MN-GLYPH)
    html.elem("span", attrs: (("class"): _CLS.marginnote))[#body]
}

#let sidenote-html(numbered, body) = {
    if numbered { _sidenote-triplet(body) } else { _marginnote-triplet(body) }
}

// Main figure: image is the body, caption hoisted into the margin via a
// marginnote triplet — all inside <figure>.
#let main-figure-html(content, caption) = {
    html.elem("figure")[
        #if caption != none {
            _toggle("mn-fig-", glyph: _MN-GLYPH)
            html.elem("span", attrs: (("class"): _CLS.marginnote))[#caption]
        }
        #content
    ]
}

// Margin figure: image + caption live entirely in the margin column,
// inline-adjacent to the surrounding paragraph. NOT wrapped in <figure>
// (matches web-tufte-typst — the image goes inside the marginnote span).
#let margin-figure-html(content, caption) = {
    _toggle("mn-fig-", glyph: _MN-GLYPH)
    html.elem("span", attrs: (("class"): _CLS.marginnote))[
        #box[#content]
        #if caption != none [ #caption]
    ]
}

// Full-width figure: spans across main + margin via tufte-css `.fullwidth`.
// Must be a child of <article>/<section>; the document scaffold places body
// content inside <section>, so this lands correctly.
#let full-width-figure-html(content, caption) = {
    html.elem("figure", attrs: (("class"): _CLS.fullwidth))[
        #content
        #if caption != none {
            html.elem("figcaption")[#caption]
        }
    ]
}

// Single epigraph — wrapped in <div class="epigraph"> so tufte-css's
// `div.epigraph > blockquote` italic + offset styling applies.
#let epigraph-html(quote, author) = {
    html.elem("div", attrs: (("class"): _CLS.epigraph))[
        #html.elem("blockquote")[
            #html.p(quote)
            #if author != none { html.elem("footer")[#author] }
        ]
    ]
}

// Newthought: span.newthought wrapping inner small-caps span (matches
// web-tufte-typst output; CSS class alone isn't always enough — the
// inner explicit `font-variant-caps: small-caps` ensures small-caps
// renders even without the tufte stylesheet).
#let new-thought-html(body) = {
    html.elem("span", attrs: (("class"): _CLS.newthought))[
        #html.elem("span", attrs: (("style"): "font-variant-caps: small-caps"))[#body]
    ]
}

#let full-width-html(body) = html.elem("div", attrs: (("class"): _CLS.fullwidth))[#body]

#let sidecite-html(key) = _sidenote-triplet(cite(key, form: "full"))

#let sans-html(body) = html.elem("p", attrs: (("class"): _CLS.sans))[#body]

#let _render-title-block-html(title, author, email, date) = {
    if title != none { html.elem("h1")[#title] }
    let parts = ()
    if author != none { parts.push(author) }
    if email != none { parts.push(email) }
    if date != none {
        parts.push(if type(date) == datetime { date.display() } else { date })
    }
    if parts.len() > 0 {
        html.elem("p", attrs: (("class"): _CLS.subtitle))[#parts.join(", ")]
    }
}

// CDN by default. For offline / pinned builds pass `html-css: "tufte.min.css"`.
#let _default-css = ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",)

#let setup-html(cfg, title, author, email, date, abstract, toc, lang, css-urls, body) = {
    let doc-title = if title != none { title } else { "Document" }
    let html-css = if css-urls == auto { _default-css }
                   else if type(css-urls) == str { (css-urls,) }
                   else { css-urls }

    // Reset counter so ids are stable across rebuilds.
    _id-counter.update(0)
    // `toc` is accepted to mirror the PDF target's signature; HTML TOC
    // generation isn't implemented yet (see status.md "Deferred").
    let _ = toc

    let body-section = html.elem("section")[
        #set text(fill: rgb("#111"))
        #set par(spacing: 1.4em)
        // HTML export drops equations but `@`-references still need a
        // numbering rule to exist, otherwise `@eq-label` errors hard.
        #set math.equation(numbering: "(1)")
        #show link: set text(fill: rgb("#111"))
        #show list: set block(width: 50%)

        // Raw `#figure(...)` → main-figure default (caption in margin).
        // `main-figure(...)`, `margin-figure(...)`, `full-width-figure(...)`
        // bypass this rule by emitting HTML directly.
        // Render full caption (supplement + counter + body) so "Figure N: ..."
        // numbering is visible. tufte-css's figcaption styling applies to
        // <figcaption>; here the caption sits inside <span class="marginnote">,
        // so we emit the text directly.
        #show figure: it => {
            let cap = if it.has("caption") and it.caption != none {
                {
                    it.caption.supplement
                    sym.space.nobreak
                    it.caption.counter.display()
                    it.caption.separator
                    it.caption.body
                }
            } else { none }
            main-figure-html(it.body, cap)
        }
        #show footnote: it => _sidenote-triplet(it.body)

        // Typst's `#line(...)` is page-geometry primitive — invisible in
        // HTML by default. Map it to <hr/> so a horizontal rule survives
        // the export.
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
        body-section
    }

    html.elem("html", attrs: (("lang"): lang))[
        #html.elem("head")[
            #html.elem("meta", attrs: (("charset"): "utf-8"))[]
            #html.elem("meta", attrs: (("name"): "viewport", ("content"): "width=device-width, initial-scale=1"))[]
            #html.elem("title")[#doc-title]
            #for css-link in html-css {
                html.elem("link", attrs: (
                    ("rel"): "stylesheet",
                    ("href"): css-link,
                ))[]
            }
            #html.elem("style")[
                .subtitle + p { margin-top: 2.5em; }
                p + h2 { margin-top: 5.5rem; }
                /* tufte-css doesn't constrain h1..h3 width; without this,
                   a sidenote/marginnote inside a heading floats relative
                   to the full section width and lands far right of the
                   margin column. Match the 55% body width so the float
                   anchors at the same edge as a sidenote inside `<p>`. */
                article h1, article h2, article h3 { max-width: 55%; }
                /* tufte-css scopes body-text size to `p`; mirror it on
                   bare full-width prose so a `<div class=fullwidth>`
                   containing inline text reads at the same size. */
                div.fullwidth { font-size: 1.4rem; line-height: 2rem; }
                /* tufte-css's table.fullwidth rule requires the class on
                   the <table>; our wrapper places it on the parent <div>,
                   so propagate width to a directly-nested <table>. */
                div.fullwidth > table { width: 100%; }
                /* tufte-css styles h1..h3 only; deeper Typst headings
                   land on <h4>+ and would inherit the browser default
                   (smaller than body). Match the h3 italic+size scale. */
                h4 { font-style: italic; font-weight: 400; font-size: 1.4rem; line-height: 2rem; margin-top: 2rem; margin-bottom: 0; }
                h5 { font-style: italic; font-weight: 400; font-size: 1.2rem; line-height: 2rem; margin-top: 2rem; margin-bottom: 0; }
            ]
        ]
        #html.elem("body")[
            #html.elem("article")[#article-body]
        ]
    ]
}
