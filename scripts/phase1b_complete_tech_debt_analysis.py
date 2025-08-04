#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 1-B 完整技术债务分析工具 - 修复版本
Author: Whisky, PR Worker

解决 Delta reviewer 指出的分析不完整问题:
1. 覆盖所有源文件目录 (包括 Poetry 子系统)
2. 识别真正的长函数和复杂文件
3. 提供准确的技术债务度量
"""

import os
import re
import json
import sys
from datetime import datetime
from collections import defaultdict
from pathlib import Path

def analyze_ocaml_file(filepath):
    """分析OCaml文件中的函数和复杂度 - 修复版本"""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception as e:
        print(f"警告: 无法读取文件 {filepath}: {e}")
        return None
    
    lines = content.split('\n')
    total_lines = len(lines)
    non_empty_lines = sum(1 for line in lines if line.strip())
    
    # 更准确的函数检测算法
    functions = []
    
    # 使用更准确的方法：只识别真正的函数定义，过滤简单变量赋值
    let_positions = []
    for i, line in enumerate(lines):
        stripped = line.strip()
        # 检测函数/值定义开始，但过滤掉简单的变量赋值
        if re.match(r'^\s*let\s+(?:rec\s+)?(\w+)', line):
            func_match = re.match(r'^\s*let\s+(?:rec\s+)?(\w+)', line)
            if func_match:
                name = func_match.group(1)
                # 跳过明显的简单变量赋值，但保留函数定义和复杂表达式
                if ('=' in line and 
                    not re.search(r'\bfun\b|\bfunction\b|\bmatch\b|\bif\b|\bthen\b|\belse\b|\brec\b|\band\b', line) and
                    len(line.strip()) < 60 and
                    line.count('(') <= 2):  # 简单的短赋值
                    continue
                
                let_positions.append({
                    'name': name,
                    'line': i + 1,  # 1-based line numbers
                    'content': line
                })
    
    # 计算每个函数的长度
    for i, func_info in enumerate(let_positions):
        start_line = func_info['line']
        
        # 确定结束行
        if i + 1 < len(let_positions):
            # 下一个函数前的行
            end_line = let_positions[i + 1]['line'] - 1
        else:
            # 文件末尾
            end_line = total_lines
            
        # 计算实际长度：从函数开始到结束的非空行数
        func_lines = []
        for line_num in range(start_line - 1, end_line):
            if line_num < len(lines):
                line_content = lines[line_num].strip()
                if line_content and not line_content.startswith('(*') and not line_content.startswith('*)'):
                    func_lines.append(line_num + 1)
        
        # 更保守的长度计算：只计算到下一个let或明显的定义结束
        actual_end = start_line
        indent_level = len(func_info['content']) - len(func_info['content'].lstrip())
        
        for line_num in range(start_line, end_line):
            if line_num < len(lines):
                line = lines[line_num]
                line_stripped = line.strip()
                
                # 跳过空行和注释
                if not line_stripped or line_stripped.startswith('(*'):
                    continue
                
                # 检测下一个顶级定义
                current_indent = len(line) - len(line.lstrip())
                if (line_num > start_line and 
                    current_indent <= indent_level and 
                    (line_stripped.startswith('let ') or 
                     line_stripped.startswith('type ') or
                     line_stripped.startswith('module ') or
                     line_stripped.startswith('val '))):
                    break
                    
                actual_end = line_num + 1
        
        length = actual_end - start_line + 1
        
        functions.append({
            'name': func_info['name'],
            'start_line': start_line,
            'end_line': actual_end,
            'length': length
        })
    
    # 计算复杂度指标
    complexity_indicators = {
        'nested_matches': len(re.findall(r'\bmatch\b.*\bwith\b', content, re.MULTILINE)),
        'nested_ifs': len(re.findall(r'\bif\b.*\bthen\b.*\belse\b', content, re.MULTILINE)),
        'exception_handling': len(re.findall(r'\btry\b|\bwith\b|\braise\b', content)),
        'loops': len(re.findall(r'\bfor\b|\bwhile\b', content)),
        'recursive_calls': len(re.findall(r'\brec\b', content))
    }
    
    return {
        'filepath': filepath,
        'total_lines': total_lines,
        'non_empty_lines': non_empty_lines,
        'functions': functions,
        'complexity_indicators': complexity_indicators,
        'long_functions': [f for f in functions if f['length'] >= 50],
        'very_long_functions': [f for f in functions if f['length'] >= 100]
    }

def find_all_ml_files(root_dir):
    """递归查找所有.ml文件"""
    ml_files = []
    for root, dirs, files in os.walk(root_dir):
        # 跳过构建目录
        if '_build' in root or '.git' in root:
            continue
        
        for file in files:
            if file.endswith('.ml'):
                ml_files.append(os.path.join(root, file))
    
    return sorted(ml_files)

def generate_comprehensive_report():
    """生成完整的技术债务分析报告"""
    print("🔍 开始完整技术债务分析...")
    
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    src_dir = os.path.join(project_root, 'src')
    
    # 查找所有源文件
    all_ml_files = find_all_ml_files(src_dir)
    print(f"📁 发现 {len(all_ml_files)} 个 .ml 文件")
    
    analysis_results = []
    total_stats = {
        'total_files': 0,
        'total_lines': 0,
        'total_functions': 0,
        'long_functions': 0,
        'very_long_functions': 0,
        'largest_files': [],
        'longest_functions': []
    }
    
    # 分析每个文件
    for i, filepath in enumerate(all_ml_files, 1):
        if i % 50 == 0:
            print(f"📊 已分析 {i}/{len(all_ml_files)} 文件...")
        
        analysis = analyze_ocaml_file(filepath)
        if analysis:
            analysis_results.append(analysis)
            
            # 更新统计信息
            total_stats['total_files'] += 1
            total_stats['total_lines'] += analysis['total_lines']
            total_stats['total_functions'] += len(analysis['functions'])
            total_stats['long_functions'] += len(analysis['long_functions'])
            total_stats['very_long_functions'] += len(analysis['very_long_functions'])
            
            # 收集最大文件
            if analysis['total_lines'] >= 200:
                total_stats['largest_files'].append({
                    'file': os.path.relpath(filepath, project_root),
                    'lines': analysis['total_lines'],
                    'functions': len(analysis['functions'])
                })
            
            # 收集最长函数
            for func in analysis['very_long_functions']:
                total_stats['longest_functions'].append({
                    'file': os.path.relpath(filepath, project_root),
                    'function': func['name'],
                    'length': func['length'],
                    'start_line': func['start_line']
                })
    
    # 排序结果
    total_stats['largest_files'].sort(key=lambda x: x['lines'], reverse=True)
    total_stats['longest_functions'].sort(key=lambda x: x['length'], reverse=True)
    
    # 限制输出数量
    total_stats['largest_files'] = total_stats['largest_files'][:20]
    total_stats['longest_functions'] = total_stats['longest_functions'][:20]
    
    # 生成报告
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_data = {
        'analysis_metadata': {
            'timestamp': timestamp,
            'version': '2.0_complete_coverage',
            'analyzer': 'Whisky_PR_Worker_Fixed',
            'description': '完整技术债务分析 - 修复Delta审查问题'
        },
        'summary_statistics': total_stats,
        'detailed_analysis': analysis_results[:10],  # 只保存前10个详细分析避免文件过大
        'recommendations': {
            'priority_refactoring_targets': total_stats['longest_functions'][:5],
            'large_file_candidates': total_stats['largest_files'][:5],
            'estimated_refactoring_effort': 'HIGH' if total_stats['very_long_functions'] > 10 else 'MEDIUM'
        }
    }
    
    # 保存报告
    monitoring_dir = os.path.join(project_root, 'monitoring_reports')
    os.makedirs(monitoring_dir, exist_ok=True)
    
    report_file = os.path.join(monitoring_dir, f'phase1b_complete_tech_debt_analysis_{timestamp}.json')
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report_data, f, ensure_ascii=False, indent=2)
    
    # 打印关键发现
    print("\n" + "="*80)
    print("🎯 Phase 1-B 完整技术债务分析报告")
    print("="*80)
    print(f"📊 项目规模: {total_stats['total_files']} 文件, {total_stats['total_lines']:,} 行代码")
    print(f"🔧 函数统计: {total_stats['total_functions']} 总函数")
    print(f"⚠️  长函数 (≥50行): {total_stats['long_functions']} 个 ({total_stats['long_functions']/total_stats['total_functions']*100:.1f}%)")
    print(f"🚨 超长函数 (≥100行): {total_stats['very_long_functions']} 个 ({total_stats['very_long_functions']/total_stats['total_functions']*100:.1f}%)")
    
    print(f"\n📁 前5个最大文件:")
    for i, file_info in enumerate(total_stats['largest_files'][:5], 1):
        print(f"  {i}. {file_info['file']} - {file_info['lines']} 行")
    
    print(f"\n🔧 前5个最长函数:")
    for i, func_info in enumerate(total_stats['longest_functions'][:5], 1):
        print(f"  {i}. {func_info['function']}() 在 {func_info['file']} - {func_info['length']} 行 (第{func_info['start_line']}行开始)")
    
    print(f"\n💾 详细报告保存至: {report_file}")
    print("="*80)
    
    return report_file

if __name__ == '__main__':
    try:
        report_file = generate_comprehensive_report()
        print(f"\n✅ 完整技术债务分析完成: {report_file}")
    except Exception as e:
        print(f"❌ 分析失败: {e}")
        sys.exit(1)