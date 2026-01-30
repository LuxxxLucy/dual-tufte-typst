// Shared constants and utilities

// Default font stacks (can be imported by advanced users)
#let body-font = ("ETBembo", "Palatino", "Georgia")
#let sans-font = ("Gill Sans", "Helvetica")
#let mono-font = ("Monaco", "Courier New")

// Default font sizes
#let font-sizes = (
    tiny: 8pt,
    small: 9pt,
    normal: 11pt,
    large: 12pt,
    larger: 14pt,
    huge: 17pt,
)

// Resolve auto to default
#let resolve-font(user-value, default-value) = {
    if user-value == auto { default-value } else { user-value }
}

#let sidenote-counter = counter("sidenote")
