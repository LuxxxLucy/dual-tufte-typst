// HTML-specific implementation for tufte-css output
// Known limitations:
//   - Mobile toggle requires CSS adjacent sibling selector which Typst's HTML breaks; a workaround is to amend the css but I do not wish to do that.
//   - Single <section> wraps all content (tufte-css uses one per h2)

#let sidenote-html(numbered, body) = {
    let note-cls = if numbered { "sidenote" } else { "marginnote" }
    if numbered { html.span(class: "sidenote-number") }
    html.span(class: note-cls, body)
}

#let main-figure-html(content, caption) = {
    figure(content, caption: caption)
}

#let margin-figure-html(content, caption) = {
    // Use Typst's native figure to get automatic numbering
    show figure: it => {
        html.span(class: "marginnote", { it.body; it.caption })
    }
    figure(content, caption: caption)
}

#let full-width-figure-html(content, caption) = {
    // Use Typst's native figure to get automatic numbering
    // Override both caption and figure show rules for full-width layout
    show figure.caption: it => html.figcaption(
        it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body
    )
    show figure: it => html.figure(class: "fullwidth", {
        it.body
        it.caption
    })
    figure(content, caption: caption)
}

#let epigraph-html(quote, author) = {
    html.div(class: "epigraph", html.blockquote({
        html.p(quote)
        if author != none { html.footer(author) }
    }))
}

#let new-thought-html(body) = html.span(class: "newthought", body)

#let full-width-html(body) = html.div(class: "fullwidth", body)

#let sidecite-html(key) = {
    html.span(class: "sidenote-number")
    html.span(class: "sidenote", cite(key, form: "full"))
}

#let sans-html(body) = html.p(class: "sans", body)

#let render-title-block-html(title, author, date) = {
    if title != none { html.h1(title) }
    if author != none or date != none {
        let subtitle = if author != none and date != none {
            author + ", " + date.display()
        } else if author != none { author } else { date.display() }
        html.p(class: "subtitle", subtitle)
    }
}

#let render-abstract-html(abstract) = {
    if abstract != none { html.p(abstract) }
}

#let render-toc-html(toc) = {
    if toc == true {
        html.nav(class: "toc", { html.h2[Contents]; html.p[Table of contents displays section headings.] })
    }
}

#let setup-html(title, author, date, abstract, toc, lang, css-urls, body) = {
    let doc-title = if title != none { title } else { "Document" }
    let html-css = if css-urls == auto {
        ("https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",)
    } else if type(css-urls) == str { (css-urls,) } else { css-urls }

    let styled-body = {
        set text(fill: rgb("#111"))
        set par(spacing: 1.4em)
        show link: set text(fill: rgb("#111"))
        show list: set block(width: 50%)

        show figure.caption: it => {
            html.span(class: "marginnote", it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body)
        }
        show figure: it => html.figure({ it.caption; it.body })
        show footnote: it => sidenote-html(true, it.body)

        show quote: it => {
            html.blockquote({
                html.p(it.body)
                if it.attribution != none {
                    html.footer(it.attribution)
                }
            })
        }

        render-title-block-html(title, author, date)
        render-abstract-html(abstract)
        render-toc-html(toc)
        body
    }

    html.html(lang: lang, {
        html.head({
            html.meta(charset: "utf-8")
            html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
            html.title(doc-title)
            for css-link in html-css { html.link(rel: "stylesheet", href: css-link) }
            html.elem("style", {
                ".subtitle + p { margin-top: 2.5em; }"
                "p + h2, { margin-top: 5.5rem; }"
            })
        })
        html.body(html.article(html.section(styled-body)))
    })
}
