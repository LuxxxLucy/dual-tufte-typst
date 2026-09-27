#!/usr/bin/env -S uv run --quiet
# /// script
# dependencies = ["pillow"]
# ///
"""Compare each given PNG with refs/<same path>; exit 1 on any mismatch.

A PNG matches when it has the same size and every channel is within 1.
A mismatch writes diff.png (ref | live | 8x difference).
"""
import sys
from pathlib import Path
from PIL import Image, ImageChops


def same_png(ref, live):
    a, b = Image.open(ref).convert("RGB"), Image.open(live).convert("RGB")
    if a.size == b.size:
        d = ImageChops.difference(a, b)
        if max(hi for _, hi in d.getextrema()) <= 1:
            return True
        d = d.point(lambda v: min(255, v * 8))
    else:
        d = Image.new("RGB", b.size, (255, 200, 200))
    out = Image.new("RGB", (a.width + b.width + d.width + 8, max(a.height, b.height)), (240, 240, 240))
    for x, im in ((0, a), (a.width + 4, b), (a.width + b.width + 8, d)):
        out.paste(im, (x, 0))
    out.save(live.with_name("diff.png"))
    return False


ok = True
for live in map(Path, sys.argv[1:]):
    ref = "refs" / live
    if not ref.exists():
        print(f"MISSING ref: {ref}")
    elif same_png(ref, live):
        continue
    else:
        print(f"MISMATCH: {live}")
    ok = False
sys.exit(not ok)
