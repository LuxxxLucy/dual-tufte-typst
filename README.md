# Dual-Tufte-Typst

Tufte-style documents in Typst.
One source compiles to PDF (marginalia handout) and HTML (tufte-css).

## Quick start

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(
    title: [Document Title],
    author: "Author Name",
    style: "tufte-original",
)

Content with #sidenote[margin notes].
```

```bash
typst compile --root . --font-path assets/fonts document.typ
typst compile --root . --font-path assets/fonts \
    --features html --input target=html document.typ out.html
```

See `example/example.typ`.
The rendered example ships at <https://luxxxlucy.github.io/dual-tufte-typst/> via the build workflow.

## Styles

Two ready styles, both calibrated against authoritative sources:

| Style | Mirrors | Status |
|---|---|---|
| `tufte-original` | tufte-LaTeX `tufte-handout` class (`.refs/style-research/tufte-common.def`) | ready |
| `envision`       | rstudio/tufte's envisioned variant (<https://rstudio.github.io/tufte/envisioned/>) | ready |

`jialin`, `terpret`, `claude-tufte`, `openai-tufte` are work-in-progress experiments — they layer on top of `tufte-original` but haven't been calibrated yet.

Per-style HTML CSS isn't wired in yet (the HTML target always emits canonical tufte-css). PDF rendering varies by style.

Pass the style by name:

```typst
#show: tufte.with(title: [...], style: "envision")
```

Or pass an inline override:

```typst
#show: tufte.with(
    title: [...],
    config: (
        page: (margin-x: 1in),
        sizes: (body: 9pt),
    ),
)
```

## Repo layout

```
src/                  template engine + style registry
  lib.typ             public API + tufte()
  config.typ          default-config + merge-config
  pdf.typ             PDF target (marginalia handout)
  html.typ            HTML target (tufte-css)
  styles/             per-style configs (tufte-original is the pivot)
example/              demo doc + GH Pages source
assets/fonts/         optional fonts (gitignored; run fetch.sh)
tests/                regression harness + style gallery
```

## Fonts

Bundled fonts live under `assets/fonts/` (gitignored). Run the fetch script once to populate:

```bash
./assets/fonts/fetch.sh
```

Pulls Roboto Condensed, JetBrains Mono, and extra Inter weights from the npm `@fontsource` mirror, converts WOFF→TTF, and renames Roboto Condensed in place to bypass a Typst 0.14 family-grouping quirk. Requires `uv` (for the fonttools conversion).

ET Book / Palatino / Gill Sans are expected from the system. macOS ships Palatino + Gill Sans; on Linux, install `et-book` + a Gill Sans clone (e.g. URW Gothic).

## Tests

`tests/cases/<feature>/<name>/case.typ` holds atomic single-feature snippets, one case per directory.

`tests/reproductions/<name>/` holds whole-document reproductions of real `.typ` files, each with a `source` symlink and a `build.sh` that sed-patches imports so the original compiles through this template unchanged.

```bash
./tests/serve.sh                 # build everything + serve on :8765
./tests/check.sh                 # verify PNG (pixel-diff) + HTML (byte-equal) refs
./tests/check.sh --update        # copy live → ref after intentional changes
```

The gallery (`tests/gallery/`) renders `example/example.typ` through every registered style for visual side-by-side comparison.

## References

- [Tufte-LaTeX](https://github.com/Tufte-LaTeX/tufte-latex) — handout class, ground truth for `tufte-original`.
- [Tufte CSS](https://github.com/edwardtufte/tufte-css) — HTML emit reference.
- [rstudio/tufte](https://github.com/rstudio/tufte) — envisioned variant, ground truth for `envision`.
- [marginalia](https://typst.app/universe/package/marginalia) — Typst margin-note primitives.

## License

MIT.
