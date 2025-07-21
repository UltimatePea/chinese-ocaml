#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import json
from typing import List, Tuple, Dict, Optional

def analyze_function_lines(file_content: str, file_path: str) -> List[Tuple[str, int, int, int]]:
    """分析文件中的函数，返回函数名、起始行、结束行、行数"""
    functions = []
    lines = file_content.split('\n')
    
    # OCaml函数定义的正则表达式模式
    # 匹配 let、let rec、和其他函数定义
    function_patterns = [
        r'^\s*let\s+(rec\s+)?([a-zA-Z_][a-zA-Z0-9_\']*)\s*[=\(]',
        r'^\s*and\s+([a-zA-Z_][a-zA-Z0-9_\']*)\s*[=\(]',
    ]
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        function_name = None
        
        # 检查是否是函数定义
        for pattern in function_patterns:
            match = re.match(pattern, lines[i])
            if match:
                if match.group(2) if len(match.groups()) > 1 else match.group(1):
                    function_name = match.group(2) if len(match.groups()) > 1 else match.group(1)
                    break
        
        if function_name:
            start_line = i + 1  # 行号从1开始
            
            # 寻找函数结束位置
            indent_level = len(lines[i]) - len(lines[i].lstrip())
            brace_count = 0
            paren_count = 0
            
            # 计算函数体中的括号和大括号
            for char in lines[i]:
                if char == '(':
                    paren_count += 1
                elif char == ')':
                    paren_count -= 1
                elif char == '{':
                    brace_count += 1
                elif char == '}':
                    brace_count -= 1
            
            j = i + 1
            while j < len(lines):
                current_line = lines[j]
                current_indent = len(current_line) - len(current_line.lstrip())
                
                # 更新括号计数
                for char in current_line:
                    if char == '(':
                        paren_count += 1
                    elif char == ')':
                        paren_count -= 1
                    elif char == '{':
                        brace_count += 1
                    elif char == '}':
                        brace_count -= 1
                
                # 检查函数结束条件
                if current_line.strip() == '':
                    j += 1
                    continue
                
                # 如果遇到新的let定义且缩进相同或更少，且括号平衡，则认为上一个函数结束
                if (current_indent <= indent_level and 
                    paren_count == 0 and brace_count == 0 and
                    (re.match(r'^\s*let\s+', current_line) or 
                     re.match(r'^\s*and\s+', current_line) or
                     re.match(r'^\s*type\s+', current_line) or
                     re.match(r'^\s*module\s+', current_line) or
                     re.match(r'^\s*exception\s+', current_line) or
                     current_line.strip().startswith('(*') or
                     j == len(lines) - 1)):
                    break
                
                j += 1
            
            end_line = j
            function_lines = end_line - start_line + 1
            
            # 只记录超过10行的函数（避免过多噪音）
            if function_lines >= 10:
                functions.append((function_name, start_line, end_line, function_lines))
        
        i += 1
    
    return functions

def analyze_directory(root_path: str, target_dirs: List[str]) -> Dict:
    """分析指定目录中的OCaml文件"""
    results = {
        'summary': {
            'total_files': 0,
            'total_functions': 0,
            'long_functions_50_plus': 0,
            'very_long_functions_100_plus': 0,
            'extreme_long_functions_200_plus': 0
        },
        'files': {}
    }
    
    for target_dir in target_dirs:
        full_path = os.path.join(root_path, target_dir)
        if not os.path.exists(full_path):
            continue
            
        for root, dirs, files in os.walk(full_path):
            for file in files:
                if file.endswith('.ml'):
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, root_path)
                    
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        
                        functions = analyze_function_lines(content, file_path)
                        if functions:
                            results['files'][rel_path] = {
                                'total_functions': len(functions),
                                'functions': []
                            }
                            
                            for func_name, start, end, lines in functions:
                                func_info = {
                                    'name': func_name,
                                    'start_line': start,
                                    'end_line': end,
                                    'lines': lines,
                                    'category': 'normal'
                                }
                                
                                if lines >= 200:
                                    func_info['category'] = 'extreme_long'
                                    results['summary']['extreme_long_functions_200_plus'] += 1
                                elif lines >= 100:
                                    func_info['category'] = 'very_long'
                                    results['summary']['very_long_functions_100_plus'] += 1
                                elif lines >= 50:
                                    func_info['category'] = 'long'
                                    results['summary']['long_functions_50_plus'] += 1
                                
                                results['files'][rel_path]['functions'].append(func_info)
                            
                            results['summary']['total_functions'] += len(functions)
                        
                        results['summary']['total_files'] += 1
                        
                    except Exception as e:
                        print(f"Error analyzing {file_path}: {e}")
    
    return results

