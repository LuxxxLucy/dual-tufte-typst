// LIMITATION (HTML target only): a marginnote whose body contains multiple
// paragraphs (or a paragraph plus a code block). Same root cause as the
// multi-paragraph sidenote — `<p>` / `<pre>` inside `<span class="marginnote">`
// gets reparented by the browser. The bezierlogue reproductions exercise
// this pattern heavily; the smoke test counts hundreds of `<p>` inside
// marginnote across those documents.
//
// PDF target renders correctly via marginalia.note.
// !with: (title: [Multi-paragraph marginnote (HTML limitation)])

Body sentence with a substantial margin aside.#marginnote[
    First paragraph of the marginnote.

    Second paragraph — code-block-adjacent prose, illustrating how a margin
    aside that spans more than one paragraph breaks out of `<span class="marginnote">`.
] Body text continues here.
