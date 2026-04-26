#!/usr/bin/env bash
# Build every registered style on the canonical tufte-css homepage source
# and serve the gallery on http://localhost:8766/.
#
# Usage: ./tests/gallery/serve.sh [port]

set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8766}"

echo "==> building all styles"
./build.sh

echo "==> serving http://localhost:${PORT}/"
python3 -m http.server "${PORT}"
