# Dual-Tufte-Typst

A Typst template for Edward Tufte's design principles with dual-format output: PDF and HTML from a single source.

## Quick Start

Basic usage:

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(title: [Document Title], author: "Author Name")

Content with #sidenote[margin notes].
```

With common parameters:

```typst
#import "src/lib.typ": tufte, sidenote

#show: tufte.with(
  title: [Document Title],
  author: "Author Name",
  date: datetime.today(),                    // Publication date
  abstract: [Brief document summary...],     // Optional abstract
  lang: "en",                                // Document language
  paper: "us-letter",                        // Paper size for PDF
)

Content with #sidenote[margin notes].
```

Compile:

```bash
typst compile document.typ                                            # PDF
typst compile --input target=html --features html document.typ out.html  # HTML
```

See `example/example.typ` and `tests/test.typ` for complete usage.

## Features

Sidenotes, margin notes, margin figures, full-width figures, epigraphs, new-thought openers, side citations (`sidecite`), abstract, and table of contents. Footnotes convert to sidenotes automatically.

## Template Parameters

The `tufte.with()` function accepts:
- `title`: Document title
- `author`: Author name
- `date`: Publication date (e.g., `datetime.today()`)
- `abstract`: Brief document summary (optional)
- `toc`: Enable table of contents (default: `false`; HTML: placeholder only)
- `lang`: Document language (default: `"en"`)
- `paper`: Paper size for PDF (default: `"us-letter"`)
- Font customization: `body-font`, `sans-font`, `mono-font`

## Limitations

- **HTML**: Experimental. Math ignored, TOC placeholder only, mobile sidenote toggle not supported (requires CSS amendments).
- **PDF**: Minor style differences from canonical Tufte-LaTeX; some fine-tuning expected.

## Font

Install [ET Book](https://github.com/edwardtufte/et-book) for authentic Tufte typography. Falls back to Palatino/Georgia if unavailable.

## Test

```bash
./test.sh            # compare against reference files
./test.sh --generate # regenerate reference files
```

## Font Setup

Install [ET Book](https://github.com/edwardtufte/et-book) for authentic Tufte typography. Falls back to Palatino/Georgia if unavailable.

## References

**Tufte handout:**
- [Tufte-LaTeX](https://github.com/Tufte-LaTeX/tufte-latex)
- [Tufte CSS](https://github.com/edwardtufte/tufte-css)
- [ET Book font](https://github.com/edwardtufte/et-book)

**Typst Tufte templates for PDF:**
- [tufte-memo](https://github.com/nogula/tufte-memo)
- [tufte-typst](https://github.com/fredguth/tufte-typst)
- [toffee-tufte](https://codeberg.org/jianweicheong/toffee-tufte)
- [bookly](https://github.com/maucejo/bookly)

**Typst Tufte templates for HTML:**
- [tufted](https://github.com/vsheg/tufted)
- [Tufted-Blog-Template](https://github.com/Yousa-Mirage/Tufted-Blog-Template)

## License

MIT
