#!/usr/bin/env bash
# Build the public web app at web/_site/.
#
#   ./web/build.sh                   # build into web/_site
#   ./web/build.sh /custom/output    # build into /custom/output
#
# Renders example/example.typ through every PUBLIC style (excludes jialin —
# uses Berkeley Mono, which is not freely redistributable). Output:
#
#   _site/index.html                 # web app entry (router; views below)
#   _site/css/, _site/js/            # app shell (copied from web/)
#   _site/manifest.json              # {styles, pages: {<style>: N}}
#   _site/styles/<style>/out.{pdf,html}, out-N.png
#   _site/example.typ                # source (linked by editor view)
#   _site/src/...                    # template source (loaded by WASM editor)

set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:-web/_site}"
ROOT="$(pwd)"
SRC="$ROOT/example/example.typ"

# Public styles. Jialin needs Berkeley Mono (paid, not webfont) — exclude
# from the public app rather than ship a degraded fallback render. The
# local tests/gallery/ keeps jialin for development.
STYLES=(tufte-original envision terpret orange-happy bluewhite)

source "$ROOT/tests/_compile.sh"

rm -rf "$OUT"
mkdir -p "$OUT/styles"

# typst is multi-threaded per process; parallelize across styles only.
build_one() {
    local style="$1"
    local outdir="$OUT/styles/$style"
    mkdir -p "$outdir"
    tc_pdf  "$ROOT" "$SRC" "$outdir/out.pdf"      --input style="$style"
    tc_png  "$ROOT" "$SRC" "$outdir/out-{n}.png"  --input style="$style"
    tc_html "$ROOT" "$SRC" "$outdir/out.html"     --input style="$style"
    echo "==> $style"
}

# `set -e` does not propagate background-job failures; collect PIDs and
# wait on each so a failed style aborts the deploy.
pids=()
for s in "${STYLES[@]}"; do
    build_one "$s" & pids+=($!)
done
for p in "${pids[@]}"; do wait "$p"; done

# App shell: index.html + js + css. Source bundle: typst.ts in the editor
# view fetches /src/manifest.json then every listed file.
cp web/index.html "$OUT/index.html"
cp -r web/css "$OUT/css"
cp -r web/js  "$OUT/js"
mkdir -p "$OUT/src"
cp -r src/* "$OUT/src/"
cp example/example.typ "$OUT/example.typ"

# Manifests: one for the gallery views, one for the editor's source bundle.
python3 - "$OUT" "${STYLES[@]}" <<'PY'
import json, sys
from pathlib import Path
out = Path(sys.argv[1])
styles = sys.argv[2:]
pages = {s: len(list((out / "styles" / s).glob("out-*.png"))) for s in styles}
(out / "manifest.json").write_text(
    json.dumps({"styles": styles, "pages": pages}, indent=2)
)
src_files = sorted(p.relative_to(out).as_posix()
                   for p in (out / "src").rglob("*.typ"))
(out / "src" / "manifest.json").write_text(
    json.dumps({"files": src_files}, indent=2)
)
PY

echo "==> $OUT"
