#!/usr/bin/env bash
# Build every tests/limitations/<name>/case.typ — kept separate from cases/
# so a reviewer can grep "limitation" in CI output.
set -euo pipefail
cd "$(dirname "$0")"
source ../_compile.sh

build_one() {
    local dir="$1"
    local root=../../..
    (
        cd "$dir"
        rm -f out.pdf
        tc_html "$root" case.typ out.html || exit 1
        tc_png  "$root" case.typ out.png  || exit 1
        if [[ -f out-1.png ]]; then
            mv -f out-1.png out.png
            rm -f out-[0-9]*.png
        fi
        echo "==> $dir"
    )
}
export -f build_one tc_html tc_png

find . -name case.typ -print0 \
    | xargs -0 -n1 -P "$(sysctl -n hw.ncpu 2>/dev/null || echo 4)" \
        -I{} bash -c 'source ../_compile.sh; build_one "$(dirname "$1")"' _ {}

echo "all limitations built"
