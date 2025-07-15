#!/usr/bin/env python3
"""
解析器函数依赖关系分析脚本
"""

import re
import sys

def analyze_parser_functions(filename):
    """分析parser.ml中的函数依赖关系"""
    
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 找到互相递归块的开始和结束
    recursive_start = content.find('let rec parse_expression')
    if recursive_start == -1:
        print("找不到递归块开始")
        return
    
    # 找到递归块的结束（下一个let定义）
    rest_content = content[recursive_start:]
    next_let_match = re.search(r'\nlet\s+(?!rec)', rest_content)
    if next_let_match:
        recursive_end = recursive_start + next_let_match.start()
        recursive_block = content[recursive_start:recursive_end]
    else:
        recursive_block = rest_content
    
    # 提取所有函数定义
    function_pattern = r'(?:let\s+rec|and)\s+(parse_\w+)'
    functions = re.findall(function_pattern, recursive_block)
    
    print("=== 互相递归块中的函数列表 ===")
    for i, func in enumerate(functions, 1):
        print(f"{i:2d}. {func}")
    
    print(f"\n总共 {len(functions)} 个函数")
    
    # 分析每个函数的依赖关系
    print("\n=== 函数依赖关系分析 ===")
    dependencies = {}
    
    for func in functions:
        # 找到这个函数的定义
        func_pattern = rf'(?:let\s+rec|and)\s+{re.escape(func)}\s+.*?(?=(?:and\s+parse_|\nlet\s+|$))'
        func_match = re.search(func_pattern, recursive_block, re.DOTALL)
        
        if func_match:
            func_body = func_match.group(0)
            
            # 找到所有被调用的parse_函数
            called_funcs = re.findall(r'parse_\w+', func_body)
            
            # 过滤掉自己和不在递归块中的函数
            called_funcs = [f for f in called_funcs if f != func and f in functions]
            
            # 去重并排序
            called_funcs = sorted(list(set(called_funcs)))
            
            dependencies[func] = called_funcs
            
            print(f"\n{func}:")
            if called_funcs:
                for called in called_funcs:
                    print(f"  -> {called}")
            else:
                print("  -> 无依赖")
    
    # 分析哪些函数可能可以独立提取
    print("\n=== 可能可以独立提取的函数 ===")
    
    # 被其他函数调用的函数
    called_by_others = set()
    for deps in dependencies.values():
        called_by_others.update(deps)
    
    # 只调用其他函数但不被调用的函数（叶子函数）
    leaf_functions = []
    for func in functions:
        if func not in called_by_others:
            leaf_functions.append(func)
    
    print("叶子函数（不被其他函数调用）:")
    for func in leaf_functions:
        print(f"  - {func}")
        if dependencies[func]:
            print(f"    依赖: {', '.join(dependencies[func])}")
    
    # 分析函数组
    print("\n=== 函数分组建议 ===")
    
    # 模式解析相关
    pattern_funcs = [f for f in functions if 'pattern' in f]
    print(f"模式解析组: {pattern_funcs}")
    
    # 类型解析相关
    type_funcs = [f for f in functions if 'type' in f]
    print(f"类型解析组: {type_funcs}")
    
    # 表达式解析相关
    expr_funcs = [f for f in functions if 'expression' in f]
    print(f"表达式解析组: {expr_funcs}")
    
    # 自然语言相关
    natural_funcs = [f for f in functions if 'natural' in f]
    print(f"自然语言解析组: {natural_funcs}")
    
    # 古雅体相关
    ancient_funcs = [f for f in functions if 'ancient' in f]
    print(f"古雅体解析组: {ancient_funcs}")
    
    # 文言相关
    wenyan_funcs = [f for f in functions if 'wenyan' in f]
    print(f"文言解析组: {wenyan_funcs}")

if __name__ == "__main__":
    analyze_parser_functions("/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser.ml")