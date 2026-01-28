// Shared constants and utilities

// Default font stacks (can be imported by advanced users)
#let default-body-font = ("ETBembo", "Palatino", "Georgia")
#let default-sans-font = ("Gill Sans", "Helvetica")
#let default-mono-font = ("Monaco", "Courier New")

// Default font sizes
#let default-font-sizes = (
    tiny: 8pt,
    small: 9pt,
    normal: 11pt,
    large: 13pt,
    larger: 16pt,
)

// Backward compatibility exports
#let body-font = default-body-font
#let sans-font = default-sans-font
#let mono-font = default-mono-font
#let font-sizes = default-font-sizes

// Resolve auto to default
#let resolve-font(user-value, default-value) = {
    if user-value == auto { default-value } else { user-value }
}

#let full-width-size = 100% + 2in
#let sidenote-counter = counter("sidenote")

#let tight-par(content) = {
    set par(leading: 0.55em, spacing: 0.5em)
    content
}

#let apply-common-styles(body, body-font-family: body-font, sans-font-family: sans-font) = {
    set text(font: body-font-family, size: font-sizes.normal)

    show heading.where(level: 1): it => {
        set text(font: body-font-family, size: font-sizes.larger, style: "italic", weight: "regular")
        set block(above: 4em, below: 1.5em)
        it
    }

    show heading.where(level: 2): it => {
        set text(font: body-font-family, size: font-sizes.large, style: "italic", weight: "regular")
        set block(above: 2.1em, below: 1.4em)
        it
    }

    show heading.where(level: 3): it => {
        set text(font: body-font-family, size: font-sizes.normal, style: "italic", weight: "regular")
        set block(above: 2em, below: 1.4em)
        it
    }

    show figure.caption: set text(font: sans-font-family, size: font-sizes.small)
    show figure.caption: set align(left)

    body
}
