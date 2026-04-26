#!/usr/bin/env -S uv run --quiet
# /// script
# requires-python = ">=3.10"
# dependencies = ["pillow"]
# ///
"""PNG/HTML diff helpers used by check.sh.

PNG diff: typst-style — same dimensions and per-byte abs_diff ≤ TOL. On
mismatch, write a 3-column composite (ref | live | 8×-amplified difference)
as `diff.png` next to the live image.

HTML diff: exact byte equality.

PNGs are now stored at full page width (no autocrop) so the handout's
left gutter and margin column are visible in the test gallery.
"""
from __future__ import annotations
import sys
from pathlib import Path
from PIL import Image, ImageChops


TOL = 1


def diff_png(ref: Path, live: Path) -> tuple[bool, Image.Image | None, dict | None]:
    """Return (matches, side_by_side_image_if_mismatch_else_None, stats_or_None).

    stats: {max, mean, changed_pct} computed over the per-pixel RGB
    abs-diff. `mean` is the average channel delta (0–255); `changed_pct`
    is the fraction of pixels with any non-zero channel delta.

    Compare in RGB: if we use RGBA, equal alpha channels make
    `getextrema` report 0 on the alpha band but RGB drift can hide there.
    """
    a = Image.open(ref).convert("RGB")
    b = Image.open(live).convert("RGB")
    stats = None
    if a.size == b.size:
        diff = ImageChops.difference(a, b)
        extrema = diff.getextrema()
        if all(hi <= TOL for _lo, hi in extrema):
            return True, None, None
        max_d = max(hi for _lo, hi in extrema)
        # mean channel delta and changed-pixel count via histogram —
        # avoids PIL.Image.getdata which is deprecated in Pillow 13+.
        n = diff.width * diff.height * 3
        hist = diff.histogram()  # 768 entries: 256 per R, G, B band.
        total = sum(hist[i] * (i % 256) for i in range(len(hist)))
        mean = total / n if n else 0.0
        gray_hist = diff.convert("L").histogram()
        changed = sum(gray_hist[1:])  # any non-zero gray value
        changed_pct = 100.0 * changed / (diff.width * diff.height)
        stats = {"max": max_d, "mean": round(mean, 2), "changed_pct": round(changed_pct, 2)}
        amplified = diff.point(lambda v: min(255, v * 8))
    else:
        amplified = Image.new("RGB", b.size, (255, 200, 200))
        stats = {"max": 255, "mean": -1, "changed_pct": -1, "size_mismatch": True}
    h = max(a.height, b.height)
    canvas = Image.new("RGB", (a.width + b.width + amplified.width + 8, h), (240, 240, 240))
    canvas.paste(a, (0, 0))
    canvas.paste(b, (a.width + 4, 0))
    canvas.paste(amplified, (a.width + b.width + 8, 0))
    return False, canvas, stats


def check_one(kind: str, ref: Path, live: Path) -> bool:
    if not ref.exists():
        print(f"  MISSING ref: {ref}", file=sys.stderr)
        return False
    if kind == "html":
        if ref.read_bytes() == live.read_bytes():
            return True
        print(f"  HTML mismatch: {live}", file=sys.stderr)
        return False
    ok, composite, stats = diff_png(ref, live)
    if ok:
        return True
    diff_out = live.with_name("diff.png")
    composite.save(diff_out, optimize=True)
    if stats is not None:
        # Single-line `key=val` pairs so the index can read it without
        # parsing JSON. Keys: max, mean, changed_pct (and size_mismatch).
        meta = " ".join(f"{k}={v}" for k, v in stats.items())
        live.with_name("diff.txt").write_text(meta + "\n")
    print(f"  PNG mismatch: {live}  (diff → {diff_out})", file=sys.stderr)
    return False


# CLI:
#   _diff.py check    reads `kind\tref\tlive` triples from stdin, one per line.
#                     exit 0 if all match, 1 if any mismatch.
def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: _diff.py check", file=sys.stderr)
        return 2
    cmd = argv[1]
    if cmd == "check":
        ok = True
        for line in sys.stdin:
            line = line.rstrip("\n")
            if not line:
                continue
            kind, ref, live = line.split("\t")
            if not check_one(kind, Path(ref), Path(live)):
                ok = False
        return 0 if ok else 1
    print(f"unknown cmd: {cmd}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
