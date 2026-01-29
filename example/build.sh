#!/usr/bin/env bash
set -euo pipefail

# Build example.typ to PDF and HTML

echo "Building PDF..."
typst compile --root .. example.typ

echo "Building HTML..."
typst compile --root .. --input target=html --features html example.typ example.html

echo "Done: example.pdf, example.html"

