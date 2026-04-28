#!/usr/bin/env bash
# Build the web app and serve it locally.
#   ./web/serve.sh           # builds web/_site, serves on :8000
#   ./web/serve.sh 9000      # custom port
set -euo pipefail
cd "$(dirname "$0")/.."

PORT="${1:-8000}"
./web/build.sh
echo "==> http://localhost:${PORT}/"
cd web/_site && python3 -m http.server "${PORT}"
