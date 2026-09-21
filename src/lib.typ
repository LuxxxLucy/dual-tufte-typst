// Dual-format Tufte template. One .typ source compiles to PDF (marginalia
// handout) or HTML (tufte-css).
//
// Author: Jialin Lu <luxxxlucy@gmail.com>
// License: MIT
//
// References:
//   Tufte LaTeX:        https://github.com/Tufte-LaTeX/tufte-latex
//   Tufte CSS:          https://github.com/edwardtufte/tufte-css
//   marginalia (Typst): https://typst.app/universe/package/marginalia

#import "styles/registry.typ" as styles
#import "pdf.typ"
#import "html.typ" as web

#let _is-html = sys.inputs.at("target", default: "pdf") == "html"
#let _target = if _is-html { web } else { pdf }

#let sidenote(numbered: true, dy: 0pt, body) = _target.sidenote(numbered, dy, body)

#let marginnote(dy: 0pt, body) = sidenote(numbered: false, dy: dy, body)

#let sidecite(key, dy: 0pt) = sidenote(dy: dy, cite(key, form: "full"))

#let margin-figure(content, caption: none, dy: 0pt) = _target.margin-figure(content, caption, dy)

#let epigraph(quote, author: none) = _target.epigraph(quote, author)

#let new-thought(body) = _target.new-thought(body)

#let full-width(body) = _target.full-width(body)

#let sans(body) = _target.sans(body)

#let main-figure(content, caption: none) = figure(content, caption: caption)

// A label after the call binds to the wrapper, not the figure; write
// `#full-width[#figure(..) <fig>]` to reference one.
#let full-width-figure(content, caption: none) = full-width(figure(content, caption: caption))

// Embed CeTZ or other drawn content as inline SVG in HTML.
#let diagram(body) = if _is-html { html.frame(body) } else { body }

// Deep merge; `overrides` wins.
#let merge-config(base, overrides) = {
    if overrides == none or overrides == auto { return base }
    let out = base
    for (k, v) in overrides {
        if type(out.at(k, default: none)) == dictionary and type(v) == dictionary {
            out.insert(k, merge-config(out.at(k), v))
        } else {
            out.insert(k, v)
        }
    }
    out
}

// Merge order: tufte-original, the style, then `config`.
#let tufte(
    title: none,
    author: none,
    email: none,
    date: none,
    abstract: none,
    lang: "en",
    toc: false,
    bib: none,
    html-css: auto,
    style: "tufte-original",
    config: auto,
    head-extra: none,
    body,
) = {
    set text(lang: lang)
    let cfg = merge-config(merge-config(styles.tufte-original, styles.resolve(style)), config)
    if html-css != auto { cfg.html.css = if type(html-css) == str { (html-css,) } else { html-css } }

    let doc = (
        title: title,
        meta: (author, email, if type(date) == datetime { date.display() } else { date }).filter(p => p != none),
        abstract: abstract,
        toc: toc,
        lang: lang,
        head-extra: head-extra,
    )
    _target.setup(cfg, doc, { body; bib })
}
