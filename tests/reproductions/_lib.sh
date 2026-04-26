#!/usr/bin/env bash
# Shared build helper for reproductions.
#
# Each reproduction lives in tests/reproductions/<name>/ with:
#   source/        symlink to the original document directory
#   build.sh       sources this file, calls build <entry-filename>
#                  and (optionally) build_ref <entry-filename>
#
# Reproductions are the *holistic* test: ref = original PDF compiled through
# its own handout package, live = our dual-typst PDF + HTML. PNG pixel-diffs
# are not used here; the index renders the two PDFs side-by-side for review.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_compile.sh"

build() {
    local entry="$1"
    local src="source/$entry"
    local patched="_main.typ"
    local root=../../..

    [[ -f "$src" ]] || { echo "missing $src" >&2; exit 1; }

    python3 "$(dirname "${BASH_SOURCE[0]}")/_rewrite.py" "$src" "$patched"

    tc_pdf  "$root" "$patched" out.pdf  &
    tc_html "$root" "$patched" out.html &
    wait
    rm -f out.png out-[0-9]*.png
    echo "Built: $(pwd)/{out.pdf,out.html}"
}

# Compile the *original* source through its own handout package, untouched.
# Result is pinned as the PDF reference at tests/refs/reproductions/<name>/.
# Run once after `git pull` of the source, or whenever the original changes.
build_ref() {
    local entry="$1"
    local name
    name="$(basename "$(pwd)")"
    local ref_dir="../../refs/reproductions/$name"
    mkdir -p "$ref_dir"
    typst compile --root source "source/$entry" "$ref_dir/out.pdf" >/dev/null 2>&1 \
        || { echo "FAIL ref-build: $name (source/$entry)" >&2; exit 1; }
    echo "Ref:   $ref_dir/out.pdf"
}
