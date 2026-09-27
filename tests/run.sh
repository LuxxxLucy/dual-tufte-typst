#!/usr/bin/env bash
# Build every case to HTML and PNG, check the HTML structure, and compare
# the PNG of the first page with refs/.
#
#   ./tests/run.sh           fail on any difference
#   ./tests/run.sh --update  save the PNGs as the new refs
set -euo pipefail
cd "$(dirname "$0")"

tc() { log=$(typst compile --root .. --font-path ../assets/fonts --ignore-system-fonts "$@" 2>&1) || { echo "$log"; exit 1; }; }

for src in cases/*/*/case.typ; do
    dir=$(dirname "$src")
    rm -f "$dir"/out* "$dir"/diff.png
    tc --features html "$src" "$dir/out.html"
    tc --ppi 144 "$src" "$dir/out-{n}.png"
    mv "$dir/out-1.png" "$dir/out.png"
    rm -f "$dir"/out-*.png
done

./_smoke.py
pngs=(cases/*/*/out.png)
if [[ ${1:-} == --update ]]; then
    rm -rf refs
    for f in "${pngs[@]}"; do mkdir -p "refs/$(dirname "$f")"; cp "$f" "refs/$f"; done
    echo "refs updated"
    exit
fi
./_diff.py "${pngs[@]}"
echo PASS
