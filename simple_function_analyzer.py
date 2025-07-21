#!/usr/bin/env python3
"""
简化版本的骆言项目超长函数分析脚本
"""

import os

def analyze_file(file_path):
    """分析单个文件中的函数长度"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        return []
    
    functions = []
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # 简单的函数检测 - 查找 let 开头的行
        if line.startswith('let ') and '=' in line:
            func_name = line.split()[1].split('=')[0].strip()
            start_line = i + 1
            
            # 简单的函数结束检测 - 找到下一个顶层定义或文件结束
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if (next_line.startswith('let ') or 
                    next_line.startswith('and ') or
                    next_line.startswith('type ') or
                    next_line.startswith('module ') or
                    next_line.startswith('exception ') or
                    next_line.startswith('val ')):
                    break
                j += 1
            
            end_line = j if j < len(lines) else len(lines)
            line_count = end_line - i
            
            if line_count >= 50:  # 超过50行的函数
                functions.append({
                    'name': func_name,
                    'file': file_path,
                    'start_line': start_line,
                    'end_line': end_line,
                    'line_count': line_count
                })
            
            i = j
        else:
            i += 1
    
    return functions

def main():
    src_dir = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    all_functions = []
    
    # 遍历src目录
    for root, dirs, files in os.walk(src_dir):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for file in files:
            if file.endswith('.ml'):
                file_path = os.path.join(root, file)
                functions = analyze_file(file_path)
                all_functions.extend(functions)
    
    # 按行数排序
    all_functions.sort(key=lambda f: f['line_count'], reverse=True)
    
    print(f"发现 {len(all_functions)} 个超过50行的函数:")
    print("=" * 80)
    
    for i, func in enumerate(all_functions[:15], 1):  # 显示前15个
        rel_path = os.path.relpath(func['file'], src_dir)
        print(f"{i:2d}. {func['name']} ({rel_path})")
        print(f"    行数: {func['line_count']}行 (第{func['start_line']}-{func['end_line']}行)")
        print()

if __name__ == "__main__":
    main()