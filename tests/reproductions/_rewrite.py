#!/usr/bin/env python3
"""Rewrite a reproduction's `source/<entry>.typ` so it compiles through
the dual template instead of its bundled handout package.

Each reproduction lives at tests/reproductions/<name>/. Its `source/` is
a symlink to the original document tree. We do not edit the upstream
source; we emit a patched `_main.typ` next to it that:
    - swaps the handout import for src/tufte-handout-compat.typ
    - rewrites asset / bibliography paths so they resolve from the
      reproduction directory (which sees the source tree under `source/`)
"""
from __future__ import annotations
import sys
from pathlib import Path

# (pattern, replacement), applied in order; plain string replace.
_RULES: tuple[tuple[str, str], ...] = (
    # Handout import → dual template's compat shim.
    ('#import "tufte-handout.typ"',
     '#import "../../../src/tufte-handout-compat.typ"'),
    # Asset paths: rewrite both `./asset/` and `asset/` forms for image()/read().
    ('image("./asset/', 'image("./source/asset/'),
    ('image("asset/',   'image("source/asset/'),
    ('read("./asset/',  'read("./source/asset/'),
    ('read("asset/',    'read("source/asset/'),
    # Bibliography file lives inside source/.
    ('bibliography("refs.bib"',   'bibliography("source/refs.bib"'),
    ('bibliography("./refs.bib"', 'bibliography("source/refs.bib"'),
)


def rewrite(text: str) -> str:
    for pat, repl in _RULES:
        text = text.replace(pat, repl)
    return text


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(f"usage: {argv[0]} <input.typ> <output.typ>", file=sys.stderr)
        return 2
    src = Path(argv[1])
    dst = Path(argv[2])
    if not src.is_file():
        print(f"missing: {src}", file=sys.stderr)
        return 1
    dst.write_text(rewrite(src.read_text()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
