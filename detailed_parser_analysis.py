#!/usr/bin/env python3
"""
更详细的解析器函数依赖关系分析
"""

import re
import sys

def extract_function_definitions(content):
    """提取所有函数定义及其内容"""
    
    # 找到互相递归块的开始
    recursive_start = content.find('let rec parse_expression')
    if recursive_start == -1:
        print("找不到递归块开始")
        return {}
    
    # 找到递归块的结束
    rest_content = content[recursive_start:]
    next_let_match = re.search(r'\nlet\s+(?!rec)', rest_content)
    if next_let_match:
        recursive_end = recursive_start + next_let_match.start()
        recursive_block = content[recursive_start:recursive_end]
    else:
        recursive_block = rest_content
    
    functions = {}
    
    # 分割函数定义
    # 首先匹配 "let rec parse_expression"
    first_func_match = re.match(r'let\s+rec\s+(parse_\w+)(.*?)(?=and\s+parse_|\Z)', recursive_block, re.DOTALL)
    if first_func_match:
        func_name = first_func_match.group(1)
        func_body = first_func_match.group(2)
        functions[func_name] = func_body.strip()
    
    # 然后匹配所有 "and parse_xxx" 函数
    and_matches = re.finditer(r'and\s+(parse_\w+)(.*?)(?=and\s+parse_|\Z)', recursive_block, re.DOTALL)
    for match in and_matches:
        func_name = match.group(1)
        func_body = match.group(2)
        functions[func_name] = func_body.strip()
    
    return functions

def analyze_dependencies(functions):
    """分析函数依赖关系"""
    dependencies = {}
    
    for func_name, func_body in functions.items():
        # 查找所有对其他parse_函数的调用
        parse_calls = re.findall(r'\bparse_\w+', func_body)
        
        # 过滤掉自己，只保留在functions中定义的函数
        called_funcs = []
        for call in parse_calls:
            if call != func_name and call in functions:
                called_funcs.append(call)
        
        # 去重并排序
        dependencies[func_name] = sorted(list(set(called_funcs)))
    
    return dependencies

def find_strongly_connected_components(dependencies):
    """查找强连通分量（真正需要互相递归的函数组）"""
    # 简化版的Tarjan算法概念实现
    
    # 构建反向图
    reverse_deps = {}
    for func in dependencies:
        reverse_deps[func] = []
    
    for func, deps in dependencies.items():
        for dep in deps:
            if dep in reverse_deps:
                reverse_deps[dep].append(func)
    
    # 查找互相调用的函数对
    mutual_pairs = []
    for func, deps in dependencies.items():
        for dep in deps:
            if func in dependencies.get(dep, []):
                pair = tuple(sorted([func, dep]))
                if pair not in mutual_pairs:
                    mutual_pairs.append(pair)
    
    return mutual_pairs

def categorize_functions(functions):
    """按功能分类函数"""
    categories = {
        '模式解析': [],
        '类型解析': [],
        '表达式解析核心': [],
        '表达式解析专门': [],
        '自然语言解析': [],
        '古雅体解析': [],
        '文言风格解析': [],
        '运算符优先级解析': [],
        '记录和数组': [],
        '控制流': [],
        '模块和签名': [],
        '辅助函数': []
    }
    
    for func_name in functions:
        if 'pattern' in func_name:
            categories['模式解析'].append(func_name)
        elif 'type' in func_name and not 'module_type' in func_name:
            categories['类型解析'].append(func_name)
        elif 'natural' in func_name:
            categories['自然语言解析'].append(func_name)
        elif 'ancient' in func_name:
            categories['古雅体解析'].append(func_name)
        elif 'wenyan' in func_name:
            categories['文言风格解析'].append(func_name)
        elif any(x in func_name for x in ['arithmetic', 'multiplicative', 'comparison', 'or_', 'and_']):
            categories['运算符优先级解析'].append(func_name)
        elif any(x in func_name for x in ['record', 'array', 'list']):
            categories['记录和数组'].append(func_name)
        elif any(x in func_name for x in ['conditional', 'match', 'try', 'raise']):
            categories['控制流'].append(func_name)
        elif any(x in func_name for x in ['module', 'signature']):
            categories['模块和签名'].append(func_name)
        elif func_name in ['parse_expression', 'parse_assignment_expression', 'parse_or_else_expression', 
                          'parse_unary_expression', 'parse_primary_expression']:
            categories['表达式解析核心'].append(func_name)
        else:
            if any(x in func_name for x in ['function', 'let', 'combine', 'postfix', 'ref']):
                categories['表达式解析专门'].append(func_name)
            else:
                categories['辅助函数'].append(func_name)
    
    return categories

