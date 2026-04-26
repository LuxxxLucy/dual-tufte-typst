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
        both) find_args=( -name 'out.png' -o -name 'out-[0-9]*.png' -o -name 'out.html' ) ;;
    esac
    while IFS= read -r -d '' live; do
        local kind=png
        [[ "$live" == *.html ]] && kind=html
        printf '%s\t%s\t%s\n' "$kind" "refs/$live" "$live"
    done < <(find "$group" \( "${find_args[@]}" \) -print0 | sort -z)
}

# Reproductions are whole-document artifacts; PNG drift is expected
# (small font-subset / kerning rounding). Gate HTML only — the PNG strip
# stays in the index for visual review.
all_triples() {
    emit_triples cases
    emit_triples reproductions html
    emit_triples limitations
}

if [[ $UPDATE -eq 1 ]]; then
    while IFS=$'\t' read -r _ ref live; do
        mkdir -p "$(dirname "$ref")"
        cp -f "$live" "$ref"
    done < <(all_triples)
    echo "refs updated under refs/"
    exit 0
fi

if all_triples | ./_diff.py check; then
    echo "PASS"
else
    exit 1
fi
