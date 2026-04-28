// LIMITATION (HTML target only): a sidenote whose body contains multiple
// paragraphs. Typst wraps each paragraph in `<p>`; browsers reject `<p>`
// inside `<span class="sidenote">` and reparent — only the superscript
// number lands in the margin, the body escapes into top-level flow.
//
// PDF target renders correctly via marginalia.note.
// !with: (title: [Multi-paragraph sidenote (HTML limitation)])

A claim that needs an extended sidenote#sidenote[
    First paragraph of the sidenote, anchored to the marker.

    Second paragraph in the same sidenote — this is what trips up the HTML
    target. PDF (via marginalia) handles it; HTML reparents the inner `<p>`
    out of `<span class="sidenote">`.
] in the body. The HTML pane will show only the superscript here and dump
both note paragraphs into the main flow. The PDF pane will show the full
two-paragraph note in the margin.
