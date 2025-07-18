#!/usr/bin/env python3
"""
分析骆言项目中的深层嵌套问题
"""

import os
import re
from typing import List, Dict, Tuple
from collections import defaultdict

def analyze_nesting_depth(file_path: str) -> List[Dict]:
    """分析单个文件中的嵌套深度"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    nesting_issues = []
    current_depth = 0
    max_depth = 0
    depth_stack = []
    
    for i, line in enumerate(lines, 1):
        original_line = line
        line = line.strip()
        
        # 跳过注释和空行
        if line.startswith('(*') or line.startswith('(**') or not line:
            continue
        
        # 计算当前行的缩进级别
        indent_level = len(original_line) - len(original_line.lstrip())
        
        # 检查各种嵌套结构
        nesting_change = calculate_nesting_change(line)
        current_depth += nesting_change
        max_depth = max(max_depth, current_depth)
        
        # 检查特定的深嵌套模式
        deep_nesting_indicators = check_deep_nesting_indicators(line, indent_level)
        
        if deep_nesting_indicators or current_depth > 4:
            context_lines = get_context_lines(lines, i-1, 3)
            nesting_issues.append({
                'line': i,
                'content': line,
                'depth': current_depth,
                'indent_level': indent_level // 2,  # 假设每层缩进2个空格
                'nesting_type': deep_nesting_indicators or 'general_deep',
                'context': context_lines,
                'file': file_path
            })
    
    # 只返回真正的深嵌套问题（深度>4或缩进>6级）
    return [issue for issue in nesting_issues 
            if issue['depth'] > 4 or issue['indent_level'] > 6]

def calculate_nesting_change(line: str) -> int:
    """计算行中嵌套深度的变化"""
    depth_change = 0
    
    # 计算括号
    depth_change += line.count('(') - line.count(')')
    depth_change += line.count('[') - line.count(']')
    depth_change += line.count('{') - line.count('}')
    
    # 检查控制结构
    if re.search(r'\bif\b|\bmatch\b|\blet\b|\btry\b|\bbegin\b', line):
        depth_change += 1
    
    if re.search(r'\belse\b|\bend\b|\bdone\b', line):
        depth_change -= 1
    
    return depth_change

def check_deep_nesting_indicators(line: str, indent_level: int) -> str:
    """检查特定的深嵌套指示器"""
    if indent_level > 24:  # 超过12级缩进（假设每级2个空格）
        return 'excessive_indentation'
    
    # 检查嵌套的if语句
    if re.search(r'\bif\b.*\bif\b', line):
        return 'nested_if'
    
    # 检查嵌套的match语句
    if re.search(r'\bmatch\b.*\bmatch\b', line):
        return 'nested_match'
    
    # 检查深度嵌套的函数调用
    paren_count = line.count('(')
    if paren_count > 4:
        return 'deep_function_calls'
    
    # 检查复杂的模式匹配
    if re.search(r'\|\s*\w+\s*\(\s*\w+\s*\(\s*\w+', line):
        return 'complex_pattern_nesting'
    
    return ""

def get_context_lines(lines: List[str], center: int, radius: int) -> List[str]:
    """获取指定行周围的上下文"""
    start = max(0, center - radius)
    end = min(len(lines), center + radius + 1)
    return [f"{i+1}: {lines[i].rstrip()}" for i in range(start, end)]

def find_ml_files(src_dir: str) -> List[str]:
    """找到所有.ml文件"""
    ml_files = []
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                ml_files.append(os.path.join(root, file))
    return ml_files

def generate_nesting_report(src_dir: str):
    """生成深层嵌套分析报告"""
    print("=== 骆言项目深层嵌套问题分析报告 ===")
    print()
    
    ml_files = find_ml_files(src_dir)
    all_nesting_issues = []
    
    for file_path in ml_files:
        issues = analyze_nesting_depth(file_path)
        all_nesting_issues.extend(issues)
    
    # 统计信息
    total_issues = len(all_nesting_issues)
    high_depth_issues = [issue for issue in all_nesting_issues if issue['depth'] > 6]
    excessive_indent_issues = [issue for issue in all_nesting_issues if issue['indent_level'] > 8]
    
    print("## 总体统计")
    print(f"- 总文件数: {len(ml_files)}")
    print(f"- 深层嵌套问题总数: {total_issues}")
    print(f"- 极深嵌套(>6层): {len(high_depth_issues)}")
    print(f"- 过度缩进(>8级): {len(excessive_indent_issues)}")
    print()
    
    if all_nesting_issues:
        # 按深度排序
        all_nesting_issues.sort(key=lambda x: (x['depth'], x['indent_level']), reverse=True)
        
        print("## 需要重构的深层嵌套问题")
        print()
        print("| 文件 | 行号 | 嵌套深度 | 缩进级别 | 问题类型 | 代码片段 |")
        print("|------|------|----------|----------|----------|----------|")
        
        for issue in all_nesting_issues[:15]:  # 显示前15个最严重的问题
            file_short = os.path.basename(issue['file'])
            code_snippet = issue['content'][:50] + "..." if len(issue['content']) > 50 else issue['content']
            nesting_type = issue['nesting_type']
            print(f"| {file_short} | {issue['line']} | {issue['depth']} | {issue['indent_level']} | {nesting_type} | {code_snippet} |")
        
        print()
        
        # 按文件分组
        file_stats = defaultdict(list)
        for issue in all_nesting_issues:
            file_stats[issue['file']].append(issue)
        
        print("## 按文件分组的深层嵌套问题分布")
        print()
        
        for file_path, issues in sorted(file_stats.items(), 
                                       key=lambda x: len(x[1]), 
                                       reverse=True):
            file_short = os.path.basename(file_path)
            max_depth = max(issue['depth'] for issue in issues)
            max_indent = max(issue['indent_level'] for issue in issues)
            
            print(f"### {file_short}")
            print(f"- 深层嵌套问题数量: {len(issues)}")
            print(f"- 最大嵌套深度: {max_depth}")
            print(f"- 最大缩进级别: {max_indent}")
            print("- 问题详情:")
            
            for issue in sorted(issues, key=lambda x: x['depth'], reverse=True)[:5]:
                print(f"  - 第{issue['line']}行: 深度{issue['depth']}, 缩进{issue['indent_level']}级, 类型{issue['nesting_type']}")
            
            if len(issues) > 5:
                print(f"  - 还有{len(issues) - 5}个其他问题...")
            print()
        
        # 问题类型分析
        type_stats = defaultdict(int)
        for issue in all_nesting_issues:
            type_stats[issue['nesting_type']] += 1
        
        print("## 深层嵌套问题类型分析")
        print()
        print("| 问题类型 | 出现次数 | 描述 |")
        print("|----------|----------|------|")
        
        type_descriptions = {
            'excessive_indentation': '过度缩进',
            'nested_if': '嵌套if语句',
            'nested_match': '嵌套match语句', 
            'deep_function_calls': '深度函数调用',
            'complex_pattern_nesting': '复杂模式嵌套',
            'general_deep': '一般深层嵌套'
        }
        
        for nesting_type, count in sorted(type_stats.items(), key=lambda x: x[1], reverse=True):
            description = type_descriptions.get(nesting_type, '未知类型')
            print(f"| {nesting_type} | {count} | {description} |")
        
        print()
    else:
        print("没有发现严重的深层嵌套问题。")
    
    # 改进建议
    print("## 改进建议")
    print()
    print("### 高优先级建议")
    print("1. **提取嵌套函数**: 将深层嵌套的逻辑提取为独立的辅助函数")
    print("2. **简化条件逻辑**: 使用早期返回和guard语句减少嵌套")
    print("3. **重构复杂模式匹配**: 将复杂的match语句拆分为多个简单的匹配")
    print()
    
    print("### 中优先级建议")
    print("4. **使用管道操作**: 在适当的地方使用管道操作符减少嵌套")
    print("5. **模块化重构**: 将复杂的函数拆分为多个小模块")
    print("6. **引入设计模式**: 使用访问者模式等减少深层嵌套")
    print()

if __name__ == "__main__":
    src_directory = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    generate_nesting_report(src_directory)