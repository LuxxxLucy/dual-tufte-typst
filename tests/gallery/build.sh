#!/usr/bin/env bash
# Render example/example.typ through every registered style. The example
# is the canonical demo of our public API; gallery shows how each style
# renders the same source.
#
# PDF + per-page PNG only. HTML output is currently style-agnostic
# (always emits canonical tufte-css markup) — per-style HTML CSS support
# is a TODO; once it lands, restore an HTML pane in the index.
#
# Output: tests/gallery/<style>/out.pdf + tests/gallery/<style>/out-N.png

set -euo pipefail
cd "$(dirname "$0")"
source ../_compile.sh

STYLES=(jialin tufte-original envision terpret claude-tufte openai-tufte)
ROOT=../..
SRC=../../example/example.typ

build_one() {
    local style="$1"
    mkdir -p "$style"
    rm -f "$style"/out.pdf "$style"/out.html "$style"/out-*.png "$style"/out.png
    tc_pdf  "$ROOT" "$SRC" "$style/out.pdf"           --input style="$style" &
    tc_png  "$ROOT" "$SRC" "$style/out-{n}.png"       --input style="$style" &
    wait
    echo "==> $style"
}

for s in "${STYLES[@]}"; do
    build_one "$s" &
done
wait
echo "all styles built"

python3 _gen_index.py > index.html
echo "==> index.html"
