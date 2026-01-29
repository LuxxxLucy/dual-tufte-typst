#!/usr/bin/env bash
set -euo pipefail

# Dual-Typst Reference Test
# Compiles test.typ and compares outputs against reference files

# Configuration
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
TEST_FILE="$PROJECT_ROOT/tests/test.typ"
REF_DIR="$PROJECT_ROOT/tests/references"
OUT_DIR="$PROJECT_ROOT/out"
PDF_OUT="$OUT_DIR/test.pdf"
HTML_OUT="$OUT_DIR/test.html"
REF_PDF="$REF_DIR/test.pdf"
REF_HTML="$REF_DIR/test.html"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

compile_test() {
    echo -e "${BOLD}=== Compiling test.typ ===${RESET}"
    mkdir -p "$OUT_DIR"

    # Compile PDF
    echo "Building PDF..."
    if ! typst compile --root "$PROJECT_ROOT" "$TEST_FILE" "$PDF_OUT" 2>&1; then
        echo -e "${RED}✗ PDF compilation failed${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ PDF compiled: $PDF_OUT${RESET}"

    # Compile HTML
    echo "Building HTML..."
    if ! typst compile --root "$PROJECT_ROOT" --input target=html --features html "$TEST_FILE" "$HTML_OUT" 2>&1; then
        echo -e "${RED}✗ HTML compilation failed${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ HTML compiled: $HTML_OUT${RESET}"

    return 0
}

compare_sizes() {
    local ref_file="$1"
    local current_file="$2"
    local file_type="$3"
    local tolerance="${4:-0.01}"  # 1% tolerance

    if [[ ! -f "$ref_file" ]]; then
        echo -e "${YELLOW}⚠ No reference for $file_type${RESET}"
        return 0
    fi

    # BSD stat (macOS)
    local ref_size=$(stat -f "%z" "$ref_file")
    local current_size=$(stat -f "%z" "$current_file")

    # Calculate percentage difference
    local diff=$(( ref_size > current_size ? ref_size - current_size : current_size - ref_size ))
    local diff_pct=$(awk "BEGIN {printf \"%.2f\", ($diff / $ref_size) * 100}")

    # Compare with tolerance
    local tolerance_pct=$(awk "BEGIN {printf \"%.0f\", $tolerance * 100}")

    if (( $(awk "BEGIN {print ($diff_pct > $tolerance_pct)}") )); then
        echo -e "${RED}✗ $file_type size changed by ${diff_pct}% (${ref_size} → ${current_size} bytes)${RESET}"
        return 1
    else
        echo -e "${GREEN}✓ $file_type size OK (${current_size} bytes, ${diff_pct}% diff)${RESET}"
        return 0
    fi
}

validate_html() {
    local html_file="$1"
    local issues=0

    echo -e "\n${BOLD}=== Validating HTML Structure ===${RESET}"

    # Check required tags
    if ! grep -qi "<html" "$html_file"; then
        echo -e "${RED}✗ Missing <html> tag${RESET}"
        ((issues++))
    fi

    if ! grep -qi "<body" "$html_file"; then
        echo -e "${RED}✗ Missing <body> tag${RESET}"
        ((issues++))
    fi

    # Check Tufte CSS classes
    local tufte_classes=("sidenote" "marginnote" "fullwidth" "newthought" "epigraph")
    local found_count=0
    local found_list=()

    for class in "${tufte_classes[@]}"; do
        if grep -q "class=\"$class\"" "$html_file"; then
            ((found_count++))
            found_list+=("$class")
        fi
    done

    if (( found_count < 3 )); then
        echo -e "${YELLOW}⚠ Only $found_count Tufte CSS classes found (expected at least 3)${RESET}"
        ((issues++))
    else
        local found_str=$(IFS=,; echo "${found_list[*]}")
        echo -e "${GREEN}✓ Found $found_count Tufte CSS classes: ${found_str}${RESET}"
    fi

    return $issues
}


generate_references() {
    echo -e "${BOLD}=== Generating Reference Files ===${RESET}"
    mkdir -p "$REF_DIR"
    mkdir -p "$OUT_DIR"

    echo "Compiling PDF..."
    if ! typst compile --root "$PROJECT_ROOT" "$TEST_FILE" "$REF_PDF" 2>&1; then
        echo -e "${RED}✗ Failed to generate reference PDF${RESET}"
        return 1
    fi

    echo "Compiling HTML..."
    if ! typst compile --root "$PROJECT_ROOT" --input target=html --features html "$TEST_FILE" "$REF_HTML" 2>&1; then
        echo -e "${RED}✗ Failed to generate reference HTML${RESET}"
        return 1
    fi

    echo -e "\n${GREEN}✓ Reference files saved:${RESET}"
    echo "  - $REF_PDF"
    echo "  - $REF_HTML"
    date > "$REF_DIR/timestamp.txt"
    echo ""
    return 0
}

main() {
    echo -e "${BOLD}=== Reference Test ===${RESET}"
    echo "Project root: $PROJECT_ROOT"
    echo "Reference dir: $REF_DIR"
    echo "Output dir: $OUT_DIR"
    echo ""

    # Check references exist
    if [[ ! -f "$REF_PDF" ]] && [[ ! -f "$REF_HTML" ]]; then
        echo -e "${RED}Error: No reference files found in $REF_DIR${RESET}"
        echo "Run './test.sh --generate' to create reference files first"
        echo ""
        exit 1
    fi

    # Compile test file
    if ! compile_test; then
        exit 1
    fi

    echo ""

    # Compare outputs
    local failures=0

    # PDF comparison
    echo -e "${BOLD}=== Comparing PDF Output ===${RESET}"
    if ! compare_sizes "$REF_PDF" "$PDF_OUT" "PDF" 0.01; then
        ((failures++))
    fi

    # HTML comparison
    echo -e "\n${BOLD}=== Comparing HTML Output ===${RESET}"
    if ! compare_sizes "$REF_HTML" "$HTML_OUT" "HTML" 0.01; then
        ((failures++))
    fi

    if ! validate_html "$HTML_OUT"; then
        ((failures++))
    fi

    echo ""
    echo -e "${BOLD}=== Summary ===${RESET}"

    if (( failures > 0 )); then
        echo -e "${RED}${BOLD}FAILED${RESET} - $failures test(s) failed"
        echo ""
        exit 1
    else
        echo -e "${GREEN}${BOLD}PASSED${RESET} - All checks passed"
        echo ""
        exit 0
    fi
}

# Handle --generate flag
if [[ "${1:-}" == "--generate" ]]; then
    generate_references
    exit $?
fi

main "$@"
