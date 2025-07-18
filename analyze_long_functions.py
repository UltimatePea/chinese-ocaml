#!/usr/bin/env python3
"""
分析骆言项目中的长函数问题
"""

import os
import re
import subprocess
from typing import List, Dict, Tuple
from collections import defaultdict

def analyze_function_length(file_path: str) -> List[Dict]:
    """分析单个文件中的函数长度"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    functions = []
    current_function = None
    brace_count = 0
    paren_count = 0
    in_string = False
    string_char = None
    
    function_pattern = re.compile(r'^\s*let\s+(rec\s+)?(\w+(?:_\w+)*)\s*[=\(]')
    
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        
        # 跳过注释行
        if stripped.startswith('(*') or stripped.startswith('(**'):
            continue
            
        # 检查是否是函数定义开始
        match = function_pattern.match(line)
        if match and current_function is None:
            is_recursive = match.group(1) is not None
            function_name = match.group(2)
            current_function = {
                'name': function_name,
                'start_line': i,
                'is_recursive': is_recursive,
                'file': file_path
            }
            brace_count = 0
            paren_count = 0
        
        # 如果在函数内部，计算括号和大括号
        if current_function:
            # 简单的字符串检测
            j = 0
            while j < len(line):
                char = line[j]
                if not in_string:
                    if char == '"' or char == "'":
                        in_string = True
                        string_char = char
                    elif char == '(':
                        paren_count += 1
                    elif char == ')':
                        paren_count -= 1
                    elif char == '{':
                        brace_count += 1
                    elif char == '}':
                        brace_count -= 1
                else:
                    if char == string_char and (j == 0 or line[j-1] != '\\'):
                        in_string = False
                        string_char = None
                j += 1
            
            # 检查函数是否结束 - 简化逻辑
            # 对于OCaml，通常函数在下一个let或文件末尾结束
            if i < len(lines):
                next_line = lines[i] if i < len(lines) else ""
                if (next_line.strip().startswith('let ') or 
                    next_line.strip().startswith('and ') or 
                    next_line.strip().startswith('type ') or
                    next_line.strip().startswith('module ') or
                    next_line.strip().startswith('open ') or
                    i == len(lines)):
                    # 函数结束
                    current_function['end_line'] = i
                    current_function['length'] = i - current_function['start_line'] + 1
                    functions.append(current_function)
                    current_function = None
    
    # 处理文件末尾的函数
    if current_function:
        current_function['end_line'] = len(lines)
        current_function['length'] = len(lines) - current_function['start_line'] + 1
        functions.append(current_function)
    
    return functions

def find_ml_files(src_dir: str) -> List[str]:
    """找到所有.ml文件"""
    ml_files = []
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                ml_files.append(os.path.join(root, file))
    return ml_files

def analyze_all_functions(src_dir: str) -> Tuple[List[Dict], Dict]:
    """分析所有函数"""
    ml_files = find_ml_files(src_dir)
    all_functions = []
    stats = {
        'total_files': len(ml_files),
        'total_functions': 0,
        'long_functions': 0,
        'very_long_functions': 0,
        'extremely_long_functions': 0
    }
    
    for file_path in ml_files:
        functions = analyze_function_length(file_path)
        all_functions.extend(functions)
        
        for func in functions:
            stats['total_functions'] += 1
            if func['length'] > 50:
                stats['long_functions'] += 1
            if func['length'] > 100:
                stats['very_long_functions'] += 1
            if func['length'] > 200:
                stats['extremely_long_functions'] += 1
    
    return all_functions, stats

def generate_report(src_dir: str):
    """生成长函数分析报告"""
    print("=== 骆言项目长函数分析报告 ===")
    print()
    
    all_functions, stats = analyze_all_functions(src_dir)
    
    # 统计信息
    print("## 总体统计")
    print(f"- 总文件数: {stats['total_files']}")
    print(f"- 总函数数: {stats['total_functions']}")
    print(f"- 长函数(>50行): {stats['long_functions']}")
    print(f"- 很长函数(>100行): {stats['very_long_functions']}")
    print(f"- 极长函数(>200行): {stats['extremely_long_functions']}")
    print()
    
    # 按长度排序
    long_functions = [f for f in all_functions if f['length'] > 50]
    long_functions.sort(key=lambda x: x['length'], reverse=True)
    
    print("## 需要重构的长函数（>50行）")
    print()
    
    if long_functions:
        print("| 函数名 | 文件 | 行数 | 起始行 | 递归 |")
        print("|--------|------|------|--------|------|")
        
        for func in long_functions[:20]:  # 显示前20个最长的函数
            file_short = os.path.basename(func['file'])
            recursive = "是" if func['is_recursive'] else "否"
            print(f"| {func['name']} | {file_short} | {func['length']} | {func['start_line']} | {recursive} |")
    else:
        print("没有发现超过50行的长函数。")
    
    print()
    
    # 按文件分组统计
    file_stats = defaultdict(list)
    for func in long_functions:
        file_stats[func['file']].append(func)
    
    print("## 按文件分组的长函数分布")
    print()
    
    for file_path, functions in sorted(file_stats.items(), 
                                     key=lambda x: sum(f['length'] for f in x[1]), 
                                     reverse=True):
        file_short = os.path.basename(file_path)
        total_length = sum(f['length'] for f in functions)
        print(f"### {file_short}")
        print(f"- 长函数数量: {len(functions)}")
        print(f"- 总行数: {total_length}")
        print("- 函数列表:")
        for func in sorted(functions, key=lambda x: x['length'], reverse=True):
            print(f"  - {func['name']}: {func['length']}行 (第{func['start_line']}行开始)")
        print()

def main():
    src_directory = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    generate_report(src_directory)

if __name__ == "__main__":
    main()