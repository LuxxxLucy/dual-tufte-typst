#!/usr/bin/env python3
"""Generate tests/gallery/index.html — one row per style.

Each row shows the per-page PNG stack of example/example.typ rendered
through that style alongside the live HTML output (in an iframe). PDF
+ HTML download links in the row header.
"""
from __future__ import annotations
import html
from pathlib import Path

ROOT = Path(__file__).parent

# Pinned baselines first — `tufte-original` mirrors tufte-LaTeX,
# `envision` mirrors rstudio/tufte's envisioned variant. They are the
# typographic ground truths every other style derives from; surfacing
# them at the top of the gallery makes drift in the others obvious.
_PINNED = ("tufte-original", "envision")
_ALL = [d.name for d in ROOT.iterdir() if d.is_dir() and (d / "out.pdf").exists()]
STYLES = (
    [s for s in _PINNED if s in _ALL]
    + sorted(s for s in _ALL if s not in _PINNED)
)


def png_stack(d: Path) -> str:
    pngs = sorted(d.glob("out-[0-9]*.png"))
    if not pngs:
        return '<div class="missing">no png</div>'
    return "".join(
        f'<a href="{html.escape(str(p.relative_to(ROOT)))}">'
        f'<img src="{html.escape(str(p.relative_to(ROOT)))}" loading="lazy"></a>'
        for p in pngs
    )


def html_pane(d: Path, style: str) -> str:
    h = d / "out.html"
    if not h.exists():
        return '<div class="missing">no html</div>'
    src = html.escape(f"{style}/out.html")
    return f'<iframe src="{src}" loading="lazy"></iframe>'


def row(style: str) -> str:
    d = ROOT / style
    pdf = d / "out.pdf"
    htmlf = d / "out.html"
    links = []
    if pdf.exists():
        links.append(f'<a href="{style}/out.pdf">pdf</a>')
    if htmlf.exists():
        links.append(f'<a href="{style}/out.html">html</a>')
    links_html = " ".join(links)
    return f"""
<details class="style" open>
  <summary>
    <span class="label">{html.escape(style)}</span>
    <span class="links">{links_html}</span>
  </summary>
  <div class="panes">
    <div class="pane png-stack">{png_stack(d)}</div>
    <div class="pane html-frame">{html_pane(d, style)}</div>
  </div>
</details>"""


PAGE = """<!doctype html>
<meta charset=utf-8>
<title>dual-tufte-typst — style gallery</title>
<style>
  body {{ font: 14px/1.5 system-ui, sans-serif; max-width: 100rem; margin: 1.5rem auto;
          padding: 0 1rem; color: #222; }}
  h1 {{ font-weight: 300; margin-bottom: 0.2rem; }}
  h1 small {{ color: #888; font-size: 0.6em; }}
  p.lede {{ color: #666; margin-top: 0.2rem; }}
  .controls {{ position: sticky; top: 0; background: #fff; padding: 0.5rem 0;
               border-bottom: 1px solid #eee; z-index: 10; }}
  .controls button {{ font: 13px system-ui; padding: 0.3rem 0.8rem; margin-right: 0.5rem;
                       cursor: pointer; background: #f5f5f5; border: 1px solid #ccc; border-radius: 4px; }}
  .style {{ border: 1px solid #ddd; border-radius: 6px; margin: 0.8rem 0; background: #fafafa; }}
  .style > summary {{ list-style: none; cursor: pointer; padding: 0.6rem 0.9rem;
                       display: flex; gap: 1rem; align-items: center; user-select: none; }}
  .style > summary::-webkit-details-marker {{ display: none; }}
  .style > summary::before {{ content: "▶"; font-size: 0.7em; color: #888; }}
  .style[open] > summary::before {{ content: "▼"; }}
  .style .label {{ font-family: ui-monospace, Menlo, monospace; font-size: 14px; color: #111; }}
  .style .links {{ margin-left: auto; font-size: 12px; }}
  .style .links a {{ color: #06c; text-decoration: none; margin-left: 0.5rem; }}
  .panes {{ display: grid; grid-template-columns: 1fr 1fr; gap: 0.6rem;
            margin: 0 0.9rem 0.9rem; }}
  .pane {{ border: 1px solid #e3e3e3; background: white; overflow: auto;
           height: 80rem; }}
  .pane.png-stack img {{ display: block; width: 100%; height: auto; }}
  .pane.png-stack img + img {{ border-top: 1px dashed #eee; }}
  .pane.html-frame iframe {{ width: 100%; height: 100%; border: 0; display: block; }}
  .missing {{ display: flex; align-items: center; justify-content: center;
              color: #aaa; font-style: italic; min-height: 8rem; }}
</style>

<h1>dual-tufte-typst <small>— style gallery</small></h1>
<p class="lede">Same source (<code>example/example.typ</code>) rendered through
every registered style. Each row shows the PDF (per-page PNG stack, left)
and the HTML output (live iframe, right). PDF + HTML download links in
the row header.</p>

<div class="controls">
  <button onclick="setAll(true)">Expand all</button>
  <button onclick="setAll(false)">Collapse all</button>
</div>

{rows}

<script>
function setAll(open) {{
  document.querySelectorAll('details.style').forEach(d => {{ d.open = open; }});
}}
</script>
"""


def main() -> None:
    print(PAGE.format(rows="".join(row(s) for s in STYLES)))


if __name__ == "__main__":
    main()
