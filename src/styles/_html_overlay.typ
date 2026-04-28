// Per-style HTML overlay on top of canonical tufte-css. The result is
// inlined into <head>; tufte-css supplies geometry, this layer paints.

#let html-overlay(
    import-css: "",
    body-font: "Georgia, serif",
    heading-font: none,
    mono-font: "JetBrains Mono, ui-monospace, monospace",
    bg: "#ffffff",
    fg: "#111111",
    link: "#0066cc",
    heading-color: none,
    note-color: none,
    link-underline: false,
    body-size: "1.05rem",
    body-line-height: "1.6",
    quote-size: "1.4rem",
    quote-line-height: "2rem",
    extra: "",
) = {
    let h-font = if heading-font == none { body-font } else { heading-font }
    let h-color = if heading-color == none { fg } else { heading-color }
    let n-color = if note-color == none { fg } else { note-color }
    let link-deco = if link-underline { "underline" } else { "none" }
    let link-hover = if link-underline { "" } else { "a:hover { text-decoration: underline; }" }
    (
        import-css
        + "html { background-color: " + bg + "; }"
        + "body { background-color: " + bg + "; color: " + fg + ";"
        + " font-family: " + body-font + ";"
        + " font-size: " + body-size + "; line-height: " + body-line-height + "; }"
        + "h1, h2, h3, h4, h5, h6, .subtitle, .newthought {"
        + " font-family: " + h-font + "; color: " + h-color + ";"
        + " font-style: normal; }"
        + ".sidenote, .marginnote, .sidenote-number, figcaption {"
        + " font-family: " + body-font + "; font-style: normal;"
        + " color: " + n-color + "; }"
        + "code, pre, .code, kbd, samp { font-family: " + mono-font + "; }"
        + "a:link, a:visited { color: " + link + "; text-shadow: none;"
        + " background-image: none; text-decoration: " + link-deco + ";"
        + " text-decoration-skip-ink: auto; text-underline-offset: 0.15em; }"
        + link-hover
        + " article blockquote, article blockquote p {"
        + " font-size: " + quote-size + "; line-height: " + quote-line-height + "; }"
        + extra
    )
}
