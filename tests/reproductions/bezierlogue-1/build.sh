#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../_lib.sh
build "blog.typ"
build_ref "blog.typ"
