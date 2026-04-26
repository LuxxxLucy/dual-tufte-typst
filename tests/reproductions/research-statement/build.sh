#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../_lib.sh
build "what_I_want_to_do_jialin_lu.typ"
build_ref "what_I_want_to_do_jialin_lu.typ"
