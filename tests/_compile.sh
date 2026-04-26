#!/usr/bin/env bash
# Shared typst-compile helpers. Source from any tests/ build script:
#
#   source "$(git rev-parse --show-toplevel)/tests/_compile.sh"     # any depth
# or, when running from a fixed depth:
#   source ../../_compile.sh
#
# Each helper takes (root_path, src.typ, output_path, [extra-input-pairs...])
# and forwards optional `--input k=v` extras. Fails the whole script on
# typst error.

# Compile a typst source to PDF.
tc_pdf() {
    local root="$1" src="$2" out="$3"; shift 3
    typst compile --root "$root" --font-path "$root/assets/fonts" \
        "$@" "$src" "$out" >/dev/null 2>&1 \
        || { echo "FAIL pdf:  $src" >&2; return 1; }
}

# Compile a typst source to HTML (target=html, --features html).
tc_html() {
    local root="$1" src="$2" out="$3"; shift 3
    typst compile --root "$root" --font-path "$root/assets/fonts" \
        --features html --input target=html \
        "$@" "$src" "$out" >/dev/null 2>&1 \
        || { echo "FAIL html: $src" >&2; return 1; }
}

# Compile a typst source to PNG. `out` may include `{n}` for per-page PNGs
# (e.g. "out-{n}.png") or be a single path (auto-suffixed by typst when the
# document has multiple pages).
tc_png() {
    local root="$1" src="$2" out="$3"; shift 3
    typst compile --root "$root" --font-path "$root/assets/fonts" \
        --ppi 144 \
        "$@" "$src" "$out" >/dev/null 2>&1 \
        || { echo "FAIL png:  $src" >&2; return 1; }
}
