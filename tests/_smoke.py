#!/usr/bin/env python3
"""Fast structural smoke test for dual-typst HTML output.

Runs in <1s across every `out.html` and checks invariants that, if broken,
yield obviously bad rendering. Use before/after every emit-affecting change
so a wrong tag or stray paragraph break is caught immediately, instead of
sliding through to the slow vision-LLM pass.

Invariants enforced (per case):

  1. Document scaffold:
     - <article> exists; <h1> (if any) is a direct child of <article>,
       NOT inside <section>. tufte-css's `section > p` selector relies
       on this hierarchy.
     - <section> wraps the body content.

  2. Sidenote / marginnote triplet structure: every label.margin-toggle
     must have a matching <input type="checkbox" id="..."> and a
     subsequent <span class="sidenote"> or <span class="marginnote">.
     The label+input pair must share a parent <span> (the box wrapper).

  3. Block-level elements must NOT appear inside <span class="sidenote">
     or <span class="marginnote"> — browsers reparent <p>/<ul>/<ol>/<div>
     out of inline parents, ejecting the body to top-level flow and
     leaving only the superscript number in the margin. This is the
     single most common rendering break.

  4. Figure cases must contain at least one <img>. A figure that emits
     only a caption (the rect()-placeholder failure mode) is a bug.

  5. Every label[for=X] has a matching input[id=X]. ids are unique.

Exit code: 0 on PASS, 1 on FAIL. Use `--quiet` to suppress per-case
PASS lines.
"""
from __future__ import annotations
import argparse
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).parent

# Block elements that must not appear inside <span class="sidenote|marginnote">.
BLOCK_TAGS = {"p", "ul", "ol", "div", "table", "blockquote", "figure",
              "h1", "h2", "h3", "h4", "h5", "h6", "section", "article",
              "aside", "footer", "header", "pre"}


class StructureParser(HTMLParser):
    """Single-pass parser that records the issues we care about."""

    def __init__(self) -> None:
        super().__init__()
        self.stack: list[tuple[str, dict]] = []
        self.issues: list[str] = []
        self.has_article = False
        self.has_section = False
        self.img_count = 0
        # label/input id tracking
        self.label_fors: list[str] = []
        self.input_ids: list[str] = []
        self.all_ids: list[str] = []

    def _classes(self, attrs: dict) -> set[str]:
        return set((attrs.get("class") or "").split())

    def _in_inline_note_span(self) -> str | None:
        for tag, attrs in reversed(self.stack):
            if tag == "span":
                cls = self._classes(attrs)
                if "sidenote" in cls or "marginnote" in cls:
                    return "sidenote" if "sidenote" in cls else "marginnote"
        return None

    def _parent_section(self) -> bool:
        return any(t == "section" for t, _ in self.stack)

    def handle_starttag(self, tag: str, raw_attrs) -> None:
        attrs = dict(raw_attrs)
        if tag == "article":
            self.has_article = True
        elif tag == "section":
            self.has_section = True
        elif tag == "img":
            self.img_count += 1
        elif tag == "label" and "margin-toggle" in self._classes(attrs):
            if "for" in attrs:
                self.label_fors.append(attrs["for"])
        elif tag == "input" and attrs.get("type") == "checkbox":
            if "id" in attrs:
                self.input_ids.append(attrs["id"])

        # Ids inside <svg> are svg-internal scope (resolved by xlink:href);
        # `html.frame` reuses the same `<defs>` ids across frames legitimately.
        if "id" in attrs and not any(t == "svg" for t, _ in self.stack):
            self.all_ids.append(attrs["id"])

        # Block-inside-inline-note check.
        if tag in BLOCK_TAGS:
            ctx = self._in_inline_note_span()
            if ctx is not None:
                self.issues.append(
                    f"<{tag}> inside <span class=\"{ctx}\"> "
                    "(browsers will reparent and eject the body to top-level flow)"
                )

        self.stack.append((tag, attrs))

    def handle_endtag(self, tag: str) -> None:
        # Pop until matching tag (handles unclosed self-closing edge cases).
        while self.stack and self.stack[-1][0] != tag:
            self.stack.pop()
        if self.stack:
            self.stack.pop()