def generate_report(results: Dict) -> str:
    """生成详细的分析报告"""
    report = []
    
    report.append("# OCaml项目超长函数分析报告")
    report.append("=" * 50)
    report.append("")
    
    # 总体统计
    summary = results['summary']
    report.append("## 总体统计")
    report.append(f"- 分析文件总数: {summary['total_files']}")
    report.append(f"- 函数总数: {summary['total_functions']}")
    report.append(f"- 超长函数(50+行): {summary['long_functions_50_plus']}")
    report.append(f"- 极长函数(100+行): {summary['very_long_functions_100_plus']}")
    report.append(f"- 超极长函数(200+行): {summary['extreme_long_functions_200_plus']}")
    report.append("")
    
    # 按类别分组
    long_functions = []
    very_long_functions = []
    extreme_long_functions = []
    
    for file_path, file_info in results['files'].items():
        for func in file_info['functions']:
            func_data = (file_path, func)
            if func['category'] == 'extreme_long':
                extreme_long_functions.append(func_data)
            elif func['category'] == 'very_long':
                very_long_functions.append(func_data)
            elif func['category'] == 'long':
                long_functions.append(func_data)
    
    # 按行数排序
    extreme_long_functions.sort(key=lambda x: x[1]['lines'], reverse=True)
    very_long_functions.sort(key=lambda x: x[1]['lines'], reverse=True)
    long_functions.sort(key=lambda x: x[1]['lines'], reverse=True)
    
    if extreme_long_functions:
        report.append("## 🔴 超极长函数 (200+行) - 急需重构")
        for file_path, func in extreme_long_functions:
            report.append(f"- **{func['name']}** ({file_path})")
            report.append(f"  - 行数: {func['lines']} 行 ({func['start_line']}-{func['end_line']})")
            report.append(f"  - 优先级: **极高**")
        report.append("")
    
    if very_long_functions:
        report.append("## 🟠 极长函数 (100-199行) - 强烈建议重构")
        for file_path, func in very_long_functions:
            report.append(f"- **{func['name']}** ({file_path})")
            report.append(f"  - 行数: {func['lines']} 行 ({func['start_line']}-{func['end_line']})")
            report.append(f"  - 优先级: **高**")
        report.append("")
    
    if long_functions:
        report.append("## 🟡 长函数 (50-99行) - 建议重构")
        for file_path, func in long_functions:
            report.append(f"- **{func['name']}** ({file_path})")
            report.append(f"  - 行数: {func['lines']} 行 ({func['start_line']}-{func['end_line']})")
            report.append(f"  - 优先级: **中等**")
        report.append("")
    
    # 按模块分组统计
    report.append("## 按模块分组统计")
    module_stats = {}
    for file_path, file_info in results['files'].items():
        module_name = os.path.dirname(file_path) if os.path.dirname(file_path) else "根目录"
        if module_name not in module_stats:
            module_stats[module_name] = {
                'files': 0,
                'total_functions': 0,
                'long_functions': 0,
                'very_long_functions': 0,
                'extreme_long_functions': 0
            }
        
        module_stats[module_name]['files'] += 1
        module_stats[module_name]['total_functions'] += file_info['total_functions']
        
        for func in file_info['functions']:
            if func['category'] == 'extreme_long':
                module_stats[module_name]['extreme_long_functions'] += 1
            elif func['category'] == 'very_long':
                module_stats[module_name]['very_long_functions'] += 1
            elif func['category'] == 'long':
                module_stats[module_name]['long_functions'] += 1
    
    for module_name, stats in sorted(module_stats.items()):
        if stats['long_functions'] > 0 or stats['very_long_functions'] > 0 or stats['extreme_long_functions'] > 0:
            report.append(f"### {module_name}")
            report.append(f"- 文件数: {stats['files']}")
            report.append(f"- 总函数数: {stats['total_functions']}")
            if stats['extreme_long_functions'] > 0:
                report.append(f"- 🔴 超极长函数: {stats['extreme_long_functions']}")
            if stats['very_long_functions'] > 0:
                report.append(f"- 🟠 极长函数: {stats['very_long_functions']}")
            if stats['long_functions'] > 0:
                report.append(f"- 🟡 长函数: {stats['long_functions']}")
            report.append("")
    
    # 重构建议
    report.append("## 重构建议")
    report.append("1. **超极长函数(200+行)**: 立即拆分，应用单一职责原则")
    report.append("2. **极长函数(100-199行)**: 分解为多个小函数，提取公共逻辑")
    report.append("3. **长函数(50-99行)**: 考虑拆分，增强可读性和可维护性")
    report.append("")
    
    report.append("## 技术建议")
    report.append("- 使用数据外化技术处理大量重复数据")
    report.append("- 提取公共函数减少代码重复")
    report.append("- 应用策略模式处理复杂条件逻辑")
    report.append("- 使用模块化设计分离关注点")
    
    return "\n".join(report)

def main():
    root_path = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml"
    target_dirs = [
        "src",
        "src/poetry", 
        "src/chinese_best_practices",
        "src/config"
    ]
    
    print("开始分析OCaml项目中的超长函数...")
    results = analyze_directory(root_path, target_dirs)
    
    # 生成报告
    report = generate_report(results)
    
    # 保存到文件
    output_file = os.path.join(root_path, "超长函数详细分析报告.md")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"分析完成！报告已保存到: {output_file}")
    
    # 同时输出到控制台
    print("\n" + report)
    
    # 保存JSON数据用于后续处理
    json_file = os.path.join(root_path, "long_functions_analysis_results.json")
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"详细数据已保存到: {json_file}")

if __name__ == "__main__":
    main()