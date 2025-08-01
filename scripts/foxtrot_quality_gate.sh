#!/bin/bash
# Foxtrot Quality Gate Check System
# Author: Foxtrot, Project Overseer
# Purpose: Mandatory quality validation for all agent deliverables

set -e

echo "🛡️ Foxtrot Quality Gate Check System"
echo "======================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

QUALITY_GATE_PASSED=true

# Function to log results
log_check() {
    local status=$1
    local message=$2
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $message"
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}❌ FAIL${NC}: $message"
        QUALITY_GATE_PASSED=false
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠️  WARN${NC}: $message"
    fi
}

echo "📊 Phase 1: Technical Baseline Validation"
echo "------------------------------------------"

# Check 1: Poetry Module Count Accuracy
echo "🔍 Checking Poetry module count accuracy..."
POETRY_MODULE_COUNT=$(find . -path "*/poetry/*" -name "*.ml" | wc -l)
echo "   Found $POETRY_MODULE_COUNT Poetry modules"

if [ "$POETRY_MODULE_COUNT" -eq 666 ]; then
    log_check "PASS" "Poetry module count matches expected 666 modules"
elif [ "$POETRY_MODULE_COUNT" -eq 201 ]; then
    log_check "FAIL" "Poetry module count shows old incorrect baseline (201). Agent using outdated information."
else
    log_check "WARN" "Poetry module count ($POETRY_MODULE_COUNT) differs from expected 666. Needs verification."
fi

# Check 2: Build System Integrity
echo "🔨 Checking build system integrity..."
if dune build > /dev/null 2>&1; then
    BUILD_TIME=$(time dune build 2>&1 | grep real | awk '{print $2}' || echo "unknown")
    log_check "PASS" "Project builds successfully (time: $BUILD_TIME)"
else
    log_check "FAIL" "Project build failed. Code changes broke compilation."
fi

echo ""
echo "🔧 Phase 2: Tool Executability Validation"
echo "------------------------------------------"

# Check 3: Python Tool Validation
echo "🐍 Checking Python tools executability..."
if [ -f "dependency_analyzer.py" ]; then
    if python3 dependency_analyzer.py --test > /dev/null 2>&1; then
        log_check "PASS" "Python dependency analyzer is executable"
    else
        log_check "FAIL" "Python dependency analyzer fails to execute properly"
    fi
else
    log_check "WARN" "No dependency_analyzer.py found - may not be applicable"
fi

# Check 4: Analysis Results Sanity Check
echo "📈 Checking analysis results sanity..."
if [ -f "poetry_dependency_analysis.json" ]; then
    DEPENDENCY_COUNT=$(grep -o '"dependencies"' poetry_dependency_analysis.json | wc -l || echo "0")
    if [ "$DEPENDENCY_COUNT" -lt 10 ]; then
        log_check "FAIL" "Dependency analysis shows suspiciously low count ($DEPENDENCY_COUNT). Likely incomplete analysis."
    elif [ "$DEPENDENCY_COUNT" -gt 1000 ]; then
        log_check "WARN" "Dependency analysis shows very high count ($DEPENDENCY_COUNT). May include indirect dependencies."
    else
        log_check "PASS" "Dependency analysis shows reasonable count ($DEPENDENCY_COUNT)"
    fi
else
    log_check "WARN" "No poetry_dependency_analysis.json found - may not be applicable"
fi

echo ""
echo "📋 Phase 3: Documentation and Completeness"
echo "-------------------------------------------"

# Check 5: Documentation Requirements
echo "📝 Checking documentation completeness..."
RECENT_DOCS=$(find . -name "*.md" -newer $(find . -name "*.ml" | head -1) | wc -l)
if [ "$RECENT_DOCS" -gt 0 ]; then
    log_check "PASS" "Found recent documentation updates ($RECENT_DOCS files)"
else
    log_check "WARN" "No recent documentation updates found"
fi

# Check 6: Test Coverage (if available)
echo "🧪 Checking test coverage..."
if command -v bisect-ppx-report > /dev/null 2>&1; then
    COVERAGE=$(bisect-ppx-report summary 2>/dev/null | grep -o '[0-9]*\.[0-9]*%' | head -1 || echo "unknown")
    if [ "$COVERAGE" != "unknown" ]; then
        COVERAGE_NUM=$(echo $COVERAGE | sed 's/%//')
        if (( $(echo "$COVERAGE_NUM > 70" | bc -l 2>/dev/null || echo "0") )); then
            log_check "PASS" "Test coverage is adequate ($COVERAGE)"
        else
            log_check "WARN" "Test coverage could be improved ($COVERAGE)"
        fi
    else
        log_check "WARN" "Test coverage information not available"
    fi
else
    log_check "WARN" "Test coverage tools not available"
fi

echo ""
echo "🎯 Phase 4: Project Alignment Check"
echo "------------------------------------"

# Check 7: Chinese Poetry Language Mission Alignment
echo "🎭 Checking project mission alignment..."
if grep -q "诗词\|poetry\|rhyme\|韵律" $(find . -name "*.ml" -newer $(date -d "1 day ago" +%Y-%m-%d) 2>/dev/null | head -5) 2>/dev/null; then
    log_check "PASS" "Recent changes maintain Chinese poetry language focus"
else
    log_check "WARN" "Recent changes may lack clear Chinese poetry language focus"
fi

# Check 8: OCaml Code Quality
echo "🧹 Checking OCaml code quality..."
if command -v ocamlformat > /dev/null 2>&1; then
    UNFORMATTED=$(find . -name "*.ml" -exec ocamlformat --check {} \; 2>&1 | wc -l || echo "0")
    if [ "$UNFORMATTED" -eq 0 ]; then
        log_check "PASS" "OCaml code formatting is consistent"
    else
        log_check "WARN" "Some OCaml files may need formatting ($UNFORMATTED issues)"
    fi
else
    log_check "WARN" "OCaml formatting tools not available"
fi

echo ""
echo "📊 Quality Gate Summary"
echo "======================="

if [ "$QUALITY_GATE_PASSED" = true ]; then
    echo -e "${GREEN}🎉 QUALITY GATE PASSED${NC}"
    echo "✅ All critical checks passed. Work meets Foxtrot quality standards."
    echo "📋 Agent deliverable is approved for merge and further processing."
    exit 0
else
    echo -e "${RED}🚫 QUALITY GATE FAILED${NC}"
    echo "❌ Critical issues found. Work does not meet Foxtrot quality standards."
    echo "🔄 Agent must address failures before resubmission."
    echo ""
    echo "📞 Contact Foxtrot for guidance on resolving quality issues."
    exit 1
fi