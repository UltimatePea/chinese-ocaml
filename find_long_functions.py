#!/usr/bin/env python3
"""
查找OCaml源代码中的长函数
Find long functions in OCaml source code
"""

import os
import re
import sys
from typing import List, Tuple, Dict

def count_lines_in_function(lines: List[str], start_line: int) -> int:
    """计算函数的行数"""
    count = 0
    paren_depth = 0
    brace_depth = 0
    in_string = False
    escape_next = False
    
    for i in range(start_line, len(lines)):
        line = lines[i].strip()
        count += 1
        
        # 简单的字符串处理
        j = 0
        while j < len(line):
            char = line[j]
            
            if escape_next:
                escape_next = False
                j += 1
                continue
                
            if char == '\\' and in_string:
                escape_next = True
                j += 1
                continue
                
            if char == '"' and not in_string:
                in_string = True
            elif char == '"' and in_string:
                in_string = False
            elif not in_string:
                if char == '(':
                    paren_depth += 1
                elif char == ')':
                    paren_depth -= 1
                elif char == '{':
                    brace_depth += 1
                elif char == '}':
                    brace_depth -= 1
            
            j += 1
        
        # 如果到达了函数的结尾（平衡的括号和大括号），停止计数
        if paren_depth == 0 and brace_depth == 0 and count > 5:
            # 检查是否是函数结尾的模式
            if (line.endswith(';;') or 
                line.endswith(')') or 
                (i < len(lines) - 1 and lines[i+1].strip().startswith('let ')) or
                (i < len(lines) - 1 and lines[i+1].strip().startswith('(** ')) or
                (i < len(lines) - 1 and lines[i+1].strip().startswith('type ')) or
                (i == len(lines) - 1)):
                break
    
    return count

def find_long_functions(file_path: str, min_lines: int = 100) -> List[Tuple[str, int, int]]:
    """查找文件中的长函数"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return []
    
    long_functions = []
    
    # 函数定义的正则表达式模式
    patterns = [
        r'^\s*let\s+rec\s+(\w+)',  # let rec function_name
        r'^\s*let\s+(\w+)\s*.*=.*fun',  # let function_name = fun
        r'^\s*let\s+(\w+)\s*.*=.*function',  # let function_name = function
        r'^\s*let\s+(\w+)\s*\(.*\)\s*=',  # let function_name(args) =
        r'^\s*and\s+(\w+)',  # and function_name
    ]
    
    for i, line in enumerate(lines):
        for pattern in patterns:
            match = re.match(pattern, line)
            if match:
                function_name = match.group(1)
                
                # 计算函数的行数
                function_lines = count_lines_in_function(lines, i)
                
                if function_lines >= min_lines:
                    long_functions.append((function_name, i + 1, function_lines))
    
    return long_functions

def analyze_function_complexity(file_path: str, func_name: str, start_line: int, num_lines: int) -> Dict:
    """分析函数的复杂度"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        return {}
    
    end_line = min(start_line + num_lines - 1, len(lines))
    function_lines = lines[start_line-1:end_line]
    
    complexity = {
        'nested_match': 0,
        'nested_if': 0,
        'pattern_matches': 0,
        'function_calls': 0,
        'complex_expressions': 0,
    }
    
    for line in function_lines:
        line_str = line.strip()
        
        # 计算嵌套的match表达式
        if 'match' in line_str and 'with' in line_str:
            complexity['nested_match'] += 1
        
        # 计算嵌套的if表达式
        if line_str.startswith('if ') or ' if ' in line_str:
            complexity['nested_if'] += 1
        
        # 计算模式匹配
        if '|' in line_str and '->' in line_str:
            complexity['pattern_matches'] += 1
        
        # 计算函数调用
        complexity['function_calls'] += line_str.count('(')
        
        # 计算复杂表达式
        if any(op in line_str for op in ['&&', '||', 'List.', 'String.', 'Printf.']):
            complexity['complex_expressions'] += 1
    
    return complexity

def main():
    if len(sys.argv) > 1:
        min_lines = int(sys.argv[1])
    else:
        min_lines = 100
    
    src_dir = "src"
    if not os.path.exists(src_dir):
        print(f"Source directory '{src_dir}' not found")
        sys.exit(1)
    
    all_long_functions = []
    
    # 遍历src目录下的所有.ml文件
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                file_path = os.path.join(root, file)
                long_functions = find_long_functions(file_path, min_lines)
                
                if long_functions:
                    all_long_functions.extend([(file_path, func_name, line_num, num_lines) 
                                             for func_name, line_num, num_lines in long_functions])
    
    # 按行数排序
    all_long_functions.sort(key=lambda x: x[3], reverse=True)
    
    if not all_long_functions:
        print(f"No functions longer than {min_lines} lines found.")
        return
    
    print(f"Found {len(all_long_functions)} functions longer than {min_lines} lines:\n")
    print("=" * 80)
    
    for file_path, func_name, line_num, num_lines in all_long_functions:
        rel_path = os.path.relpath(file_path)
        print(f"File: {rel_path}")
        print(f"Function: {func_name}")
        print(f"Line: {line_num}")
        print(f"Lines: {num_lines}")
        
        # 分析复杂度
        complexity = analyze_function_complexity(file_path, func_name, line_num, num_lines)
        if complexity:
            print(f"Complexity metrics:")
            print(f"  - Nested match expressions: {complexity['nested_match']}")
            print(f"  - Nested if expressions: {complexity['nested_if']}")
            print(f"  - Pattern matches: {complexity['pattern_matches']}")
            print(f"  - Function calls: {complexity['function_calls']}")
            print(f"  - Complex expressions: {complexity['complex_expressions']}")
        
        print("-" * 80)

if __name__ == "__main__":
    main()