#!/usr/bin/env python3
"""Check the HTML structure of each case's out.html; exit 1 on any issue.

- <article> and <section> exist.
- No block element sits inside a sidenote or marginnote <span>.
- Each margin-toggle label has an <input> with the same id.
- Ids outside <svg> are unique.
- Figure cases contain an <img>.
"""
import sys
from html.parser import HTMLParser
from pathlib import Path

BLOCK_TAGS = {"p", "ul", "ol", "div", "table", "blockquote", "figure", "pre",
              "h1", "h2", "h3", "h4", "h5", "h6", "section", "article", "aside", "footer", "header"}


class Parser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack, self.issues, self.tags, self.fors, self.ids = [], [], set(), [], []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = (attrs.get("class") or "").split()
        self.tags.add(tag)
        if tag == "label" and "margin-toggle" in classes:
            self.fors.append(attrs.get("for"))
        if "id" in attrs and "svg" not in self.stack:
            self.ids.append(attrs["id"])
        if tag in BLOCK_TAGS and "span.note" in self.stack:
            self.issues.append(f"<{tag}> inside a note span")
        self.stack.append("span.note" if tag == "span" and {"sidenote", "marginnote"} & set(classes) else tag)

    def handle_endtag(self, tag):
        while self.stack and self.stack.pop().split(".")[0] != tag:
            pass


def issues(path):
    p = Parser()
    p.feed(path.read_text())
    out = p.issues
    out += [f"missing <{t}>" for t in ("article", "section") if t not in p.tags]
    out += [f'label for="{f}" has no input' for f in p.fors if f not in p.ids]
    out += [f'duplicate id "{i}"' for i in {i for i in p.ids if p.ids.count(i) > 1}]
    if "figures" in path.parts and "img" not in p.tags:
        out.append("figure case has no <img>")
    return out


failed = False
for path in sorted(Path(__file__).parent.glob("cases/*/*/out.html")):
    for issue in issues(path):
        failed = True
        print(f"FAIL {path.parent.relative_to(path.parents[3])}: {issue}")
sys.exit(failed)
