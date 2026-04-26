#!/usr/bin/env bash
# Build everything (cases + reproductions + limitations), run the
# structural smoke test, regenerate the index, and serve tests/ on
# http://localhost:8765 for browser inspection.
#
# Usage: ./tests/serve.sh [port]

set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8765}"

echo "==> building cases, reproductions, limitations, gallery (parallel groups)"
( cd cases         && ./build-all.sh ) &
( cd reproductions && ./build-all.sh ) &
( cd limitations   && ./build-all.sh ) &
( cd gallery       && ./build.sh )     &
wait

echo "==> running structural smoke test"
./_smoke.py --quiet || { echo "smoke test failed — fix structural issues before serving" >&2; exit 1; }

echo "==> running ref diff (non-fatal — diffs surface in the index)"
./check.sh || true

echo "==> generating index.html"
python3 _gen_index.py > index.html

echo "==> serving http://localhost:${PORT}/"
python3 -m http.server "${PORT}"
