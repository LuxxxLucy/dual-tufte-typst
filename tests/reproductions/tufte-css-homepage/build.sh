#!/usr/bin/env bash
# Tufte-CSS homepage reproduction.
# Live = our dual-typst PDF + HTML rendered from _main.typ.
# Ref  = upstream snapshot at tests/refs/reproductions/tufte-css-homepage/
#        upstream.html (refresh by hand when upstream changes).
set -euo pipefail
cd "$(dirname "$0")"
source ../../_compile.sh

ROOT=../../..
tc_pdf  "$ROOT" _main.typ out.pdf            &
tc_html "$ROOT" _main.typ out.html           &
tc_png  "$ROOT" _main.typ "out-{n}.png"      &
wait
echo "Built: $(pwd)/{out.pdf,out.html,out-N.png}"

# Refresh upstream snapshot (run by hand when upstream changes):
#   curl -sL https://edwardtufte.github.io/tufte-css/index.html \
#       -o ../../refs/reproductions/tufte-css-homepage/upstream.html
