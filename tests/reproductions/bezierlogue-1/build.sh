#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../../_compile.sh

ROOT=../../..
tc_pdf  "$ROOT" blog.typ out.pdf  &
tc_html "$ROOT" blog.typ out.html &
wait
echo "Built: $(pwd)/{out.pdf,out.html}"
