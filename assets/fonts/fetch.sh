#!/usr/bin/env bash
# Fetch optional free fonts that improve render fidelity for some styles.
# Idempotent — skips files that already exist.
#
#   ./assets/fonts/fetch.sh
#
# `assets/fonts/` is .gitignored; this script is the canonical way to
# repopulate it on a new clone or in CI. The .github/workflows/build-web.yml
# action runs it before building the web app.
#
# Apache / SIL fonts only. Commercial faces (Söhne, Berkeley Mono,
# Colfax, Input, SF Mono) are not pulled — styles that mention them
# fall back to bundled families (Inter, Menlo) with a Typst warning.
#
# Pipeline: pull each fontsource npm tarball, extract the latin-subset
# WOFF, convert WOFF → TTF (Typst 0.14 only loads TTF/OTF/TTC/OTC).

set -euo pipefail
cd "$(dirname "$0")"

# Require uv for the WOFF → TTF conversion (fonttools).
if ! command -v uv >/dev/null 2>&1; then
    echo "fetch.sh needs \`uv\` for WOFF → TTF conversion. Install: https://github.com/astral-sh/uv" >&2
    exit 1
fi

woff_to_ttf() {
    local woff="$1" ttf="$2" rename_family="${3:-}"
    uv run --quiet --with fonttools python3 - "$woff" "$ttf" "$rename_family" <<'PY'
import sys
from fontTools.ttLib import TTFont

src, dst, rename_family = sys.argv[1], sys.argv[2], sys.argv[3]
f = TTFont(src)
f.flavor = None  # strip WOFF wrapper, write plain TTF

# Optional family rename. Typst (≤0.14) groups family names by stripping
# axis-suffix words like "Condensed", so a font shipped as
# "Roboto Condensed" disappears under "Roboto". Renaming to
# "RobotoCondensed" (no space) survives the normalization. Pass an
# empty string to skip.
if rename_family:
    nm = f['name']
    subfamily = nm.getDebugName(2) or "Regular"
    for nid in (1, 4, 6, 16, 17):
        nm.removeNames(nameID=nid)
    nm.setName(rename_family, 1, 3, 1, 0x409)
    nm.setName(rename_family, 1, 1, 0, 0)
    nm.setName(f"{rename_family} {subfamily}", 4, 3, 1, 0x409)
    nm.setName(f"{rename_family}-{subfamily.replace(' ','')}", 6, 3, 1, 0x409)

f.save(dst)
PY
}

# Pull one weight/style of a fontsource family. `family_npm` is the
# package name suffix (e.g. roboto-condensed); `version` is pinned so
# upstream renames don't break the script.
fetch_face() {
    local family_npm="$1" version="$2" weight="$3" style="$4" out_ttf="$5" rename_family="${6:-}"
    if [[ -s "$out_ttf" ]]; then
        echo "  ✓ exists: $out_ttf"
        return
    fi
    local tarball="/tmp/fontsource-$family_npm-$version.tgz"
    if [[ ! -s "$tarball" ]]; then
        local url="https://registry.npmjs.org/@fontsource/$family_npm/-/$family_npm-$version.tgz"
        curl -sLf --max-time 60 "$url" -o "$tarball" || { echo "FAIL: $url" >&2; exit 1; }
    fi
    local woff_in_tar="package/files/$family_npm-latin-$weight-$style.woff"
    local tmp_dir; tmp_dir=$(mktemp -d)
    tar xzf "$tarball" -C "$tmp_dir" "$woff_in_tar" 2>/dev/null || {
        echo "FAIL: $woff_in_tar not in $tarball" >&2
        rm -rf "$tmp_dir"
        exit 1
    }
    mkdir -p "$(dirname "$out_ttf")"
    woff_to_ttf "$tmp_dir/$woff_in_tar" "$out_ttf" "$rename_family"
    rm -rf "$tmp_dir"
    echo "  ↓ converted: $out_ttf"
}

# Roboto Condensed — `envision` style (matches rstudio/tufte's
# envisioned variant). Apache 2.0.
#
# Renamed in-place to "RobotoCondensed" (no space) because Typst 0.14's
# font matcher strips axis-suffix words like "Condensed" from family
# names, collapsing "Roboto Condensed" into the bundled "Roboto"
# family and making the condensed face unreachable.
echo "Roboto Condensed (renamed RobotoCondensed):"
fetch_face roboto-condensed 5.0.4 400 normal "roboto/RobotoCondensed-Regular.ttf" "RobotoCondensed"
fetch_face roboto-condensed 5.0.4 700 normal "roboto/RobotoCondensed-Bold.ttf"    "RobotoCondensed"
fetch_face roboto-condensed 5.0.4 400 italic "roboto/RobotoCondensed-Italic.ttf"  "RobotoCondensed"

# JetBrains Mono — free mono fallback for orange-happy / bluewhite.
# Apache 2.0.
echo "JetBrains Mono:"
fetch_face jetbrains-mono 5.0.21 400 normal "jetbrains-mono/JetBrainsMono-Regular.ttf"
fetch_face jetbrains-mono 5.0.21 700 normal "jetbrains-mono/JetBrainsMono-Bold.ttf"
fetch_face jetbrains-mono 5.0.21 400 italic "jetbrains-mono/JetBrainsMono-Italic.ttf"

# Inter extra weights — back the existing Inter-Regular / Italic so
# semibold / medium heading specs in orange-happy / bluewhite
# resolve to real glyphs instead of synthesized bold. SIL OFL.
echo "Inter:"
fetch_face inter 5.2.6 500 normal "inter/Inter-Medium.ttf"
fetch_face inter 5.2.6 600 normal "inter/Inter-SemiBold.ttf"
fetch_face inter 5.2.6 700 normal "inter/Inter-Bold.ttf"

echo ""
echo "done. Verify with: typst fonts --font-path assets/fonts | grep -iE 'roboto cond|jetbrains|inter'"
