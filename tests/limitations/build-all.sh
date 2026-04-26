#!/usr/bin/env bash
# Build every tests/limitations/<name>/case.typ — kept separate from cases/
# so a reviewer can grep "limitation" in CI output.
set -euo pipefail
cd "$(dirname "$0")"
source ../_compile.sh
tc_build_all_cases ../../..
echo "all limitations built"
