#!/usr/bin/env python3
"""
调试函数边界检测的详细过程
"""

import sys
import re
sys.path.append('/home/zc/chinese-ocaml-worktrees/chinese-ocaml/scripts/analysis')

def debug_function_boundary_detailed():
    test_code = """let complex_function x y =
  match x with
  | Some v -> v + y
  | None -> y

let another_func z = z * 2"""
    
    lines = test_code.split('\n')
    print("调试函数边界检测过程:")
    print("=" * 50)
    
    for i, line in enumerate(lines):
        print(f"行 {i}: '{line}'")
    
    print("\n开始分析第一个函数 'complex_function':")
    print("=" * 50)
    
    start_idx = 0
    first_line = lines[start_idx]
    base_indent = len(first_line) - len(first_line.lstrip())
    print(f"起始行 {start_idx}: '{first_line}', 基础缩进: {base_indent}")
    
    paren_depth = 0
    bracket_depth = 0
    brace_depth = 0
    in_match = False
    in_string = False
    in_let_expression = False
    
    for i in range(start_idx + 1, len(lines)):
        line = lines[i]
        stripped = line.strip()
        current_indent = len(line) - len(line.lstrip())
        
        print(f"\n分析行 {i}: '{line}'")
        print(f"  stripped: '{stripped}'")
        print(f"  当前缩进: {current_indent}, 基础缩进: {base_indent}")
        
        if not stripped:
            print("  -> 空行，跳过")
            continue
        
        # 字符级分析
        old_paren_depth = paren_depth
        for char in stripped:
            if char == '"' and not in_string:
                in_string = True
            elif char == '"' and in_string:
                in_string = False
            elif not in_string:
                if char == '(':
                    paren_depth += 1
                elif char == ')':
                    paren_depth -= 1
                elif char == '[':
                    bracket_depth += 1
                elif char == ']':
                    bracket_depth -= 1
                elif char == '{':
                    brace_depth += 1
                elif char == '}':
                    brace_depth -= 1
        
        if paren_depth != old_paren_depth:
            print(f"  括号深度变化: {old_paren_depth} -> {paren_depth}")
        
        # match检测
        if re.search(r'\bmatch\b.*\bwith\b', stripped):
            in_match = True
            print("  -> 检测到match表达式开始")
        
        # let表达式检测
        if re.match(r'^\s+let\s+', line):
            in_let_expression = True
            print("  -> 检测到let表达式")
        elif stripped.startswith('in') and in_let_expression:
            in_let_expression = False
            print("  -> let表达式结束")
        
        # 顶层定义检测
        is_top_level_definition = (
            current_indent <= base_indent and 
            paren_depth == 0 and bracket_depth == 0 and brace_depth == 0 and
            not in_match and not in_let_expression and
            re.match(r'^(let|type|module|open|exception|val)', stripped)
        )
        
        print(f"  状态: paren={paren_depth}, bracket={bracket_depth}, brace={brace_depth}")
        print(f"  状态: in_match={in_match}, in_let_expr={in_let_expression}")
        print(f"  是否顶层定义: {is_top_level_definition}")
        
        if is_top_level_definition:
            print(f"  -> 找到新的顶层定义，函数在行 {i-1} 结束")
            return i - 1
        
        # match结构结束检测
        if in_match and current_indent <= base_indent and not re.search(r'^\s*\|', stripped):
            in_match = False
            print("  -> match表达式结束")
    
    print(f"\n到达文件末尾，函数在行 {len(lines)-1} 结束")
    return len(lines) - 1

if __name__ == "__main__":
    debug_function_boundary_detailed()