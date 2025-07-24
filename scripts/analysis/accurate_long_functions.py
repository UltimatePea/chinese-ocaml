#!/usr/bin/env python3
"""
Accurate analysis of functions longer than 50 lines in the src/ directory.
This script properly parses OCaml function boundaries.
"""

import os
import re
import sys

def analyze_file(filepath):
    """Analyze a single OCaml file for functions longer than 50 lines."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return []
    
    long_functions = []
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # Look for function definitions: let [rec] function_name parameters = 
        func_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_][a-zA-Z0-9_\']*)\s*.*=', lines[i])
        if func_match:
            func_name = func_match.group(2)
            start_line = i + 1
            
            # Find the end of this function by looking for the next top-level definition
            # or end of file
            j = i + 1
            indentation_level = get_indentation_level(lines[i])
            
            # Skip the function definition line and look for the end
            while j < len(lines):
                current_line = lines[j].strip()
                
                # Skip empty lines and comments
                if not current_line or current_line.startswith('(*') or current_line.startswith('(**'):
                    j += 1
                    continue
                
                current_indentation = get_indentation_level(lines[j])
                
                # Check if this is a new top-level definition at the same or lesser indentation
                if current_indentation <= indentation_level:
                    # Check for next function, type, or module definition
                    if (re.match(r'^let\s+(rec\s+)?[a-zA-Z_]', lines[j]) or
                        re.match(r'^type\s+', lines[j]) or
                        re.match(r'^module\s+', lines[j]) or
                        re.match(r'^val\s+', lines[j]) or
                        re.match(r'^exception\s+', lines[j])):
                        break
                
                j += 1
            
            # Calculate actual function length
            end_line = j
            func_length = end_line - i
            
            # Only include functions longer than 50 lines
            if func_length > 50:
                long_functions.append({
                    'name': func_name,
                    'start_line': start_line,
                    'end_line': end_line,
                    'length': func_length,
                    'file': filepath
                })
            
            i = j
        else:
            i += 1
    
    return long_functions

def get_indentation_level(line):
    """Get the indentation level of a line."""
    return len(line) - len(line.lstrip())

def main():
    src_dir = "src"
    if not os.path.exists(src_dir):
        print(f"Directory {src_dir} not found")
        return
    
    all_long_functions = []
    
    # Walk through all .ml files
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                filepath = os.path.join(root, file)
                long_functions = analyze_file(filepath)
                all_long_functions.extend(long_functions)
    
    # Sort by length (longest first)
    all_long_functions.sort(key=lambda x: x['length'], reverse=True)
    
    print(f"Found {len(all_long_functions)} functions longer than 50 lines:")
    print("=" * 80)
    
    for func in all_long_functions:
        print(f"File: {func['file']}")
        print(f"Function: {func['name']}")
        print(f"Lines: {func['start_line']}-{func['end_line']} ({func['length']} lines)")
        print("-" * 40)

if __name__ == "__main__":
    main()