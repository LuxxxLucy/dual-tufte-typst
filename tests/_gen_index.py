#!/usr/bin/env python3
"""Generate tests/index.html — collapsible per-case rows.

Each row expands to:
  - HTML row: live iframe | ref iframe
  - Visual row:
      cases         live PNG | ref PNG
      reproductions live PDF | ref PDF (original handout, pinned)

Cases are atomic and pixel-diff gated against PNG refs. Reproductions are
holistic and compared as PDF-vs-PDF (the original document compiled through
its own handout package is the reference); per-page PNG strips are not used.
"""
from __future__ import annotations
import html
from pathlib import Path

ROOT = Path(__file__).parent
REFS = ROOT / "refs"


def opt(p: Path) -> Path | None:
    return p.relative_to(ROOT) if p.exists() else None


def collect(group: str) -> list[dict]:
    base = ROOT / group
    if not base.exists():
        return []
    src_name = "_main.typ" if group == "reproductions" else "case.typ"
    # Cases & limitations enter via case.typ; reproductions via build.sh.
    entries = sorted(base.rglob("case.typ")) + sorted(base.glob("*/build.sh"))
    rows = []
    for entry in entries:
        d = entry.parent
        ref_dir = REFS / group / d.relative_to(base)
        live_pngs = sorted(d.glob("out.png")) + sorted(d.glob("out-[0-9]*.png"))
        diff_txt = d / "diff.txt"
        diff_stats = diff_txt.read_text().strip() if diff_txt.exists() else ""
        rows.append({
            "label": str(d.relative_to(base)),
            "rel": d.relative_to(ROOT),
            "src_name": src_name,
            "live_html": opt(d / "out.html"),
            "ref_html": opt(ref_dir / "out.html"),
            "live_pdf": opt(d / "out.pdf"),
            "ref_pdf": opt(ref_dir / "out.pdf"),
            "live_pngs": [p.relative_to(ROOT) for p in live_pngs],
            "ref_pngs": [opt(ref_dir / p.name) for p in live_pngs],
            "diff": opt(d / "diff.png"),
            "diff_stats": diff_stats,
        })
    return rows


MISSING = '<div class="missing">no ref</div>'


def iframe_pane(src: Path | None) -> str:
    if src is None:
        return MISSING
    return f'<iframe src="{html.escape(str(src))}" loading="lazy"></iframe>'


def img_pane(src: Path) -> str:
    s = html.escape(str(src))
    return f'<a href="{s}"><img src="{s}" loading="lazy"></a>'


def png_column(pngs: list) -> str:
    if not pngs:
        return MISSING
    return "".join(img_pane(p) for p in pngs)


def render_row(r: dict) -> str:
    diff_badge = (
        f' <a class="badge bad" href="{html.escape(str(r["diff"]))}">DIFF</a>'
        if r["diff"] else ""
    )
    if r["live_pdf"]:
        pdf_s = html.escape(str(r["live_pdf"]))
        pdf_link = f'<a href="{pdf_s}">pdf</a>'
        live_visual = f'<div class="pane pdf"><iframe src="{pdf_s}" loading="lazy"></iframe></div>'
        if r["ref_pdf"]:
            ref_s = html.escape(str(r["ref_pdf"]))
            ref_visual = f'<div class="pane pdf"><iframe src="{ref_s}" loading="lazy"></iframe></div>'
        else:
            ref_visual = f'<div class="pane">{MISSING}</div>'
        visual_label = "pdf"
    else:
        pdf_link = ""
        live_visual = f'<div class="pane png-stack">{png_column(r["live_pngs"])}</div>'
        ref_visual = f'<div class="pane png-stack">{png_column(r["ref_pngs"])}</div>'
        visual_label = "png"
    if r["diff"]:
        stats_label = (
            f' <span class="diff-stats">{html.escape(r["diff_stats"])}</span>'
            if r["diff_stats"] else ""
        )
        # The composite is a 3-column image (ref | live | 8×-amplified).
        # Caption above the image labels each panel so the reader doesn't
        # have to guess which is which.
        diff_row = f"""
    <div class="row-label">diff</div>
    <div class="pane diff-row">
      <div class="diff-cap"><span>ref</span><span>live</span><span>8×&nbsp;diff</span>{stats_label}</div>
      {img_pane(r["diff"])}
    </div>"""
    else:
        diff_row = ""
    return f"""
<details class="case"{' open' if r['diff'] else ''}>
  <summary>
    <span class="label">{html.escape(r["label"])}</span>
    <span class="links">
      <a href="{html.escape(str(r["rel"]))}/{r["src_name"]}">{r["src_name"]}</a>
      {pdf_link}
    </span>{diff_badge}
  </summary>
  <div class="grid">
    <div></div>
    <div class="col-label">live</div>
    <div class="col-label">ref</div>

    <div class="row-label">html</div>
    <div class="pane html">{iframe_pane(r["live_html"])}</div>
    <div class="pane html">{iframe_pane(r["ref_html"])}</div>

    <div class="row-label">{visual_label}</div>
    {live_visual}
    {ref_visual}{diff_row}
  </div>
</details>"""


def section(title: str, rows: list[dict]) -> str:
    if not rows:
        return f"<section><h2>{html.escape(title)}</h2><p><i>(none built)</i></p></section>"
    return f"""
<section>
  <h2>{html.escape(title)} <small>({len(rows)})</small></h2>
  {''.join(render_row(r) for r in rows)}
</section>"""


