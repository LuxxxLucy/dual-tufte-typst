#!/usr/bin/env bash
# Build every tests/cases/<feature>/<name>/case.typ → sibling out.{html,png}.
set -euo pipefail
cd "$(dirname "$0")"
source ../_compile.sh
tc_build_all_cases ../../../..
echo "all cases built"
