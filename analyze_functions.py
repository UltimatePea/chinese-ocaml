#!/usr/bin/env python3
"""
分析OCaml源代码中的函数长度，找出需要重构的超长函数
"""

import os
import re
import sys
from collections import defaultdict

def count_function_lines(content, filename):
    """分析函数长度，返回函数名和行数的列表"""
    lines = content.split('\n')
    functions = []
    
    # 匹配let函数定义的正则表达式
    let_pattern = re.compile(r'^\s*let\s+(rec\s+)?([a-zA-Z_][a-zA-Z0-9_]*)')
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # 跳过注释行
        if line.startswith('(*') or line.startswith('(**') or not line:
            i += 1
            continue
            
        # 匹配let函数定义
        match = let_pattern.match(lines[i])
        if match:
            func_name = match.group(2)
            start_line = i + 1  # 1-based line numbers
            
            # 计算函数体的行数
            brace_count = 0
            paren_count = 0
            func_lines = 0
            j = i
            
            while j < len(lines):
                current_line = lines[j].strip()
                
                # 简单的括号匹配来确定函数结束
                for char in current_line:
                    if char == '(':
                        paren_count += 1
                    elif char == ')':
                        paren_count -= 1
                        
                func_lines += 1
                j += 1
                
                # 简单启发式：如果遇到下一个顶级let定义，认为函数结束
                if j < len(lines):
                    next_line = lines[j].strip()
                    if (next_line.startswith('let ') and 
                        not next_line.startswith('let (') and
                        paren_count == 0 and
                        func_lines > 3):  # 至少3行才算一个函数
                        break
                        
                # 如果到文件末尾，也结束
                if j >= len(lines):
                    break
                    
            # 只记录超过10行的函数
            if func_lines > 10:
                functions.append((func_name, func_lines, start_line, filename))
            
            i = j
        else:
            i += 1
    
    return functions

def analyze_ocaml_files(src_dir):
    """分析src目录下所有.ml文件"""
    all_functions = []
    
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        functions = count_function_lines(content, filepath)
                        all_functions.extend(functions)
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
    
    return all_functions

def main():
    src_dir = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    
    print("🔍 分析OCaml源代码中的函数长度...")
    print("=" * 60)
    
    functions = analyze_ocaml_files(src_dir)
    
    # 按行数排序
    functions.sort(key=lambda x: x[1], reverse=True)
    
    print(f"\n📊 发现 {len(functions)} 个超过10行的函数")
    print("\n🚨 最长的20个函数：")
    print("-" * 80)
    print(f"{'函数名':<30} {'行数':<8} {'起始行':<8} {'文件':<30}")
    print("-" * 80)
    
    for i, (name, lines, start_line, filename) in enumerate(functions[:20]):
        short_filename = os.path.basename(filename)
        print(f"{name:<30} {lines:<8} {start_line:<8} {short_filename:<30}")
    
    # 统计超长函数（>30行）
    long_functions = [f for f in functions if f[1] > 30]
    if long_functions:
        print(f"\n⚠️  发现 {len(long_functions)} 个超过30行的超长函数，需要重构：")
        print("-" * 80)
        for name, lines, start_line, filename in long_functions:
            short_filename = os.path.basename(filename)
            print(f"  • {name} ({lines}行) - {short_filename}:{start_line}")
    else:
        print("\n✅ 没有发现超过30行的超长函数！")
    
    # 按文件统计
    print(f"\n📁 按文件统计长函数分布：")
    print("-" * 60)
    
    file_stats = defaultdict(list)
    for name, lines, start_line, filename in functions:
        short_filename = os.path.basename(filename)
        file_stats[short_filename].append((name, lines))
    
    # 按每个文件的函数数量排序
    sorted_files = sorted(file_stats.items(), key=lambda x: len(x[1]), reverse=True)
    
    for filename, func_list in sorted_files[:10]:
        avg_lines = sum(lines for _, lines in func_list) / len(func_list)
        print(f"  {filename:<25} {len(func_list)} 个函数 (平均 {avg_lines:.1f} 行)")

if __name__ == "__main__":
    main()