PAGE = """<!doctype html>
<meta charset=utf-8>
<title>dual-tufte-typst — test index</title>
<style>
  body {{ font: 14px/1.5 system-ui, sans-serif; max-width: 100rem; margin: 1.5rem auto; padding: 0 1rem; color: #222; }}
  h1 {{ font-weight: 300; margin-bottom: 0.2rem; }}
  h1 small {{ color: #888; font-size: 0.6em; }}
  h2 {{ font-weight: 400; margin-top: 2rem; border-bottom: 1px solid #ddd; padding-bottom: 0.3rem; }}
  h2 small {{ color: #888; font-weight: 300; }}
  .controls {{ position: sticky; top: 0; background: #fff; padding: 0.5rem 0;
               border-bottom: 1px solid #eee; z-index: 10; }}
  .controls button {{ font: 13px system-ui; padding: 0.3rem 0.8rem; margin-right: 0.5rem;
                       cursor: pointer; background: #f5f5f5; border: 1px solid #ccc; border-radius: 4px; }}
  .case {{ border: 1px solid #ddd; border-radius: 6px; margin: 0.5rem 0; background: #fafafa; }}
  .case > summary {{ list-style: none; cursor: pointer; padding: 0.6rem 0.9rem;
                      display: flex; gap: 1rem; align-items: center; user-select: none; }}
  .case > summary::-webkit-details-marker {{ display: none; }}
  .case > summary::before {{ content: "▶"; font-size: 0.7em; color: #888; }}
  .case[open] > summary::before {{ content: "▼"; }}
  .case .label {{ font-family: ui-monospace, Menlo, monospace; font-size: 13px; color: #333; }}
  .case .links {{ margin-left: auto; display: flex; gap: 0.7rem; font-size: 12px; }}
  .case .links a {{ color: #06c; text-decoration: none; }}
  .case .links a:hover {{ text-decoration: underline; }}
  .badge {{ font-size: 11px; padding: 0.1rem 0.4rem; border-radius: 3px; text-decoration: none;
            font-family: ui-monospace, Menlo, monospace; }}
  .badge.bad {{ background: #fee; color: #c00; border: 1px solid #fcc; }}
  .grid {{ display: grid; grid-template-columns: 5rem 1fr 1fr; gap: 0.5rem;
           padding: 0 0.9rem 0.9rem; align-items: stretch; }}
  .col-label {{ font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 0.05em;
                border-bottom: 1px solid #eee; padding-bottom: 0.2rem; }}
  .row-label {{ font-size: 11px; color: #888; align-self: center; text-align: right;
                font-family: ui-monospace, Menlo, monospace; }}
  .pane {{ border: 1px solid #e3e3e3; background: white; overflow: hidden; }}
  .pane iframe {{ width: 100%; border: 0; }}
  /* tufte-css hides .sidenote/.marginnote below 760px viewport. Force the
     HTML iframe wider than that and let the pane scroll horizontally so
     the margin column actually renders in the test index. */
  .pane.html {{ overflow-x: auto; }}
  .pane.html iframe {{ width: 900px; min-width: 100%; height: 32rem; }}
  .pane.pdf iframe {{ height: 36rem; }}
  .pane img {{ display: block; width: 100%; height: auto; }}
  .png-stack {{ overflow-y: auto; max-height: 36rem; }}
  .png-stack img + img {{ border-top: 1px dashed #eee; }}
  .diff-row {{ grid-column: 2 / span 2; padding: 0.4rem; background: #fff5f5; border: 1px solid #fcc; }}
  .diff-row img {{ width: 100%; height: auto; }}
  .diff-cap {{ display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 4px;
               font-size: 11px; color: #666; font-family: ui-monospace, Menlo, monospace;
               padding-bottom: 0.3rem; text-align: center; position: relative; }}
  .diff-cap > span {{ background: #f0f0f0; padding: 0.15rem 0.3rem; border-radius: 3px; }}
  .diff-stats {{ position: absolute; right: 0; top: 0; background: #fee !important;
                  color: #c00; font-size: 11px; padding: 0.15rem 0.4rem; }}
  details.case:has(.diff-row) {{ border-color: #fcc; background: #fff8f8; }}
  .missing {{ display: flex; align-items: center; justify-content: center;
              color: #aaa; font-style: italic; min-height: 8rem; }}
</style>

<h1>dual-tufte-typst <small>— test index</small></h1>
<p>Each row expands to live vs. reference. PNG refs are pixel-diff gated;
   PDFs ship as artifacts but aren't gated (timestamps, font subsets).
   Style gallery (same source through every registered style):
   <a href="gallery/index.html">gallery/index.html</a>.</p>

<div class="controls">
  <button onclick="setAll(true)">Expand all</button>
  <button onclick="setAll(false)">Collapse all</button>
</div>

{cases_section}
{repros_section}
{limits_section}

<script>
function setAll(open) {{
  document.querySelectorAll('details.case').forEach(d => {{ d.open = open; }});
}}
</script>
"""


def main() -> None:
    cases = collect("cases")
    repros = collect("reproductions")
    limits = collect("limitations")
    print(PAGE.format(
        cases_section=section("Cases", cases),
        repros_section=section("Reproductions", repros),
        limits_section=section("Limitations (documented broken patterns)", limits),
    ))


if __name__ == "__main__":
    main()
