#!/usr/bin/env bash
# Build cases and reproductions, run the smoke test and the ref check,
# write index.html, and serve tests/ on http://localhost:8765.
#
# Usage: ./tests/serve.sh [port]

set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8765}"

echo "==> building cases and reproductions"
./cases/build-all.sh
./reproductions/build-all.sh

echo "==> running structural smoke test (failures surface in the index)"
./_smoke.py --quiet > _smoke.log 2>&1 || true

echo "==> running ref diff (diffs surface in the index)"
./check.sh > _check.log 2>&1 || true

echo "==> generating index.html"
python3 _gen_index.py > index.html

echo "==> serving http://localhost:${PORT}/"
python3 -m http.server "${PORT}"
