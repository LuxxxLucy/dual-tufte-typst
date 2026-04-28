# dual-tufte-typst

Write a Tufte-style document once in [Typst](https://typst.app/). Get a print-ready PDF (handout layout, sidenotes in the margin) and a tufte-css web page from the same source. Same API, both outputs.

**[→ Live web app](https://luxxxlucy.github.io/dual-tufte-typst/)** — six styles in side-by-side PDF/HTML, plus an in-browser editor that compiles Typst with [typst.ts](https://github.com/Myriad-Dreamin/typst.ts). Rebuilt by `.github/workflows/build-web.yml` on every push to `main`.

## Try it locally

Requires Typst >= 0.14. Clone, fetch fonts, build the example:

```bash
git clone https://github.com/LuxxxLucy/dual-tufte-typst
cd dual-tufte-typst
./assets/fonts/fetch.sh
typst compile --root . --font-path assets/fonts example/example.typ           # PDF
typst compile --root . --font-path assets/fonts \
    --features html --input target=html example/example.typ example.html      # HTML
```

For your own document:

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(title: [Document Title], author: "Your Name")

Content with #sidenote[a margin note].
```

`example/example.typ` is the feature tour; read it alongside the rendered output to learn the API.

## Status

Pre-1.0. The API surface (helpers + `tufte.with(...)` parameters) is stable, but field names inside `config:` records can move between minor versions. Pin to a tag if you depend on a specific layout.

Typst 0.14 only — Typst's HTML emit is still evolving and we track upstream.

## API

`tufte()` is the entry point. Per-feature helpers come from the same module.

| Helper | Purpose |
|---|---|
| `sidenote(numbered: true, body)` | Numbered margin note with inline reference. |
| `marginnote(body)` | Unnumbered margin note. |
| `sidecite(key)` | Bibliography citation rendered as a numbered margin note. |
| `main-figure(content, caption)` | Figure in the text column, caption in the margin. |
| `margin-figure(content, caption)` | Figure entirely in the margin. |
| `full-width-figure(content, caption)` | Figure spans text column + margin. |
| `full-width(body)` | Block content spanning the full width. |
| `epigraph(quote, author)` | Section-opening quotation. |
| `new-thought(body)` | Tufte's small-caps section opener. |
| `sans(body)` | Sans-serif paragraph. |
| `diagram(body)` | Wrap a CeTZ canvas (or any drawable) so HTML emits inline SVG. |

`tufte.with(...)` parameters:

| Parameter | Default | Meaning |
|---|---|---|
| `title` | `none` | Document title. |
| `author`, `email`, `date` | `none` | Byline metadata. `date` accepts a `datetime` or string. |
| `abstract` | `none` | Italic abstract block under the title. |
| `toc` | `false` | Auto table of contents. |
| `lang` | `"en"` | Document language. |
| `bib` | `none` | Bibliography to run after the body, e.g. `bibliography("refs.bib")`. |
| `style` | `"tufte-original"` | Registered style name (see Styles). |
| `config` | `auto` | Per-call config overrides (see Customization). |
| `html-css` | `auto` | Override the style's HTML stylesheet list. |

CLI inputs read at compile time:

| Input | Effect |
|---|---|
| `--input target=html` | Switch to the HTML target (use with `--features html`). |
| `--input style=<name>` | Override the style without editing the source. |
| `--input color-scheme=light` | Force light mode in the HTML `<meta name="color-scheme">` (defaults to per-style). |

### Examples

CeTZ figure with the same source compiling for both targets:

```typst
#import "@preview/cetz:0.4.2"
#import "src/lib.typ": tufte, diagram, main-figure

#show: tufte.with(title: [...])

#main-figure(
  diagram(cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: 1)
    line((-1.2, 0), (1.2, 0))
  })),
  caption: [Unit circle.],
)
```

Citation rendered as a numbered margin note:

```typst
#show: tufte.with(title: [...], bib: bibliography("refs.bib"))

