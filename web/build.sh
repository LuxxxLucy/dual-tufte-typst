#!/usr/bin/env bash
# Build the web app into web/_site/: example/example.typ as PDF and HTML
# in every style, the page, and styles.txt (one style per line).

set -euo pipefail
cd "$(dirname "$0")/.."

OUT=web/_site
ROOT="$(pwd)"
SRC="$ROOT/example/example.typ"

# jialin needs Berkeley Mono, a paid font; only local builds include it.
STYLES=(tufte-original envision terpret orange-happy bluewhite rosa)
[[ -z "${CI:-}" ]] && STYLES+=(jialin)

source "$ROOT/tests/_compile.sh"

rm -rf "$OUT"
mkdir -p "$OUT/styles"

build_one() {
    local outdir="$OUT/styles/$1"
    mkdir -p "$outdir"
    tc_pdf  "$ROOT" "$SRC" "$outdir/out.pdf"  --input style="$1"
    tc_html "$ROOT" "$SRC" "$outdir/out.html" --input style="$1"
    echo "==> $1"
}

# Wait on each job so a failed style fails the build.
pids=()
for s in "${STYLES[@]}"; do
    build_one "$s" & pids+=($!)
done
for p in "${pids[@]}"; do wait "$p"; done

cp -r web/index.html web/css web/js example/example.typ "$OUT/"
printf '%s\n' "${STYLES[@]}" > "$OUT/styles.txt"

echo "==> $OUT"
