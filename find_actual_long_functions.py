#!/usr/bin/env python3

import re
import os

def find_function_boundaries(lines, start_line):
    """Find the end of a function definition by counting balanced parentheses and other constructs"""
    
    # Simple approach: find the next function definition
    current_line = start_line
    
    # Count various brackets
    paren_count = 0
    in_string = False
    in_comment = False
    
    for i in range(start_line, len(lines)):
        line = lines[i].strip()
        
        # Skip empty lines
        if not line:
            continue
            
        # Check for next function definition
        if i > start_line and (line.startswith('let ') or line.startswith('and ')):
            return i - 1
            
        # Look for structural markers that indicate function end
        if line.startswith('(* ') or line.startswith('(** '):
            # Start of another function or module
            if i > start_line + 3:  # Allow some buffer
                return i - 1
                
        current_line = i
    
    return current_line

def analyze_file(filepath):
    """Analyze a single OCaml file for long functions"""
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return []
    
    functions = []
    
    for i, line in enumerate(lines):
        # Match function definitions
        match = re.match(r'^(let\s+(rec\s+)?|and\s+)([a-zA-Z_][a-zA-Z0-9_\']*)', line.strip())
        if match:
            func_name = match.group(3)
            
            # Find function end
            end_line = find_function_boundaries(lines, i)
            
            # Count actual lines of code (excluding comments and empty lines)
            func_lines = lines[i:end_line + 1]
            code_lines = []
            
            for func_line in func_lines:
                stripped = func_line.strip()
                # Skip empty lines
                if not stripped:
                    continue
                # Skip comment lines
                if stripped.startswith('(*') or stripped.startswith('(*'):
                    continue
                code_lines.append(stripped)
            
            total_lines = end_line - i + 1
            code_line_count = len(code_lines)
            
            # Only include functions that are reasonably long
            if total_lines >= 20 or code_line_count >= 15:
                functions.append({
                    'name': func_name,
                    'file': filepath,
                    'start_line': i + 1,
                    'end_line': end_line + 1,
                    'total_lines': total_lines,
                    'code_lines': code_line_count
                })
    
    return functions

def main():
    # Target the largest files
    target_files = [
        'src/parser_expressions.ml',
        'src/config.ml',
        'src/keyword_matcher.ml',
        'src/lexer.ml',
        'src/parser.ml',
        'src/semantic_statements.ml',
        'src/parser_statements.ml',
        'src/c_codegen.ml',
        'src/expression_evaluator.ml',
        'src/interpreter.ml',
        'src/types.ml',
        'src/compiler.ml',
        'src/semantic.ml',
        'src/ast.ml',
        'src/refactoring_analyzer.ml'
    ]
    
    all_functions = []
    
    for filepath in target_files:
        if os.path.exists(filepath):
            print(f"Analyzing {filepath}...")
            functions = analyze_file(filepath)
            all_functions.extend(functions)
    
    # Sort by code lines (descending)
    all_functions.sort(key=lambda x: x['code_lines'], reverse=True)
    
    print(f"\nFound {len(all_functions)} functions with 15+ lines of code")
    
    # Show functions with 50+ lines of code
    long_functions = [f for f in all_functions if f['code_lines'] >= 50]
    
    if long_functions:
        print(f"\nFunctions with 50+ lines of code:")
        print("-" * 80)
        for func in long_functions:
            print(f"{func['name']:<25} {func['file']:<35} {func['start_line']:<6} {func['end_line']:<6} {func['total_lines']:<6} {func['code_lines']:<6}")
    else:
        print("\nNo functions found with 50+ lines of code")
    
    # Show top 15 longest functions
    print(f"\nTop 15 longest functions:")
    print("-" * 80)
    print(f"{'Function':<25} {'File':<35} {'Start':<6} {'End':<6} {'Total':<6} {'Code':<6}")
    print("-" * 80)
    
    for func in all_functions[:15]:
        filename = func['file'].replace('src/', '')
        print(f"{func['name']:<25} {filename:<35} {func['start_line']:<6} {func['end_line']:<6} {func['total_lines']:<6} {func['code_lines']:<6}")

if __name__ == '__main__':
    main()