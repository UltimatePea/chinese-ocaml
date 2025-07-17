#!/usr/bin/env python3

import os
import re
import sys

def analyze_ml_file(filepath):
    """Analyze an OCaml file for long functions."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except:
        return []
    
    functions = []
    current_function = None
    paren_count = 0
    brace_count = 0
    in_function = False
    
    for i, line in enumerate(lines, 1):
        line_stripped = line.strip()
        
        # Look for function definitions
        if re.match(r'^let\s+(rec\s+)?(\w+)', line_stripped):
            if current_function:
                functions.append(current_function)
            
            match = re.match(r'^let\s+(rec\s+)?(\w+)', line_stripped)
            func_name = match.group(2) if match else "unknown"
            current_function = {
                'name': func_name,
                'start_line': i,
                'end_line': i,
                'lines': [line]
            }
            in_function = True
            paren_count = line.count('(') - line.count(')')
            brace_count = line.count('{') - line.count('}')
        
        elif in_function:
            current_function['lines'].append(line)
            current_function['end_line'] = i
            paren_count += line.count('(') - line.count(')')
            brace_count += line.count('{') - line.count('}')
            
            # Simple heuristic: if we encounter another let at the same level
            if (line_stripped.startswith('let ') and 
                paren_count <= 0 and brace_count <= 0 and 
                not line_stripped.startswith('let (')):
                in_function = False
                if current_function:
                    functions.append(current_function)
                    current_function = None
    
    if current_function:
        functions.append(current_function)
    
    return functions

def main():
    src_dir = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    long_functions = []
    
    # Files to analyze (focus on the larger ones)
    files_to_analyze = [
        "rhyme_database.ml",
        "c_codegen_expressions.ml", 
        "Parser_expressions_advanced.ml",
        "Parser_expressions.ml",
        "builtin_functions.ml",
        "refactoring_analyzer.ml",
        "chinese_best_practices.ml",
        "poetry/tone_pattern.ml",
        "poetry/parallelism_analysis.ml",
        "poetry/artistic_evaluation.ml",
        "lexer_utils.ml",
        "compiler_errors.ml",
        "lexer.ml",
        "expression_evaluator.ml",
        "error_handler.ml",
        "parser.ml",
        "config.ml",
        "keyword_matcher.ml",
        "error_messages.ml"
    ]
    
    for filename in files_to_analyze:
        filepath = os.path.join(src_dir, filename)
        if os.path.exists(filepath):
            functions = analyze_ml_file(filepath)
            for func in functions:
                line_count = func['end_line'] - func['start_line'] + 1
                if line_count > 50:  # Consider functions over 50 lines as potentially long
                    long_functions.append({
                        'file': filename,
                        'function': func['name'],
                        'start_line': func['start_line'],
                        'end_line': func['end_line'],
                        'line_count': line_count
                    })
    
    # Sort by line count descending
    long_functions.sort(key=lambda x: x['line_count'], reverse=True)
    
    print("Long Functions Analysis Report")
    print("=" * 50)
    print(f"Found {len(long_functions)} functions over 50 lines:")
    print()
    
    for func in long_functions:
        print(f"File: {func['file']}")
        print(f"Function: {func['function']}")
        print(f"Lines: {func['start_line']}-{func['end_line']} ({func['line_count']} lines)")
        print("-" * 30)

if __name__ == "__main__":
    main()