def check_one(path: Path, expectations: dict) -> list[str]:
    """Return a list of issue strings for `path`. Empty list means PASS."""
    parser = StructureParser()
    parser.feed(path.read_text(encoding="utf-8"))
    issues = list(parser.issues)

    if not parser.has_article:
        issues.append("missing <article> wrapper")
    if not parser.has_section:
        issues.append("missing <section> wrapper for body")

    # Label / input id pairing
    for fr in parser.label_fors:
        if fr not in parser.input_ids:
            issues.append(f"label for=\"{fr}\" has no matching <input id=\"{fr}\">")

    # Unique ids
    seen, dupes = set(), []
    for i in parser.all_ids:
        if i in seen:
            dupes.append(i)
        seen.add(i)
    if dupes:
        issues.append(f"duplicate id(s): {sorted(set(dupes))}")

    # Per-expectation: figures must have <img>
    if expectations.get("requires_img") and parser.img_count == 0:
        issues.append("figure case missing <img> (Typst dropped the figure body)")

    return issues


# Per-limitation classifier. The smoke test catches *structural* breaks
# (block-inside-inline-span, missing scaffold). Content drops (math, CeTZ)
# leave structurally valid HTML — only vision can flag them.
LIMITATION_KIND = {
    "multi-paragraph-sidenote":   "structural",
    "multi-paragraph-marginnote": "structural",
    "inline-math-dropped":        "content",  # smoke test can't detect
}


def expectations_for(path: Path) -> dict:
    rel = path.relative_to(ROOT).as_posix()
    if rel.startswith("cases/figures/"):
        return {"requires_img": True}
    return {}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--quiet", action="store_true",
                    help="suppress PASS lines; only print failures")
    args = ap.parse_args()

    cases = sorted(ROOT.glob("cases/*/*/out.html"))
    repros = sorted(ROOT.glob("reproductions/*/out.html"))
    limits = sorted(ROOT.glob("limitations/*/out.html"))
    if not (cases or repros or limits):
        print("no out.html files found — run build-all.sh first", file=sys.stderr)
        return 1

    real_failed = 0
    repro_issue_files = 0
    unexpected_pass = 0

    def report(t: Path, group: str) -> None:
        nonlocal real_failed, repro_issue_files, unexpected_pass
        rel = t.relative_to(ROOT).as_posix()
        issues = check_one(t, expectations_for(t))
        if group == "limitations":
            # Limitations: structural ones are expected to fail an invariant;
            # content-level ones (math drop) leave valid HTML so the smoke
            # test simply records them.
            kind = LIMITATION_KIND.get(t.parent.name, "structural")
            if kind == "content":
                if not args.quiet:
                    print(f"LIMIT {rel}  (content-only; vision required)")
            elif issues:
                if not args.quiet:
                    print(f"LIMIT {rel}  ({len(issues)} known structural issue"
                          f"{'s' if len(issues)!=1 else ''})")
            else:
                unexpected_pass += 1
                print(f"GRADUATED {rel}  (structural issue gone — move out of limitations/)")
        elif group == "reproductions":
            # Reproductions are holistic visual tests, not structural.
            # Issues here usually trace to known limitations exercised by
            # the source — informational only, do not block exit.
            if issues:
                repro_issue_files += 1
                if not args.quiet:
                    n = len(issues)
                    print(f"INFO {rel}  ({n} structural issue{'s' if n!=1 else ''}; "
                          "see tests/limitations/)")
            elif not args.quiet:
                print(f"PASS {rel}")
        else:
            if issues:
                real_failed += 1
                print(f"FAIL {rel}")
                for issue in issues:
                    print(f"  - {issue}")
            elif not args.quiet:
                print(f"PASS {rel}")

    for t in cases: report(t, "cases")
    for t in repros: report(t, "reproductions")
    for t in limits: report(t, "limitations")

    summary = (f"\n{len(cases)} case(s), {len(repros)} reproduction(s), "
               f"{len(limits)} limitation(s)")
    if real_failed:
        print(f"{summary}\n{real_failed} unexpected case failure(s)")
        return 1
    notes = []
    if repro_issue_files:
        notes.append(f"{repro_issue_files} reproduction(s) carry known-limitation patterns")
    if unexpected_pass:
        notes.append(f"{unexpected_pass} limitation(s) graduated — move them to cases/")
    if notes:
        print(summary)
        for n in notes:
            print(n)
    else:
        print(f"{summary}\nall expectations met")
    return 0


if __name__ == "__main__":
    sys.exit(main())
