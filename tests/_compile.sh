#!/usr/bin/env bash
# Shared typst-compile helpers. Source from any tests/ build script:
#
#   source "$(git rev-parse --show-toplevel)/tests/_compile.sh"     # any depth
# or, when running from a fixed depth:
#   source ../../_compile.sh
#
# Each helper takes (root_path, src.typ, output_path, [extra-input-pairs...])
# and forwards optional `--input k=v` extras. Fails the whole script on
# typst error.

# Compile a typst source to PDF.
tc_pdf() {
    local root="$1" src="$2" out="$3"; shift 3
    typst compile --root "$root" --font-path "$root/assets/fonts" \
        "$@" "$src" "$out" >/dev/null 2>&1 \
        || { echo "FAIL pdf:  $src" >&2; return 1; }
}

# Compile a typst source to HTML (target=html, --features html).
# Tests pin `color-scheme=light` so HTML refs are deterministic regardless
# of the developer's machine preference. Default doc compile is `light dark`.
tc_html() {
    local root="$1" src="$2" out="$3"; shift 3
    typst compile --root "$root" --font-path "$root/assets/fonts" \
        --features html --input target=html --input color-scheme=light \
        "$@" "$src" "$out" >/dev/null 2>&1 \
        || { echo "FAIL html: $src" >&2; return 1; }
}

# Compile a typst source to PNG. `out` may include `{n}` for per-page PNGs
# (e.g. "out-{n}.png") or be a single path (auto-suffixed by typst when the
# document has multiple pages).
tc_png() {
    local root="$1" src="$2" out="$3"; shift 3
    typst compile --root "$root" --font-path "$root/assets/fonts" \
        --ppi 144 \
        "$@" "$src" "$out" >/dev/null 2>&1 \
        || { echo "FAIL png:  $src" >&2; return 1; }
}

# Build every <dir>/case.typ under the calling script's cwd to sibling
# out.{html,png}. `root` is the path from each case dir back to the project
# root. Used by tests/cases/ and tests/limitations/ build-all.sh.
#
# Each case.typ is wrapped via tests/_wrap.py into _wrapped.typ in the same
# directory; the wrapper applies the shared `tufte.with(style: "jialin")`
# preamble and embeds the case body, so case files hold body content only.
# The `// !with: (...)` directive in a case.typ injects per-case args into
# the preamble.
tc_build_all_cases() {
    local root="$1"
    build_one() {
        local dir="$1" root="$2"
        (
            cd "$dir"
            rm -f out.pdf out-*.png _wrapped.typ
            python3 "$root/tests/_wrap.py" case.typ >/dev/null
            tc_html "$root" _wrapped.typ out.html || exit 1
            tc_png  "$root" _wrapped.typ out.png  || exit 1
            if [[ -f out-1.png ]]; then
                mv -f out-1.png out.png
                rm -f out-[0-9]*.png
            fi
            rm -f _wrapped.typ
            echo "==> $dir"
        )
    }
    export -f build_one tc_html tc_png
    find . -name case.typ -print0 \
        | xargs -0 -n1 -P "$(sysctl -n hw.ncpu 2>/dev/null || echo 4)" \
            -I{} bash -c 'set -e; build_one "$(dirname "$1")" "$2"' _ {} "$root"
}
