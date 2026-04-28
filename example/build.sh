#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../tests/_compile.sh

ROOT=..
tc_pdf  "$ROOT" example.typ example.pdf  &
tc_html "$ROOT" example.typ example.html &
wait
echo "Built: $(pwd)/{example.pdf,example.html}"