The result was first reported in #sidecite("smith2024") and later refined.
```

## Styles

Pick a style by name, or pass `--input style=<name>`:

```typst
#show: tufte.with(title: [...], style: "envision")
```

| Style | Mirrors | Notes |
|---|---|---|
| `tufte-original` | tufte-LaTeX `tufte-handout` class | calibrated, default |
| `envision` | rstudio/tufte's envisioned variant | calibrated |
| `jialin` | web-handout look (Gill Sans title, 9pt body) | uses Berkeley Mono — excluded from public web app |
| `terpret` | tufte-css with web paragraphing | layered on `tufte-original` |
| `orange-happy` | warm cream + orange accent, sans aesthetic (Inter) | layered on `tufte-original` |
| `bluewhite` | minimal white + blue link, sans aesthetic (Inter) | layered on `tufte-original` |

Each style record can carry a `css:` field listing one or more stylesheet URLs the HTML target injects. `envision` uses this to load tufte.min.css plus rstudio's envisioned overlay. A style can also set `html-color-scheme: "light"` when its CSS does not ship a dark variant, and `html-extra-css` for inline CSS overrides on top of the bundled stylesheet.

## Customization

Override the style's HTML stylesheet for a single document:

```typst
#show: tufte.with(
    title: [...],
    style: "tufte-original",
    html-css: ("https://my-cdn.example/custom-tufte.css",),
)
```

Local file paths work the same way; the browser resolves them relative to the output HTML, so no `read()` inlining is needed.

Inline config overrides merge over the style (merge order: `default-config` -> style -> `config`):

```typst
#show: tufte.with(
    title: [...],
    config: (
        page: (margin-x: 1in),
        sizes: (body: 9pt),
    ),
)
```

### Page geometry

`config.page` mirrors Typst's native `set page(...)` arguments. Use `paper:` for named sizes, or pass raw `width:` / `height:` to override:

```typst
config: (page: (paper: "us-letter"))                  // default
config: (page: (paper: "a4"))
config: (page: (width: 6in, height: auto))            // scroll mode (single tall page)
config: (page: (width: 25cm, height: 230cm))          // poster
```

`height: auto` produces a single growing page with no pagination; the running header is suppressed because it would render once on the single tall page.

## Fidelity: PDF vs HTML

Both outputs emit from one source via `_IS-HTML` dispatch in `src/lib.typ`. They are the same document but not pixel-identical:

- **Identical:** body content, sidenote/marginnote text + numbering, figure ordering, citations.
- **Different by design:** print PDF uses fixed page geometry (us-letter handout) and is paginated; HTML scrolls and wraps to viewport. PDF margin notes use marginalia; HTML uses tufte-css markup with a checkbox toggle.
- **Degraded in HTML:** see Limitations.

## Limitations

Upstream-blocked or shipped trade-offs, not bugs.

- **HTML math.** Typst HTML has no native MathML emit (tracking [typst/typst#5512](https://github.com/typst/typst/issues/5512)). Each `$...$` renders as inline SVG via `html.frame`. PDF math stays native. SVG glyphs use `currentColor` and follow surrounding text colour, but they are not selectable and lack MathML semantics.
- **Mobile sidenote toggle.** Typst's HTML emit does not preserve tufte-css's `label + input + span` adjacent-sibling pattern across paragraphs. Sidenotes render inline on small screens. Click-to-expand toggle is unimplemented.
- **Multi-paragraph sidenote / marginnote.** A sidenote or marginnote whose body spans multiple paragraphs emits `<p>` inside `<span class="sidenote">`, which browsers reparent out of the inline span. Cases under `tests/limitations/multi-paragraph-{sidenote,marginnote}/` reproduce the failure.
- **HTML CeTZ / drawables.** HTML target drops raw frames. Wrap canvases in `diagram(...)` to emit them as inline SVG.
- **HTML TOC.** Anchors are positional (`h-1`, `h-2`, ...), not semantic slugs.

## Repo layout

```
src/                  template engine + style registry
  lib.typ             public API + tufte()
  config.typ          default-config + merge-config
  pdf.typ             PDF target (marginalia handout)
  html.typ            HTML target (tufte-css)
  styles/             per-style configs (`tufte-original` is the pivot)
example/              demo doc (rendered in the live web app)
assets/fonts/         optional fonts (gitignored; run fetch.sh)
tests/                regression harness + local style gallery
web/                  public web app (gallery + WASM editor)
```

## Tests

`tests/cases/<feature>/<name>/case.typ` holds atomic single-feature snippets, one per directory. Each `case.typ` is body-only; the build script wraps it with the shared preamble (`#import "/src/lib.typ": *` plus `#show: tufte.with(style: "jialin")`) before compiling. Per-case overrides go in a `// !with: (...)` directive at the top of the file.

`tests/reproductions/<name>/` holds whole-document reproductions of real `.typ` files.

```bash
./tests/serve.sh                 # build everything, serve local gallery on :8765
./tests/check.sh                 # PNG (pixel-diff) + HTML (byte-equal) regression
./tests/check.sh --update        # copy live -> ref after intentional changes
```

The local gallery (`tests/gallery/`) renders `example/example.typ` through every registered style for side-by-side comparison; this is the local-dev counterpart to the public web app.

## Web app

```bash
./web/build.sh                   # build into web/_site/
./web/serve.sh                   # build + serve on http://localhost:8000
```

`web/_site/` is the GitHub Pages artifact (gitignored). Four views:

- **Scroll all styles** (default): horizontal-snap row of cards, ←/→ to page through styles, format toggle (HTML / PDF / PNG stack) shared across cards.
- **Side by side**: two independent panes, each with its own style + format dropdown — compare PDF-of-X vs HTML-of-Y in any combination.
- **Grid**: every style at once, PNG stack on the left, HTML iframe on the right.
- **Editor**: in-browser typst.ts editor. First compile downloads ~15 MB of WASM (cached after).

The editor and gallery share the same source bundle, so the styles you see in the gallery are the styles your edits compile against.

## Fonts

Bundled fonts live under `assets/fonts/` (gitignored). `./assets/fonts/fetch.sh` pulls Roboto Condensed, JetBrains Mono, and extra Inter weights from the npm `@fontsource` mirror. The script converts WOFF to TTF and renames Roboto Condensed to work around a Typst 0.14 family-grouping bug. Requires `uv` for the fonttools conversion.

ET Book, Palatino, Gill Sans come from the system. macOS ships Palatino and Gill Sans; on Linux, install `et-book` and a Gill Sans clone such as URW Gothic.

## References

- [Tufte-LaTeX](https://github.com/Tufte-LaTeX/tufte-latex), the handout class. Pivot for `tufte-original`.
- [Tufte CSS](https://github.com/edwardtufte/tufte-css), the HTML emit reference.
- [rstudio/tufte](https://github.com/rstudio/tufte), the envisioned variant. Pivot for `envision`.
- [marginalia](https://typst.app/universe/package/marginalia), the Typst margin-note primitive.
- [typst.ts](https://github.com/Myriad-Dreamin/typst.ts), the WASM compiler powering the live editor.

## License

MIT.
