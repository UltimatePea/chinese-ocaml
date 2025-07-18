#!/usr/bin/env python3
"""
分析骆言项目中的错误处理不一致性问题
"""

import os
import re
from typing import List, Dict, Set, Tuple
from collections import defaultdict

def analyze_error_patterns(file_path: str) -> Dict:
    """分析单个文件中的错误处理模式"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return {}
    
    patterns = {
        'raise_patterns': [],
        'failwith_patterns': [],
        'invalid_arg_patterns': [],
        'result_patterns': [],
        'option_patterns': [],
        'try_catch_patterns': [],
        'exception_definitions': [],
        'error_functions': []
    }
    
    lines = content.split('\n')
    
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        
        # 查找各种错误处理模式
        if 'raise' in stripped:
            patterns['raise_patterns'].append({
                'line': i,
                'content': stripped,
                'type': extract_raise_type(stripped)
            })
        
        if 'failwith' in stripped:
            patterns['failwith_patterns'].append({
                'line': i,
                'content': stripped
            })
        
        if 'invalid_arg' in stripped:
            patterns['invalid_arg_patterns'].append({
                'line': i,
                'content': stripped
            })
        
        if re.search(r'\bResult\.\w+', stripped):
            patterns['result_patterns'].append({
                'line': i,
                'content': stripped,
                'result_type': extract_result_type(stripped)
            })
        
        if re.search(r'\bSome\b|\bNone\b', stripped):
            patterns['option_patterns'].append({
                'line': i,
                'content': stripped
            })
        
        if 'try' in stripped and ('with' in stripped or 'catch' in stripped):
            patterns['try_catch_patterns'].append({
                'line': i,
                'content': stripped
            })
        
        if 'exception' in stripped.lower():
            patterns['exception_definitions'].append({
                'line': i,
                'content': stripped
            })
        
        if re.search(r'_error|error_|Error\w+', stripped):
            patterns['error_functions'].append({
                'line': i,
                'content': stripped
            })
    
    return patterns

def extract_raise_type(line: str) -> str:
    """提取raise语句中的异常类型"""
    if 'RuntimeError' in line:
        return 'RuntimeError'
    elif 'SyntaxError' in line:
        return 'SyntaxError'
    elif 'TypeError' in line:
        return 'TypeError'
    elif 'ValueError' in line:
        return 'ValueError'
    elif 'InvalidArgument' in line:
        return 'InvalidArgument'
    else:
        # 尝试提取其他异常类型
        match = re.search(r'raise\s+\(?(\w+)', line)
        if match:
            return match.group(1)
        return 'Unknown'

def extract_result_type(line: str) -> str:
    """提取Result类型的使用模式"""
    if 'Result.Ok' in line:
        return 'Ok'
    elif 'Result.Error' in line:
        return 'Error'
    elif 'Result.is_ok' in line:
        return 'is_ok'
    elif 'Result.is_error' in line:
        return 'is_error'
    else:
        return 'Other'

def find_ml_files(src_dir: str) -> List[str]:
    """找到所有.ml文件"""
    ml_files = []
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                ml_files.append(os.path.join(root, file))
    return ml_files

def analyze_error_consistency(src_dir: str):
    """分析错误处理一致性"""
    ml_files = find_ml_files(src_dir)
    
    # 收集所有错误处理模式
    all_patterns = {
        'raise_types': defaultdict(int),
        'result_usage': defaultdict(int),
        'error_styles': defaultdict(list),
        'inconsistencies': []
    }
    
    file_patterns = {}
    
    for file_path in ml_files:
        patterns = analyze_error_patterns(file_path)
        file_patterns[file_path] = patterns
        
        # 统计异常类型
        for raise_pattern in patterns['raise_patterns']:
            all_patterns['raise_types'][raise_pattern['type']] += 1
        
        # 统计Result使用模式
        for result_pattern in patterns['result_patterns']:
            all_patterns['result_usage'][result_pattern['result_type']] += 1
        
        # 收集错误处理风格
        file_short = os.path.basename(file_path)
        error_styles = []
        
        if patterns['raise_patterns']:
            error_styles.append('raise')
        if patterns['failwith_patterns']:
            error_styles.append('failwith')
        if patterns['result_patterns']:
            error_styles.append('Result')
        if patterns['option_patterns']:
            error_styles.append('Option')
        if patterns['try_catch_patterns']:
            error_styles.append('try_catch')
        
        if error_styles:
            all_patterns['error_styles'][tuple(sorted(error_styles))].append(file_short)
    
    return all_patterns, file_patterns

def generate_error_consistency_report(src_dir: str):
    """生成错误处理一致性分析报告"""
    print("=== 骆言项目错误处理一致性分析报告 ===")
    print()
    
    all_patterns, file_patterns = analyze_error_consistency(src_dir)
    
    # 总体统计
    total_files = len([f for f in file_patterns.values() if any(len(patterns) > 0 for patterns in f.values())])
    
    print("## 总体统计")
    print(f"- 含错误处理的文件数: {total_files}")
    print(f"- 异常类型种类: {len(all_patterns['raise_types'])}")
    print(f"- 错误处理风格组合: {len(all_patterns['error_styles'])}")
    print()
    
    # 异常类型分布
    print("## 异常类型使用分布")
    print()
    print("| 异常类型 | 使用次数 |")
    print("|----------|----------|")
    for exc_type, count in sorted(all_patterns['raise_types'].items(), key=lambda x: x[1], reverse=True):
        print(f"| {exc_type} | {count} |")
    print()
    
    # Result类型使用模式
    print("## Result类型使用模式")
    print()
    if all_patterns['result_usage']:
        print("| Result模式 | 使用次数 |")
        print("|------------|----------|")
        for result_type, count in sorted(all_patterns['result_usage'].items(), key=lambda x: x[1], reverse=True):
            print(f"| {result_type} | {count} |")
    else:
        print("项目中很少使用Result类型进行错误处理。")
    print()
    
    # 错误处理风格组合分析
    print("## 错误处理风格组合分析")
    print()
    print("| 错误处理风格组合 | 文件数量 | 代表文件 |")
    print("|------------------|----------|----------|")
    
    for style_combo, files in sorted(all_patterns['error_styles'].items(), 
                                   key=lambda x: len(x[1]), reverse=True):
        style_str = ", ".join(style_combo)
        file_count = len(files)
        representative_files = ", ".join(files[:3])  # 显示前3个文件
        if len(files) > 3:
            representative_files += f" (+{len(files)-3}个)"
        print(f"| {style_str} | {file_count} | {representative_files} |")
    print()
    
    # 不一致性问题分析
    print("## 错误处理不一致性问题")
    print()
    
    inconsistencies = []
    
    # 检查混合使用多种错误处理方式的文件
    mixed_style_files = []
    for file_path, patterns in file_patterns.items():
        error_methods = 0
        methods_used = []
        
        if patterns['raise_patterns']:
            error_methods += 1
            methods_used.append('raise')
        if patterns['failwith_patterns']:
            error_methods += 1
            methods_used.append('failwith')
        if patterns['result_patterns']:
            error_methods += 1
            methods_used.append('Result')
        
        if error_methods > 2:  # 使用超过2种错误处理方式
            mixed_style_files.append({
                'file': os.path.basename(file_path),
                'methods': methods_used,
                'count': error_methods
            })
    
    if mixed_style_files:
        print("### 混合错误处理风格的文件")
        print()
        print("| 文件名 | 错误处理方式 | 方式数量 |")
        print("|--------|-------------|----------|")
        for item in sorted(mixed_style_files, key=lambda x: x['count'], reverse=True):
            methods_str = ", ".join(item['methods'])
            print(f"| {item['file']} | {methods_str} | {item['count']} |")
        print()
    
    # 检查异常类型不统一问题
    if len(all_patterns['raise_types']) > 5:
        print("### 异常类型过多问题")
        print()
        print(f"项目中使用了{len(all_patterns['raise_types'])}种不同的异常类型，建议统一为几种核心异常类型。")
        print()
    
    # 建议
    print("## 改进建议")
    print()
    print("### 高优先级建议")
    print("1. **统一核心异常类型**: 将异常类型统一为3-5种核心类型（如RuntimeError、SyntaxError、TypeError）")
    print("2. **建立错误处理规范**: 为不同类型的错误建立统一的处理模式")
    print("3. **重构混合风格文件**: 优先重构使用多种错误处理方式的文件")
    print()
    
    print("### 中优先级建议")
    print("4. **引入Result类型**: 在合适的地方使用Result类型替代异常")
    print("5. **错误消息国际化**: 统一错误消息的格式和语言")
    print("6. **添加错误恢复机制**: 为关键错误添加恢复策略")
    print()

if __name__ == "__main__":
    src_directory = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    generate_error_consistency_report(src_directory)