# dual-tufte-typst

Write a Tufte-style document once in [Typst](https://typst.app/). Get PDF and HTML from the same source. Same Typst source document, both outputs.

**[→ Live web app](https://luxxxlucy.github.io/dual-tufte-typst/)**.

## Install

Requires `git`, [Typst](https://github.com/typst/typst) >= 0.14, and [`uv`](https://github.com/astral-sh/uv) (for the font fetch step; pass `--no-fonts` to skip). One liner:

```bash
curl -fsSL https://raw.githubusercontent.com/LuxxxLucy/dual-tufte-typst/main/install.sh | bash
```

Or git clone it and then inside the clone repo:

```bash
./install.sh                                  # or: --bindir ~/bin --no-fonts
```


## Quickstart

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(title: [Document Title], author: "Your Name")

Content with #sidenote[a margin note].
```

See `example/example.typ` for full feature tour.
Build the `example/example/typ` from a clone:

```bash
typst compile --root . --font-path assets/fonts example/example.typ           # PDF
typst compile --root . --font-path assets/fonts \
    --features html --input target=html example/example.typ example.html      # HTML
```

### Create a new doc

Once `dual-typst` is on `$PATH` (see Install), scaffold a new doc anywhere:

```bash
dual-typst create ~/papers/my-doc
cd ~/papers/my-doc && ./build.sh                        # produces main.{pdf,html}
```

The created folder contains `main.typ`, `refs.bib`, an executable `build.sh`, and `src` / `assets` symlinks pointing into the dual-typst clone.

## API

`tufte()` is the entry point. Per-feature helpers come from the same module.

| Helper | Purpose |
|---|---|
| `sidenote(numbered: true, body)` | Numbered margin note with inline reference. |
| `marginnote(body)` | Unnumbered margin note. |
| `sidecite(key)` | Bibliography citation rendered as a numbered margin note. |
| `main-figure(content, caption)` | Figure and caption in the text column. |
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
| `head-extra` | `none` | HTML target only. Arbitrary content injected inside `<head>` (after `<title>`, before stylesheets) — `<meta>` tags, `<link>` relations, `<script>`s, preload hints, structured data, anything you need. Construct with `html.elem`. See Examples. |

CLI inputs read at compile time:

| Input | Effect |
|---|---|
| `--input target=html` | Switch to the HTML target (use with `--features html`). |
| `--input style=<name>` | Override the style without editing the source. |
| `--input color-scheme=light` | Force light mode in the HTML `<meta name="color-scheme">` (defaults to per-style). |

### More Examples

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

Inject arbitrary content into the HTML `<head>` (HTML target only — ignored for PDF). Use this for any `<head>`-level content the template doesn't emit on its own: descriptive metadata, social-card tags, canonical links, preload hints, third-party scripts, structured data, etc.

```typst
#show: tufte.with(
  title: [Your Post Title],
  head-extra: [
    #html.elem("meta", attrs: (
      ("name"): "description",
      ("content"): "One-sentence summary of the post."
    ))[]
    #html.elem("link", attrs: (
      ("rel"): "canonical",
      ("href"): "https://example.com/your-post/"
    ))[]
    #html.elem("link", attrs: (
      ("rel"): "preload",
      ("as"): "font",
      ("href"): "/fonts/etbembo.woff2",
      ("crossorigin"): "anonymous"
    ))[]
    #html.elem("script", attrs: (("type"): "application/ld+json"))[#"{\"@context\":\"https://schema.org\",\"@type\":\"BlogPosting\",\"headline\":\"Your Post Title\"}"]
  ],
)
```

## Styles

Different styles are provided. Pick a style by name:

```typst
#show: tufte.with(title: [...], style: "envision")
```

| Style | Mirrors |
|---|---|
| `tufte-original` | tufte-LaTeX `tufte-handout` class |
| `envision` | rstudio/tufte's envisioned variant |
| `jialin` | web-handout look (Gill Sans title, 9pt body) |
| `terpret` | tufte-css with web paragraphing |
| `orange-happy` | warm cream + orange accent, sans aesthetic (Inter) |
| `bluewhite` | minimal white + blue link, sans aesthetic (Inter) |


## Customization

Override the style's HTML stylesheet for a single document:

```typst
#show: tufte.with(
    title: [...],
    style: "tufte-original",
    html-css: ("https://my-cdn.example/custom-tufte.css",),
)
```

or override any default config:

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

The usual Typse page setup still holds up.
`config.page` mirrors Typst's native `set page(...)` arguments. Use `paper:` for named sizes, or pass raw `width:` / `height:` to override:

```typst
config: (page: (paper: "us-letter"))                  // default
config: (page: (paper: "a4"))
config: (page: (width: 6in, height: auto))            // scroll mode (single tall page)
config: (page: (width: 25cm, height: 230cm))          // poster
```

`height: auto` produces a single growing page with no pagination; the running header is suppressed because it would render once on the single tall page.


## Limitations

- **HTML math.** Typst HTML has no native MathML emit (tracking [typst/typst#5512](https://github.com/typst/typst/issues/5512)). Each `$...$` renders as inline SVG via `html.frame`. PDF math stays native. SVG glyphs use `currentColor` and follow surrounding text colour, but they are not selectable and lack MathML semantics.
- **Mobile sidenote toggle.** Typst's HTML emit does not preserve tufte-css's `label + input + span` adjacent-sibling pattern across paragraphs. Sidenotes render inline on small screens. Click-to-expand toggle is unimplemented.
- **Multi-paragraph sidenote / marginnote.** A sidenote or marginnote whose body spans multiple paragraphs emits `<p>` inside `<span class="sidenote">`, which browsers reparent out of the inline span. Cases under `tests/limitations/multi-paragraph-{sidenote,marginnote}/` reproduce the failure.
- **HTML CeTZ / drawables.** HTML target drops raw frames. Wrap canvases in `diagram(...)` to emit them as inline SVG.
- **HTML TOC.** Anchors are positional (`h-1`, `h-2`, ...), not semantic slugs.

## Develop and test

### Repo layout

```
src/                  template engine + style registry
  lib.typ             public API + tufte()
  config.typ          default-config + merge-config
  pdf.typ             PDF target (marginalia handout)
  html.typ            HTML target (tufte-css)
  styles/             per-style configs (`tufte-original` is the pivot)
