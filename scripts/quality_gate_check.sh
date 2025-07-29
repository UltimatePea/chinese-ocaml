#!/bin/bash

# Quality Gate Check Script
# Author: Charlie, 规划代理
# Purpose: Enforce quality standards to prevent pseudo-refactoring

set -e

echo "🚦 Charlie Quality Gate Check Starting..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Quality gate settings
MAX_POETRY_FILES=150
MAX_TODO_COUNT=0
MAX_RHYME_FILES=50

# Count Poetry module files
poetry_files=$(find src/poetry -name "*.ml" -o -name "*.mli" 2>/dev/null | wc -l)
echo "📊 Poetry module files: $poetry_files"

# Count TODO markers
todo_count=$(grep -r "TODO" src/poetry 2>/dev/null | wc -l)
echo "📝 TODO markers found: $todo_count"

# Count rhyme-related files  
rhyme_files=$(find src/poetry -name "*rhyme*" -type f 2>/dev/null | wc -l)
echo "🎵 Rhyme-related files: $rhyme_files"

# Count data loader files
loader_files=$(find src/poetry -name "*loader*" -type f 2>/dev/null | wc -l)
echo "📤 Data loader files: $loader_files"

# Count small files (potentially empty implementations)
small_files=$(find src/poetry -name "*.ml" -exec wc -l {} \; 2>/dev/null | awk '$1 < 20 {count++} END {print count+0}')
echo "📄 Small files (<20 lines): $small_files"

echo ""
echo "🚦 Quality Gate Evaluation:"

# Check Poetry file count
if [ $poetry_files -gt $MAX_POETRY_FILES ]; then
    echo -e "${RED}❌ FAIL: Poetry module has $poetry_files files, exceeds limit of $MAX_POETRY_FILES${NC}"
    exit 1
else
    echo -e "${GREEN}✅ PASS: Poetry file count within limit ($poetry_files/$MAX_POETRY_FILES)${NC}"
fi

# Check TODO count
if [ $todo_count -gt $MAX_TODO_COUNT ]; then
    echo -e "${RED}❌ FAIL: Found $todo_count TODO markers, must be $MAX_TODO_COUNT${NC}"
    echo "📍 TODO locations:"
    grep -r "TODO" src/poetry 2>/dev/null | head -5
    exit 1
else
    echo -e "${GREEN}✅ PASS: No TODO markers found${NC}"
fi

# Check rhyme file proliferation  
if [ $rhyme_files -gt $MAX_RHYME_FILES ]; then
    echo -e "${YELLOW}⚠️  WARNING: $rhyme_files rhyme files found, target is $MAX_RHYME_FILES${NC}"
else
    echo -e "${GREEN}✅ PASS: Rhyme file count acceptable ($rhyme_files/$MAX_RHYME_FILES)${NC}"
fi

# Warning for small files (potential empty implementations)
if [ $small_files -gt 20 ]; then
    echo -e "${YELLOW}⚠️  WARNING: $small_files small files found, may indicate empty implementations${NC}"
fi

echo ""
echo "📊 Quality Metrics Summary:"
echo "  Poetry Files: $poetry_files (target: ≤$MAX_POETRY_FILES)"
echo "  TODO Markers: $todo_count (target: $MAX_TODO_COUNT)" 
echo "  Rhyme Files: $rhyme_files (target: ≤$MAX_RHYME_FILES)"
echo "  Data Loaders: $loader_files (target: ≤5)"
echo "  Small Files: $small_files (watch for empty implementations)"

echo ""
echo -e "${GREEN}🚦 Quality Gate: PASSED${NC}"
echo "✅ All mandatory quality standards met"

exit 0