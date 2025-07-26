#!/usr/bin/env python3
"""
测试多函数边界检测的具体问题
"""

import sys
sys.path.append('/home/zc/chinese-ocaml-worktrees/chinese-ocaml/scripts/analysis')

from ast_based_analysis import ASTBasedAnalyzer

def test_multifunction_detection():
    analyzer = ASTBasedAnalyzer("/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src")
    
    # 问题测试用例
    test_code = """let complex_function x y =
  match x with
  | Some v -> v + y
  | None -> y

let another_func z = z * 2"""
    
    print("测试代码:")
    for i, line in enumerate(test_code.split('\n'), 1):
        print(f"{i:2}: {line}")
    print()
    
    functions = analyzer.parse_functions_improved(test_code)
    print(f"检测到的函数数量: {len(functions)}")
    
    for i, func in enumerate(functions, 1):
        print(f"函数 {i}: {func['name']} (第 {func.get('start_line', '?')} 行 - 第 {func.get('end_line', '?')} 行)")
        print(f"  长度: {func.get('length', '?')} 行")
    
    print()
    print("期望: 2个函数")
    print("- complex_function (行 1-5)")  
    print("- another_func (行 7)")

if __name__ == "__main__":
    test_multifunction_detection()