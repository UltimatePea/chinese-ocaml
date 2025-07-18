#!/usr/bin/env python3
"""
分析骆言项目中的复杂模式匹配问题
"""

import os
import re
from typing import List, Dict, Tuple
from collections import defaultdict

def analyze_complex_patterns(file_path: str) -> List[Dict]:
    """分析单个文件中的复杂模式匹配"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    complex_patterns = []
    lines = content.split('\n')
    
    # 查找match语句
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if 'match' in stripped and 'with' in stripped:
            # 分析match语句的复杂度
            match_analysis = analyze_match_complexity(lines, i-1)
            if match_analysis:
                match_analysis['file'] = file_path
                match_analysis['line'] = i
                complex_patterns.append(match_analysis)
    
    return complex_patterns

def analyze_match_complexity(lines: List[str], start_line: int) -> Dict:
    """分析match语句的复杂度"""
    if start_line >= len(lines):
        return None
        
    # 统计match分支
    branches = 0
    max_nesting_depth = 0
    current_depth = 0
    has_complex_patterns = False
    
    # 从match语句开始向下扫描
    i = start_line
    while i < len(lines):
        line = lines[i].strip()
        
        # 检查是否是新的match分支
        if line.startswith('|') or (line.startswith('match') and 'with' in line):
            branches += 1
            
            # 检查复杂模式
            if check_complex_pattern(line):
                has_complex_patterns = True
        
        # 检查嵌套深度
        depth_change = count_nesting_change(line)
        current_depth += depth_change
        max_nesting_depth = max(max_nesting_depth, current_depth)
        
        # 检查是否结束当前match
        if (line.startswith('let ') or 
            line.startswith('and ') or 
            line.startswith('type ') or
            (i > start_line + 1 and line.strip() == "")):
            break
            
        i += 1
    
    # 判断是否为复杂模式匹配
    is_complex = (branches > 10 or 
                  max_nesting_depth > 3 or 
                  has_complex_patterns)
    
    if is_complex:
        return {
            'branches': branches,
            'max_nesting_depth': max_nesting_depth,
            'has_complex_patterns': has_complex_patterns,
            'start_line': start_line + 1,
            'complexity_score': calculate_complexity_score(branches, max_nesting_depth, has_complex_patterns)
        }
    
    return None

def check_complex_pattern(line: str) -> bool:
    """检查是否包含复杂模式"""
    complex_indicators = [
        r'\(\s*\w+\s*,.*,.*\)',  # 复杂元组模式
        r'\[\s*.*;\s*.*\]',      # 数组模式
        r'\w+\s*\(\s*\w+\s*,.*,.*\)',  # 多参数构造器
        r'when\s+',             # guard条件
        r'\|.*\|.*\|',          # 多个Or模式
        r'as\s+\w+',            # as模式
    ]
    
    for pattern in complex_indicators:
        if re.search(pattern, line):
            return True
    return False

def count_nesting_change(line: str) -> int:
    """计算行中嵌套深度的变化"""
    depth_change = 0
    depth_change += line.count('(') - line.count(')')
    depth_change += line.count('[') - line.count(']')
    depth_change += line.count('{') - line.count('}')
    return depth_change

def calculate_complexity_score(branches: int, nesting: int, has_complex: bool) -> int:
    """计算复杂度分数"""
    score = 0
    score += branches * 2  # 每个分支2分
    score += nesting * 5   # 每层嵌套5分
    if has_complex:
        score += 10        # 复杂模式额外10分
    return score

def find_ml_files(src_dir: str) -> List[str]:
    """找到所有.ml文件"""
    ml_files = []
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                ml_files.append(os.path.join(root, file))
    return ml_files

def generate_complex_pattern_report(src_dir: str):
    """生成复杂模式匹配分析报告"""
    print("=== 骆言项目复杂模式匹配分析报告 ===")
    print()
    
    ml_files = find_ml_files(src_dir)
    all_complex_patterns = []
    
    for file_path in ml_files:
        patterns = analyze_complex_patterns(file_path)
        all_complex_patterns.extend(patterns)
    
    # 统计信息
    total_complex = len(all_complex_patterns)
    high_complexity = [p for p in all_complex_patterns if p['complexity_score'] > 50]
    very_high_complexity = [p for p in all_complex_patterns if p['complexity_score'] > 100]
    
    print("## 总体统计")
    print(f"- 总文件数: {len(ml_files)}")
    print(f"- 复杂模式匹配数: {total_complex}")
    print(f"- 高复杂度(>50分): {len(high_complexity)}")
    print(f"- 极高复杂度(>100分): {len(very_high_complexity)}")
    print()
    
    if all_complex_patterns:
        # 按复杂度排序
        all_complex_patterns.sort(key=lambda x: x['complexity_score'], reverse=True)
        
        print("## 需要重构的复杂模式匹配")
        print()
        print("| 文件 | 行号 | 分支数 | 最大嵌套深度 | 复杂模式 | 复杂度分数 |")
        print("|------|------|--------|-------------|----------|-----------|")
        
        for pattern in all_complex_patterns[:15]:  # 显示前15个最复杂的
            file_short = os.path.basename(pattern['file'])
            complex_flag = "是" if pattern['has_complex_patterns'] else "否"
            print(f"| {file_short} | {pattern['line']} | {pattern['branches']} | {pattern['max_nesting_depth']} | {complex_flag} | {pattern['complexity_score']} |")
        
        print()
        
        # 按文件分组
        file_stats = defaultdict(list)
        for pattern in all_complex_patterns:
            file_stats[pattern['file']].append(pattern)
        
        print("## 按文件分组的复杂模式匹配分布")
        print()
        
        for file_path, patterns in sorted(file_stats.items(), 
                                         key=lambda x: sum(p['complexity_score'] for p in x[1]), 
                                         reverse=True):
            file_short = os.path.basename(file_path)
            total_score = sum(p['complexity_score'] for p in patterns)
            print(f"### {file_short}")
            print(f"- 复杂模式匹配数量: {len(patterns)}")
            print(f"- 总复杂度分数: {total_score}")
            print("- 详细列表:")
            for pattern in sorted(patterns, key=lambda x: x['complexity_score'], reverse=True):
                print(f"  - 第{pattern['line']}行: {pattern['branches']}分支, 嵌套{pattern['max_nesting_depth']}层, 分数{pattern['complexity_score']}")
            print()
    else:
        print("没有发现复杂的模式匹配。")

if __name__ == "__main__":
    src_directory = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    generate_complex_pattern_report(src_directory)