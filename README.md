# dual-tufte-typst

Write a Tufte-style document once in [Typst](https://typst.app/) and get both PDF and HTML from the same source.

**[→ Live web app](https://luxxxlucy.github.io/dual-tufte-typst/)**

## Install

Requires `git`, [Typst](https://github.com/typst/typst) >= 0.14, and [`uv`](https://github.com/astral-sh/uv) for the font fetch.

```bash
curl -fsSL https://raw.githubusercontent.com/LuxxxLucy/dual-tufte-typst/main/install.sh | bash
```

Or run it from a clone:

```bash
./install.sh                                  # or: --bindir ~/bin --no-fonts
```

## Quickstart

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(title: [Document Title], author: "Your Name")

Content with #sidenote[a margin note].
```

`example/example.typ` shows every feature. Build it from a clone:

```bash
typst compile --root . --font-path assets/fonts example/example.typ                      # PDF
typst compile --root . --font-path assets/fonts --features html example/example.typ out.html  # HTML
```

The output format follows the output file: `.html` with `--features html` gives HTML, anything else gives PDF.

### Create a new doc

With `dual-typst` on `$PATH` (see Install):

```bash
dual-typst create ~/papers/my-doc
cd ~/papers/my-doc && ./build.sh              # builds main.pdf and main.html
```

The folder holds `main.typ`, `refs.bib`, `build.sh`, and `src` and `assets` symlinks into the clone.

## API

`tufte()` is the entry point. The helpers come from the same module.

| Helper | Purpose |
|---|---|
| `sidenote(body, numbered: true)` | Numbered margin note. |
| `marginnote(body)` | Margin note without a number. |
| `sidecite(key)` | Citation as a numbered margin note. |
| `margin-figure(content, caption: ..)` | Figure in the margin. |
| `full-width(body)` | Block across the text and the margin, e.g. `full-width(figure(..))`. |
| `epigraph(quote, author: ..)` | Quotation that opens a section. |
| `new-thought(body)` | Small caps that open a paragraph. |
| `diagram(body)` | CeTZ canvas or other drawing; inline SVG in HTML. |

The margin helpers also take `dy:` to move the note vertically.

`tufte.with(...)` parameters:

| Parameter | Default | Meaning |
|---|---|---|
| `title` | `none` | Document title. |
| `author`, `email`, `date` | `none` | Byline. `date` is a `datetime` or content. |
| `abstract` | `none` | Italic abstract under the title. |
| `toc` | `false` | Table of contents. |
| `lang` | `"en"` | Document language. |
| `style` | `"tufte-original"` | Style name (see Styles). |
| `config` | `auto` | Overrides of style fields (see Customization). |

### Examples

A CeTZ figure for both outputs:

```typst
#import "@preview/cetz:0.4.2"
#import "src/lib.typ": tufte, diagram

#show: tufte.with(title: [...])

#figure(
  diagram(cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: 1)
    line((-1.2, 0), (1.2, 0))
  })),
  caption: [Unit circle.],
)
```

A citation in the margin:

```typst
#show: tufte.with(title: [...])

The result was first reported in #sidecite(<smith2024>) and later refined.

#bibliography("refs.bib")
```

## Styles

Pick a style by name:

```typst
#show: tufte.with(title: [...], style: "envision")
```

| Style | Look |
|---|---|
| `tufte-original` | Tufte-LaTeX `tufte-handout` class |
| `envision` | rstudio/tufte's envisioned variant |
| `jialin` | Compact personal handout |
| `terpret` | Plain technical (Inter, Space Grotesk, JetBrains Mono) |
| `orange-happy` | Warm cream and orange (Source Serif, Public Sans, Newsreader) |
| `bluewhite` | White and blue ML blog (Inter) |
| `rosa` | Inspired by [David Álvarez Rosa's site](https://david.alvarezrosa.com/) (Alegreya, Inconsolata). Very neat. |

## Customization

Each style is one data file in `src/styles/` with its fonts, sizes, colours and web CSS, for print and web.
Override any field with `config:`:

```typst
#show: tufte.with(
    title: [...],
    config: (
        page: (margin-x: 1in),
        colors: (link: "#003366"),
        typography: (print: (body: (size: 9pt, line: 13pt))),
        html: (color-scheme: "light", css: ("https://my-cdn.example/custom-tufte.css",)),
    ),
)
```

### Page geometry

`config.page` takes the arguments of Typst's `set page(...)`:

```typst
config: (page: (paper: "us-letter"))                  // default
config: (page: (paper: "a4"))
config: (page: (width: 6in, height: auto))            // one long page
config: (page: (width: 25cm, height: 230cm))          // poster
```

With `height: auto` the document is one long page without a running header.

## Limitations

- **HTML math.** Typst HTML has no MathML output ([typst/typst#5512](https://github.com/typst/typst/issues/5512)). Each equation is an inline SVG, so its text cannot be selected.
- **Blocks in HTML notes.** Figures, code blocks and display math do not work in HTML margin notes. PDF notes are fine.
- **HTML drawings.** HTML output drops drawn frames. Wrap them in `diagram(...)`.
- **HTML TOC.** Heading anchors are numbered (`h-1`, `h-2`, ...), not named.

## Develop and test

### Repo layout

```
src/
  lib.typ             public API and tufte()
  pdf.typ             PDF output (marginalia)
  html.typ            HTML output (tufte-css)
  styles/             one data file per style
bin/dual-typst        create-doc command
install.sh            installer (clone, fonts, PATH symlink)
example/              demo document of the web app
assets/fonts/         fetched fonts (gitignored)
tests/                regression tests
web/                  web app
```

### Tests

`tests/cases/<feature>/<name>/case.typ` holds one small test in the `tufte-original` style.
`tests/run.sh` builds each case with only the fetched fonts, checks the HTML structure, and compares the PNG of the first page with `tests/refs/`.

```bash
./tests/run.sh                   # fail on any difference
./tests/run.sh --update          # save the PNGs as the new refs
./web/serve.sh                   # web app with every style on :8000
```

## Fonts

`./assets/fonts/fetch.sh` downloads the fonts into `assets/fonts/` (gitignored). It needs `uv`.

## References

- [Tufte-LaTeX](https://github.com/Tufte-LaTeX/tufte-latex), the base of `tufte-original`.
- [Tufte CSS](https://github.com/edwardtufte/tufte-css), the base of the HTML output.
- [rstudio/tufte](https://github.com/rstudio/tufte), the base of `envision`.
- [marginalia](https://typst.app/universe/package/marginalia), the Typst margin-note package.

## License

MIT.
