#!/usr/bin/env python3
"""
Systematic search for long OCaml functions in the codebase.
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Tuple, Dict

def count_lines_in_function(lines: List[str], start_idx: int, function_name: str) -> int:
    """Count lines in a function starting from the let declaration."""
    current_idx = start_idx
    indent_level = 0
    paren_level = 0
    bracket_level = 0
    brace_level = 0
    in_string = False
    string_char = None
    
    while current_idx < len(lines):
        line = lines[current_idx].strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('(*'):
            current_idx += 1
            continue
            
        # Track string boundaries
        i = 0
        while i < len(line):
            char = line[i]
            if not in_string:
                if char == '"' or char == "'":
                    in_string = True
                    string_char = char
                elif char == '(':
                    paren_level += 1
                elif char == ')':
                    paren_level -= 1
                elif char == '[':
                    bracket_level += 1
                elif char == ']':
                    bracket_level -= 1
                elif char == '{':
                    brace_level += 1
                elif char == '}':
                    brace_level -= 1
            else:
                if char == string_char and (i == 0 or line[i-1] != '\\'):
                    in_string = False
                    string_char = None
            i += 1
        
        # Check for function end conditions
        if not in_string and paren_level == 0 and bracket_level == 0 and brace_level == 0:
            # Check if we hit a new top-level declaration
            if (line.startswith('let ') or 
                line.startswith('val ') or 
                line.startswith('type ') or 
                line.startswith('module ') or 
                line.startswith('open ') or
                line.startswith('exception ')):
                if current_idx > start_idx:  # Don't count the starting line itself
                    break
        
        current_idx += 1
    
    return current_idx - start_idx

def find_long_functions_in_file(file_path: str, min_lines: int = 100) -> List[Tuple[str, int, str]]:
    """Find long functions in a single OCaml file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return []
    
    long_functions = []
    
    for i, line in enumerate(lines):
        # Look for function definitions
        line_stripped = line.strip()
        
        # Match various function definition patterns
        let_match = re.match(r'let\s+(\w+)', line_stripped)
        let_rec_match = re.match(r'let\s+rec\s+(\w+)', line_stripped)
        
        if let_match or let_rec_match:
            func_name = let_match.group(1) if let_match else let_rec_match.group(1)
            
            # Count lines in this function
            line_count = count_lines_in_function(lines, i, func_name)
            
            if line_count >= min_lines:
                # Get a brief description of why it's long
                description = analyze_function_complexity(lines, i, line_count)
                long_functions.append((func_name, line_count, description))
    
    return long_functions

def analyze_function_complexity(lines: List[str], start_idx: int, line_count: int) -> str:
    """Analyze why a function is long and provide a brief description."""
    reasons = []
    
    # Count nested levels
    max_indent = 0
    match_count = 0
    if_count = 0
    loop_count = 0
    
    for i in range(start_idx, min(start_idx + line_count, len(lines))):
        line = lines[i]
        indent = len(line) - len(line.lstrip())
        max_indent = max(max_indent, indent)
        
        line_stripped = line.strip()
        if 'match' in line_stripped:
            match_count += 1
        if line_stripped.startswith('if ') or ' if ' in line_stripped:
            if_count += 1
        if 'for ' in line_stripped or 'while ' in line_stripped:
            loop_count += 1
    
    # Determine complexity reasons
    if max_indent > 20:
        reasons.append("deep nesting")
    if match_count > 5:
        reasons.append("many pattern matches")
    if if_count > 10:
        reasons.append("many conditionals")
    if loop_count > 3:
        reasons.append("multiple loops")
    
    # Check for repetitive patterns
    if line_count > 200:
        reasons.append("very long implementation")
    elif line_count > 150:
        reasons.append("long implementation")
    
    if not reasons:
        reasons.append("complex logic")
    
    return ", ".join(reasons)

def main():
    src_dir = Path("src")
    if not src_dir.exists():
        print("src directory not found")
        return
    
    print("Searching for OCaml functions longer than 100 lines...")
    print("=" * 80)
    
    total_long_functions = 0
    
    # Find all .ml files in src directory
    for ml_file in src_dir.glob("**/*.ml"):
        # Skip generated files and data files
        if (any(part.startswith("_build") for part in ml_file.parts) or
            ml_file.suffix == ".pp.ml" or
            "data" in str(ml_file).lower()):
            continue
        
        long_functions = find_long_functions_in_file(str(ml_file))
        
        if long_functions:
            print(f"\n📁 {ml_file}")
            print("-" * 50)
            
            for func_name, line_count, description in long_functions:
                print(f"  🔍 {func_name}")
                print(f"      Lines: {line_count}")
                print(f"      Issues: {description}")
                print()
                total_long_functions += 1
    
    print("=" * 80)
    print(f"Total long functions found: {total_long_functions}")
    
    if total_long_functions == 0:
        print("✅ No functions longer than 100 lines found!")
    else:
        print(f"⚠️  Found {total_long_functions} functions that may benefit from refactoring")

if __name__ == "__main__":
    main()