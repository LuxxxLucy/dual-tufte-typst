#!/usr/bin/env bash
# Build every reproduction in parallel.
set -euo pipefail
cd "$(dirname "$0")"

run_one() {
    local dir="$1"
    [[ -x "$dir/build.sh" ]] || return 0
    # Drop stale per-page PNGs; page count can shrink between runs and
    # leftover out-NN.png would otherwise pollute the index and refs.
    rm -f "$dir"/out.pdf "$dir"/out.html "$dir"/out-*.png "$dir"/out.png
    if (cd "$dir" && ./build.sh >/dev/null 2>&1); then
        echo "==> ${dir%/}"
    else
        echo "FAIL: ${dir%/}" >&2
        return 1
    fi
}
export -f run_one

printf '%s\0' */ \
    | xargs -0 -n1 -P "$(sysctl -n hw.ncpu 2>/dev/null || echo 4)" \
        -I{} bash -c 'run_one "$1"' _ {}

echo "all reproductions built"