bin/dual-typst        create-doc CLI
install.sh            one-liner installer (clone + fonts + PATH symlink)
example/              demo doc (rendered in the live web app)
assets/fonts/         optional fonts (gitignored; run fetch.sh)
tests/                regression harness + local style gallery
web/                  public web app (gallery)
```

### Tests

`tests/cases/<feature>/<name>/case.typ` holds atomic single-feature snippets, one per directory. Each `case.typ` is body-only; the build script wraps it with the shared preamble (`#import "/src/lib.typ": *` plus `#show: tufte.with(style: "jialin")`) before compiling. Per-case overrides go in a `// !with: (...)` directive at the top of the file.

`tests/reproductions/<name>/` holds whole-document reproductions of real `.typ` files.

```bash
./tests/serve.sh                 # build everything, serve local gallery on :8765
./tests/check.sh                 # PNG (pixel-diff) + HTML (byte-equal) regression
./tests/check.sh --update        # copy live -> ref after intentional changes
```

The local gallery (`tests/gallery/`) renders `example/example.typ` through every registered style for side-by-side comparison; this is the local-dev counterpart to the public web app.

## Fonts

Bundled fonts live under `assets/fonts/` (gitignored). `./assets/fonts/fetch.sh` pulls the used fonts. Requires `uv` for the fonttools conversion.

## References

- [Tufte-LaTeX](https://github.com/Tufte-LaTeX/tufte-latex), the handout class. Pivot for `tufte-original`.
- [Tufte CSS](https://github.com/edwardtufte/tufte-css), the HTML emit reference.
- [rstudio/tufte](https://github.com/rstudio/tufte), the envisioned variant. Pivot for `envision`.
- [marginalia](https://typst.app/universe/package/marginalia), the Typst margin-note primitive.

## License

MIT.
