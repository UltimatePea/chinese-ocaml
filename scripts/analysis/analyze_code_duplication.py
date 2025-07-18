#!/usr/bin/env python3
"""
分析骆言项目中的重复代码模式
"""

import os
import re
import hashlib
from typing import List, Dict, Set, Tuple
from collections import defaultdict

def normalize_code(code: str) -> str:
    """标准化代码以便比较"""
    # 移除注释
    code = re.sub(r'\(\*.*?\*\)', '', code, flags=re.DOTALL)
    # 移除多余空白
    code = re.sub(r'\s+', ' ', code)
    # 移除变量名，用占位符替代
    code = re.sub(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b', 'VAR', code)
    # 移除数字
    code = re.sub(r'\b\d+\b', 'NUM', code)
    # 移除字符串字面量
    code = re.sub(r'"[^"]*"', 'STR', code)
    return code.strip()

def extract_code_blocks(file_path: str, min_lines: int = 5) -> List[Dict]:
    """提取代码块用于重复检测"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    blocks = []
    
    # 滑动窗口提取代码块
    for i in range(len(lines) - min_lines + 1):
        block_lines = lines[i:i + min_lines]
        block_content = ''.join(block_lines)
        
        # 跳过主要是注释或空行的块
        if re.search(r'^\s*\(\*', block_content) or len(block_content.strip()) < 50:
            continue
        
        normalized = normalize_code(block_content)
        if len(normalized) < 20:  # 跳过太短的块
            continue
        
        blocks.append({
            'file': file_path,
            'start_line': i + 1,
            'end_line': i + min_lines,
            'content': block_content,
            'normalized': normalized,
            'hash': hashlib.md5(normalized.encode()).hexdigest()
        })
    
    return blocks

def find_similar_functions(file_path: str) -> List[Dict]:
    """查找相似的函数定义"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    functions = []
    function_pattern = re.compile(r'^let\s+(rec\s+)?(\w+)\s*.*?=\s*(.*?)(?=^let\s|\Z)', 
                                 re.MULTILINE | re.DOTALL)
    
    for match in function_pattern.finditer(content):
        function_body = match.group(3)
        if len(function_body) > 100:  # 只考虑较长的函数
            normalized = normalize_code(function_body)
            functions.append({
                'file': file_path,
                'name': match.group(2),
                'body': function_body,
                'normalized': normalized,
                'hash': hashlib.md5(normalized.encode()).hexdigest(),
                'start_pos': match.start(),
                'end_pos': match.end()
            })
    
    return functions

def detect_pattern_repetition(file_path: str) -> List[Dict]:
    """检测常见的重复模式"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    patterns = []
    
    # 常见重复模式
    repetitive_patterns = [
        (r'match\s+\w+\s+with\s*\|\s*\w+\s*->', '重复的match模式'),
        (r'let\s+\w+\s*=\s*\w+\s*\(\s*\w+\s*\)', '重复的函数调用模式'),
        (r'if\s+\w+\s+then\s+\w+\s+else\s+\w+', '重复的条件判断模式'),
        (r'raise\s*\(\s*\w+\s+"[^"]*"\s*\)', '重复的异常抛出模式'),
        (r'Printf\.sprintf\s+"[^"]*"', '重复的字符串格式化模式'),
    ]
    
    for pattern, description in repetitive_patterns:
        matches = list(re.finditer(pattern, content))
        if len(matches) > 3:  # 如果模式出现超过3次
            patterns.append({
                'file': file_path,
                'pattern': pattern,
                'description': description,
                'count': len(matches),
                'matches': [m.span() for m in matches]
            })
    
    return patterns

def find_ml_files(src_dir: str) -> List[str]:
    """找到所有.ml文件"""
    ml_files = []
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.ml'):
                ml_files.append(os.path.join(root, file))
    return ml_files

def analyze_code_duplication(src_dir: str):
    """分析代码重复问题"""
    ml_files = find_ml_files(src_dir)
    
    # 收集所有代码块
    all_blocks = []
    all_functions = []
    all_patterns = []
    
    for file_path in ml_files:
        blocks = extract_code_blocks(file_path)
        functions = find_similar_functions(file_path)
        patterns = detect_pattern_repetition(file_path)
        
        all_blocks.extend(blocks)
        all_functions.extend(functions)
        all_patterns.extend(patterns)
    
    # 查找重复的代码块
    hash_groups = defaultdict(list)
    for block in all_blocks:
        hash_groups[block['hash']].append(block)
    
    duplicated_blocks = {h: blocks for h, blocks in hash_groups.items() if len(blocks) > 1}
    
    # 查找相似的函数
    func_hash_groups = defaultdict(list)
    for func in all_functions:
        func_hash_groups[func['hash']].append(func)
    
    duplicated_functions = {h: funcs for h, funcs in func_hash_groups.items() if len(funcs) > 1}
    
    return duplicated_blocks, duplicated_functions, all_patterns

def generate_duplication_report(src_dir: str):
    """生成代码重复分析报告"""
    print("=== 骆言项目代码重复分析报告 ===")
    print()
    
    duplicated_blocks, duplicated_functions, patterns = analyze_code_duplication(src_dir)
    
    # 总体统计
    total_duplicated_blocks = sum(len(blocks) for blocks in duplicated_blocks.values())
    total_duplicated_functions = sum(len(funcs) for funcs in duplicated_functions.values())
    total_pattern_violations = sum(p['count'] for p in patterns)
    
    print("## 总体统计")
    print(f"- 重复代码块组数: {len(duplicated_blocks)}")
    print(f"- 总重复代码块数: {total_duplicated_blocks}")
    print(f"- 重复函数组数: {len(duplicated_functions)}")
    print(f"- 总重复函数数: {total_duplicated_functions}")
    print(f"- 重复模式违规文件数: {len(patterns)}")
    print(f"- 总重复模式实例数: {total_pattern_violations}")
    print()
    
    # 重复代码块分析
    if duplicated_blocks:
        print("## 重复代码块分析")
        print()
        print("| 重复组 | 文件数 | 重复次数 | 代表文件 | 起始行 |")
        print("|--------|--------|----------|----------|--------|")
        
        for i, (hash_val, blocks) in enumerate(sorted(duplicated_blocks.items(), 
                                                     key=lambda x: len(x[1]), 
                                                     reverse=True)[:10]):
            files = set(os.path.basename(block['file']) for block in blocks)
            file_count = len(files)
            repeat_count = len(blocks)
            representative_file = os.path.basename(blocks[0]['file'])
            start_line = blocks[0]['start_line']
            
            print(f"| 组{i+1} | {file_count} | {repeat_count} | {representative_file} | {start_line} |")
        print()
    
    # 重复函数分析
    if duplicated_functions:
        print("## 重复函数分析")
        print()
        print("| 函数组 | 函数名示例 | 重复次数 | 涉及文件 |")
        print("|--------|------------|----------|----------|")
        
        for i, (hash_val, funcs) in enumerate(sorted(duplicated_functions.items(), 
                                                   key=lambda x: len(x[1]), 
                                                   reverse=True)[:10]):
            function_name = funcs[0]['name']
            repeat_count = len(funcs)
            files = ", ".join(set(os.path.basename(func['file']) for func in funcs))
            
            print(f"| 组{i+1} | {function_name} | {repeat_count} | {files} |")
        print()
    
    # 重复模式分析
    if patterns:
        print("## 重复模式分析")
        print()
        patterns.sort(key=lambda x: x['count'], reverse=True)
        
        print("| 文件 | 模式描述 | 重复次数 |")
        print("|------|----------|----------|")
        
        for pattern in patterns[:15]:
            file_short = os.path.basename(pattern['file'])
            description = pattern['description']
            count = pattern['count']
            print(f"| {file_short} | {description} | {count} |")
        print()
        
        # 按模式类型分组统计
        pattern_types = defaultdict(int)
        for pattern in patterns:
            pattern_types[pattern['description']] += pattern['count']
        
        print("## 重复模式类型统计")
        print()
        print("| 模式类型 | 总出现次数 | 涉及文件数 |")
        print("|----------|------------|------------|")
        
        for pattern_type, total_count in sorted(pattern_types.items(), 
                                              key=lambda x: x[1], 
                                              reverse=True):
            file_count = len([p for p in patterns if p['description'] == pattern_type])
            print(f"| {pattern_type} | {total_count} | {file_count} |")
        print()
    
    # 改进建议
    print("## 改进建议")
    print()
    print("### 高优先级建议")
    print("1. **提取公共函数**: 将重复的代码块提取为公共的辅助函数")
    print("2. **创建工具模块**: 为重复的模式创建专门的工具模块")
    print("3. **重构相似函数**: 将功能相似的函数合并或提取公共逻辑")
    print()
    
    print("### 中优先级建议")
    print("4. **使用模板或宏**: 对于重复的样板代码，考虑使用代码生成")
    print("5. **建立编码规范**: 避免在不同文件中重复实现相同逻辑")
    print("6. **定期代码审查**: 在开发过程中识别和防止代码重复")
    print()

if __name__ == "__main__":
    src_directory = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    generate_duplication_report(src_directory)