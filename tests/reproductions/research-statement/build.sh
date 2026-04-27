#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../../_compile.sh

ROOT=../../..
ENTRY=what_I_want_to_do_jialin_lu.typ
tc_pdf  "$ROOT" "$ENTRY" out.pdf  &
tc_html "$ROOT" "$ENTRY" out.html &
wait
echo "Built: $(pwd)/{out.pdf,out.html}"
