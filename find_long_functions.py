#!/usr/bin/env python3
import os
import re
import glob

def find_long_functions(directory, min_lines=50):
    """Find functions longer than min_lines in OCaml files."""
    results = []
    
    for file_path in glob.glob(os.path.join(directory, "**/*.ml"), recursive=True):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            current_function = None
            function_start = 0
            brace_depth = 0
            
            for i, line in enumerate(lines):
                # Look for function definitions
                func_match = re.match(r'^\s*(let\s+(?:rec\s+)?([a-zA-Z_][a-zA-Z0-9_]*)|and\s+([a-zA-Z_][a-zA-Z0-9_]*))(?:\s|$|\s*=)', line)
                if func_match and brace_depth == 0:
                    # End previous function if exists
                    if current_function and i - function_start >= min_lines:
                        results.append((file_path, current_function, function_start + 1, i, i - function_start))
                    
                    # Start new function
                    current_function = func_match.group(2) or func_match.group(3)
                    function_start = i
                    brace_depth = 0
                
                # Count braces/parentheses to track function scope
                if current_function:
                    for char in line:
                        if char in '({[':
                            brace_depth += 1
                        elif char in ')}]':
                            brace_depth = max(0, brace_depth - 1)
            
            # Check last function
            if current_function and len(lines) - function_start >= min_lines:
                results.append((file_path, current_function, function_start + 1, len(lines), len(lines) - function_start))
                
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    return results

if __name__ == "__main__":
    directory = "src"
    long_functions = find_long_functions(directory, min_lines=50)
    
    # Sort by length descending
    long_functions.sort(key=lambda x: x[4], reverse=True)
    
    print("Extremely Long Functions (50+ lines):")
    print("=" * 60)
    for file_path, func_name, start_line, end_line, length in long_functions:
        print(f"{file_path}:")
        print(f"  Function: {func_name}")
        print(f"  Lines: {start_line}-{end_line} ({length} lines)")
        print()