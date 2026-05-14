#!/usr/bin/env bash
# Bootstrap dual-tufte-typst on a new machine, or just install the
# `dual-typst` CLI symlink on a machine where it is already cloned.
#
#   curl -fsSL https://raw.githubusercontent.com/LuxxxLucy/dual-tufte-typst/main/install.sh | bash
#   ./install.sh                              # from inside an existing clone
#   ./install.sh --bindir ~/bin --no-fonts
#
# Modes:
#   - Inside an existing clone: skip clone, optionally run fetch.sh, link CLI.
#   - Piped via curl (no enclosing clone): clone into $DUAL_TYPST_HOME
#     (default ~/.local/share/dual-tufte-typst), run fetch.sh, link CLI.
#
# Flags:
#   --dest DIR     where to clone when not inside a clone
#                  (default: ${DUAL_TYPST_HOME:-$HOME/.local/share/dual-tufte-typst})
#   --bindir DIR   directory on PATH to receive the dual-typst symlink
#                  (default: $HOME/.local/bin)
#   --no-fonts     skip assets/fonts/fetch.sh
#   --repo URL     git URL to clone from (default: upstream)
#   -h, --help     show this help

set -euo pipefail

REPO_URL="https://github.com/LuxxxLucy/dual-tufte-typst.git"
DEFAULT_DEST="${DUAL_TYPST_HOME:-$HOME/.local/share/dual-tufte-typst}"
DEFAULT_BINDIR="$HOME/.local/bin"

dest=""
bindir="$DEFAULT_BINDIR"
fetch_fonts=1

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

die() {
  printf 'install.sh: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '==> %s\n' "$*"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dest)
      [ "$#" -ge 2 ] || die "--dest requires a path"
      dest="$2"; shift 2 ;;
    --bindir)
      [ "$#" -ge 2 ] || die "--bindir requires a path"
      bindir="$2"; shift 2 ;;
    --repo)
      [ "$#" -ge 2 ] || die "--repo requires a URL"
      REPO_URL="$2"; shift 2 ;;
    --no-fonts)
      fetch_fonts=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      die "unknown argument: $1" ;;
  esac
done

# Detect whether we are running from inside a clone. When curl-piped to bash,
# $0 is "bash" (or similar) and BASH_SOURCE[0] is empty, so the file does not
# exist on disk.
script_path=""
if [ "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  script_path="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
fi

repo=""
if [ -n "$script_path" ]; then
  candidate="$(dirname "$script_path")"
  if [ -x "$candidate/bin/dual-typst" ] && [ -d "$candidate/src" ]; then
    repo="$candidate"
  fi
fi

if [ -z "$repo" ]; then
  # Curl-pipe mode: need to clone.
  command -v git >/dev/null 2>&1 || die "git is required to clone $REPO_URL"
  target="${dest:-$DEFAULT_DEST}"
  if [ -d "$target/.git" ]; then
    log "Using existing clone at $target"
    repo="$target"
  elif [ -e "$target" ]; then
    die "destination exists and is not a git checkout: $target"
  else
    log "Cloning $REPO_URL into $target"
    mkdir -p "$(dirname "$target")"
    git clone --depth 1 "$REPO_URL" "$target"
    repo="$target"
  fi
else
  if [ -n "$dest" ]; then
    log "Ignoring --dest: running inside existing clone at $repo"
  fi
fi

# Fonts. The repo gitignores assets/fonts/* so a fresh clone has only fetch.sh
# inside it. Run fetch.sh unless the user opted out or uv is missing.
if [ "$fetch_fonts" -eq 1 ]; then
  if command -v uv >/dev/null 2>&1; then
    log "Fetching fonts via assets/fonts/fetch.sh"
    "$repo/assets/fonts/fetch.sh"
  else
    log "Skipping font fetch: \`uv\` not found. Install uv, then run $repo/assets/fonts/fetch.sh"
  fi
else
  log "Skipping font fetch (--no-fonts)"
fi

# CLI symlink. Always absolute so the link survives a moved \$PATH entry.
mkdir -p "$bindir"
link="$bindir/dual-typst"
target_bin="$repo/bin/dual-typst"
[ -x "$target_bin" ] || die "expected executable not found: $target_bin"

if [ -L "$link" ]; then
  existing="$(readlink "$link")"
  if [ "$existing" = "$target_bin" ]; then
    log "Symlink already in place: $link -> $target_bin"
  else
    log "Replacing existing symlink: $link (was -> $existing)"
    ln -sf "$target_bin" "$link"
  fi
elif [ -e "$link" ]; then
  die "$link exists and is not a symlink; refusing to overwrite"
else
  ln -s "$target_bin" "$link"
  log "Linked $link -> $target_bin"
fi

case ":$PATH:" in
  *":$bindir:"*) ;;
  *) log "Note: $bindir is not on \$PATH. Add it to your shell rc to use \`dual-typst\` directly." ;;
esac

log "Done. Try: dual-typst create ~/papers/my-doc"
