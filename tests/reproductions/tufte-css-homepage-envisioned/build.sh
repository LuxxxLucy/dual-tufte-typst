#!/usr/bin/env bash
# tufte-css homepage rendered through envision style (Roboto Condensed body,
# tufte.min.css + envisioned.css overlay). _main.typ symlinks the canonical
# tufte-css-homepage source; only the style differs.
set -euo pipefail
cd "$(dirname "$0")"
source ../../_compile.sh

ROOT=../../..
tc_pdf  "$ROOT" _main.typ out.pdf       --input style=envision &
tc_html "$ROOT" _main.typ out.html      --input style=envision &
tc_png  "$ROOT" _main.typ "out-{n}.png" --input style=envision &
wait
echo "Built: $(pwd)/{out.pdf,out.html,out-N.png}"
