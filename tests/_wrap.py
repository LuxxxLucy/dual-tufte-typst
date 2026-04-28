#!/usr/bin/env python3
"""Wrap a body-only case.typ into a compilable Typst file.

Reads ``case.typ`` and writes ``_wrapped.typ`` next to it. The wrapper
prepends `#import "/src/lib.typ": *` plus
`#show: tufte.with(style: "jialin", ..<extra>)` to the case body so case
files can be body-only. Per-case overrides come from an optional
directive:

    // !with: (title: [...], author: "...", config: (page: (...)))

spread into the `tufte.with(...)` call. The directive line is stripped
before the body is embedded.

Image and asset paths in case.typ are preserved because ``_wrapped.typ``
sits in the same directory as case.typ.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

DIRECTIVE_WITH = re.compile(r'^\s*//\s*!with:\s*(.+?)\s*$', re.M)


def main() -> None:
    case = Path(sys.argv[1]).resolve()
    text = case.read_text()
    wrapper = case.parent / "_wrapped.typ"

    m = DIRECTIVE_WITH.search(text)
    extra = f", ..{m.group(1)}" if m else ""
    body = DIRECTIVE_WITH.sub('', text).lstrip("\n")

    wrapper.write_text(
        f'#import "/src/lib.typ": *\n'
        f'#show: tufte.with(style: "jialin"{extra})\n'
        f'\n'
        f'{body}'
    )
    print(wrapper)


if __name__ == "__main__":
    main()
