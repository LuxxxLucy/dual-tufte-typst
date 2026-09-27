#!/usr/bin/env bash
# Build the web app into web/_site/: example/example.typ as PDF and HTML
# in every style, the page, and styles.txt (one style per line).

set -euo pipefail
cd "$(dirname "$0")/.."

OUT=web/_site

# jialin needs Berkeley Mono, a paid font; only local builds include it.
STYLES=(tufte-original envision terpret orange-happy bluewhite rosa)
[[ -z "${CI:-}" ]] && STYLES+=(jialin)

rm -rf "$OUT"
mkdir -p "$OUT/styles"

build_one() {
    local dir="$OUT/styles/$1" args=(--root . --font-path assets/fonts --input style="$1")
    mkdir -p "$dir"
    typst compile "${args[@]}" example/example.typ "$dir/out.pdf"
    typst compile "${args[@]}" --features html example/example.typ "$dir/out.html"
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
