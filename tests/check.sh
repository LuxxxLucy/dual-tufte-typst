#!/usr/bin/env bash
# Reference-output regression check.
#
# Per case (cropped PNG + HTML) and per reproduction (per-page PNGs + HTML),
# compare the freshly built file against the stored reference under
# tests/refs/. PNG diff is typst-style: same dimensions, every byte abs_diff ≤ 1.
# On mismatch, a 3-column composite `diff.png` is written next to the live file.
#
# PDFs are not gated — they embed timestamps and font-subset hashes.
# The PNG render of each PDF page is the layout fingerprint.
#
#   ./tests/check.sh           verify; non-zero exit on any drift
#   ./tests/check.sh --update  copy live → ref after intentional changes

set -euo pipefail
cd "$(dirname "$0")"

UPDATE=0
[[ "${1:-}" == "--update" ]] && UPDATE=1

# Emit `kind<TAB>ref<TAB>live` triples for every live file under a group.
# `kinds` controls which file types to gate (png|html|both).
emit_triples() {
    local group="$1" kinds="${2:-both}"
    local find_args=()
    case "$kinds" in
        png)  find_args=( -name 'out.png' -o -name 'out-[0-9]*.png' ) ;;
        html) find_args=( -name 'out.html' ) ;;
        pdf)  find_args=( -name 'out.pdf' ) ;;
        both) find_args=( -name 'out.png' -o -name 'out-[0-9]*.png' -o -name 'out.html' ) ;;
        all)  find_args=( -name 'out.pdf' -o -name 'out.png' -o -name 'out-[0-9]*.png' -o -name 'out.html' ) ;;
    esac
    while IFS= read -r -d '' live; do
        local kind=png
        [[ "$live" == *.html ]] && kind=html
        [[ "$live" == *.pdf  ]] && kind=pdf
        printf '%s\t%s\t%s\n' "$kind" "refs/$live" "$live"
    done < <(find "$group" \( "${find_args[@]}" \) -print0 | sort -z)
}

# Reproductions are whole-document artifacts; PNG drift is expected
# (small font-subset / kerning rounding). Gate HTML only — the PNG strip
# and PDF stay in the index for visual review.
gated_triples() {
    emit_triples cases
    emit_triples reproductions html
    emit_triples limitations
}

# --update copies every live artifact (HTML + PDF + PNGs) for every group
# so reproduction PDFs end up tracked too. Without this, the PDF + PNG
# strip in tests/refs/reproductions/ would never refresh after intentional
# changes, leaving stale visual references in the served index.
update_triples() {
    emit_triples cases
    emit_triples reproductions all
    emit_triples limitations
}

if [[ $UPDATE -eq 1 ]]; then
    while IFS=$'\t' read -r _ ref live; do
        mkdir -p "$(dirname "$ref")"
        cp -f "$live" "$ref"
    done < <(update_triples)
    echo "refs updated under refs/"
    exit 0
fi

if gated_triples | ./_diff.py check; then
    echo "PASS"
else
    exit 1
fi