def main():
    with open('/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser.ml', 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("=== 骆言语法分析器函数依赖关系分析报告 ===\n")
    
    functions = extract_function_definitions(content)
    print(f"互相递归块中共有 {len(functions)} 个函数")
    
    dependencies = analyze_dependencies(functions)
    
    # 1. 列出所有函数
    print("\n=== 1. 所有函数列表 ===")
    for i, func in enumerate(sorted(functions.keys()), 1):
        print(f"{i:2d}. {func}")
    
    # 2. 分析依赖关系
    print("\n=== 2. 函数依赖关系详情 ===")
    for func in sorted(dependencies.keys()):
        deps = dependencies[func]
        print(f"\n{func}:")
        if deps:
            for dep in deps:
                print(f"  ├─ {dep}")
        else:
            print("  └─ 无依赖")
    
    # 3. 查找真正的互相递归
    print("\n=== 3. 真正的互相递归函数对 ===")
    mutual_pairs = find_strongly_connected_components(dependencies)
    if mutual_pairs:
        for pair in mutual_pairs:
            print(f"  {pair[0]} ↔ {pair[1]}")
    else:
        print("  未发现直接的互相递归函数对")
    
    # 4. 查找叶子函数（可能可以独立提取）
    print("\n=== 4. 可独立提取的候选函数 ===")
    
    # 被其他函数调用的函数
    called_by_others = set()
    for deps in dependencies.values():
        called_by_others.update(deps)
    
    # 叶子函数：不被其他函数调用
    leaf_functions = [func for func in functions if func not in called_by_others]
    
    print("叶子函数（不被其他函数调用）:")
    for func in sorted(leaf_functions):
        deps = dependencies[func]
        print(f"  - {func}")
        if deps:
            print(f"    依赖: {', '.join(deps)}")
        else:
            print("    无依赖")
    
    # 无依赖函数
    no_deps = [func for func, deps in dependencies.items() if not deps]
    print(f"\n无依赖函数（可直接独立）: {len(no_deps)} 个")
    for func in sorted(no_deps):
        print(f"  - {func}")
    
    # 5. 按功能分类
    print("\n=== 5. 函数功能分类 ===")
    categories = categorize_functions(functions)
    
    for category, funcs in categories.items():
        if funcs:
            print(f"\n{category} ({len(funcs)} 个):")
            for func in sorted(funcs):
                deps_count = len(dependencies[func])
                print(f"  - {func} (依赖 {deps_count} 个函数)")
    
    # 6. 重构建议
    print("\n=== 6. 重构建议 ===")
    
    print("\n第一阶段 - 可独立提取的函数组:")
    
    # 无依赖函数组
    if no_deps:
        print(f"\n1. 完全独立的函数 ({len(no_deps)} 个):")
        print("   这些函数不依赖任何其他解析函数，可以直接提取:")
        for func in sorted(no_deps):
            print(f"   - {func}")
    
    # 类型解析组
    type_funcs = categories['类型解析']
    if type_funcs:
        print(f"\n2. 类型解析函数组 ({len(type_funcs)} 个):")
        print("   这些函数主要处理类型表达式，依赖关系简单:")
        for func in sorted(type_funcs):
            deps = dependencies[func]
            if deps:
                print(f"   - {func} -> {', '.join(deps)}")
            else:
                print(f"   - {func} (无依赖)")
    
    # 模式解析组
    pattern_funcs = categories['模式解析']
    if pattern_funcs:
        print(f"\n3. 模式解析函数组 ({len(pattern_funcs)} 个):")
        print("   这些函数处理模式匹配，形成相对独立的子系统:")
        for func in sorted(pattern_funcs):
            deps = dependencies[func]
            pattern_deps = [d for d in deps if d in pattern_funcs]
            non_pattern_deps = [d for d in deps if d not in pattern_funcs]
            if pattern_deps and non_pattern_deps:
                print(f"   - {func} -> 内部:{', '.join(pattern_deps)} | 外部:{', '.join(non_pattern_deps)}")
            elif pattern_deps:
                print(f"   - {func} -> 内部:{', '.join(pattern_deps)}")
            elif non_pattern_deps:
                print(f"   - {func} -> 外部:{', '.join(non_pattern_deps)}")
            else:
                print(f"   - {func} (无依赖)")
    
    print("\n第二阶段 - 专门功能模块:")
    
    # 自然语言解析
    natural_funcs = categories['自然语言解析']
    if natural_funcs:
        print(f"\n4. 自然语言解析模块 ({len(natural_funcs)} 个):")
        print("   这些函数处理自然语言风格的函数定义:")
        for func in sorted(natural_funcs):
            deps = dependencies[func]
            natural_deps = [d for d in deps if d in natural_funcs]
            if natural_deps:
                print(f"   - {func} -> {', '.join(natural_deps)}")
            else:
                print(f"   - {func}")
    
    # 古雅体解析
    ancient_funcs = categories['古雅体解析']
    if ancient_funcs:
        print(f"\n5. 古雅体解析模块 ({len(ancient_funcs)} 个):")
        for func in sorted(ancient_funcs):
            deps = dependencies[func]
            ancient_deps = [d for d in deps if d in ancient_funcs]
            if ancient_deps:
                print(f"   - {func} -> {', '.join(ancient_deps)}")
            else:
                print(f"   - {func}")

if __name__ == "__main__":
    main()