#!/usr/bin/env python3
"""
分析OCaml项目中的长函数 - 骆言诗词编程项目
专门用于查找超过80行的函数，按优先级排序
"""

import os
import re
import sys
from typing import List, Tuple, Dict
from dataclasses import dataclass

@dataclass
class FunctionInfo:
    name: str
    file_path: str
    start_line: int
    end_line: int
    line_count: int
    function_type: str = ""
    
    @property
    def priority(self) -> str:
        if self.line_count >= 100:
            return "CRITICAL"
        elif self.line_count >= 80:
            return "HIGH"
        else:
            return "MEDIUM"

def find_functions_in_file(file_path: str) -> List[FunctionInfo]:
    """分析单个OCaml文件中的函数"""
    functions = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return functions
    
    # 正则表达式匹配OCaml函数定义
    function_patterns = [
        re.compile(r'^\s*let\s+(?:rec\s+)?(\w+)'),  # let function
        re.compile(r'^\s*and\s+(\w+)'),              # and function continuation
        re.compile(r'^\s*let\s+(?:rec\s+)?(\w+)\s*=\s*function'),  # pattern matching function
    ]
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # 跳过注释和空行
        if line.strip().startswith('(*') or line.strip().startswith('*') or not line.strip():
            i += 1
            continue
            
        # 查找函数定义
        function_name = None
        for pattern in function_patterns:
            match = pattern.match(line)
            if match:
                function_name = match.group(1)
                break
        
        if function_name:
            start_line = i + 1
            # 查找函数结束位置
            end_line = find_function_end(lines, i)
            line_count = end_line - start_line + 1
            
            if line_count >= 80:  # 只记录80行以上的函数
                functions.append(FunctionInfo(
                    name=function_name,
                    file_path=file_path,
                    start_line=start_line,
                    end_line=end_line,
                    line_count=line_count
                ))
            
            i = end_line
        else:
            i += 1
    
    return functions

def find_function_end(lines: List[str], start_idx: int) -> int:
    """查找函数结束位置"""
    
    # 简单策略：查找下一个let/and定义或文件结束
    i = start_idx + 1
    paren_count = 0
    bracket_count = 0
    brace_count = 0
    in_comment = False
    
    while i < len(lines):
        line = lines[i].strip()
        
        # 处理注释
        if '(*' in line and '*)' not in line:
            in_comment = True
        elif '*)' in line:
            in_comment = False
            
        if in_comment:
            i += 1
            continue
            
        # 计算括号层次
        paren_count += line.count('(') - line.count(')')
        bracket_count += line.count('[') - line.count(']')
        brace_count += line.count('{') - line.count('}')
        
        # 查找下一个函数定义
        if (paren_count <= 0 and bracket_count <= 0 and brace_count <= 0 and
            (re.match(r'^\s*let\s+', line) or 
             re.match(r'^\s*and\s+', line) or
             re.match(r'^\s*type\s+', line) or
             re.match(r'^\s*module\s+', line) or
             re.match(r'^\s*open\s+', line) or
             line == '')):
            return i
            
        i += 1
    
    return len(lines) - 1

def analyze_directory(src_path: str) -> List[FunctionInfo]:
    """分析整个src目录"""
    all_functions = []
    
    for root, dirs, files in os.walk(src_path):
        for file in files:
            if file.endswith('.ml'):
                file_path = os.path.join(root, file)
                functions = find_functions_in_file(file_path)
                all_functions.extend(functions)
    
    return all_functions

def get_function_description(func: FunctionInfo) -> str:
    """获取函数的简要描述"""
    try:
        with open(func.file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # 查找函数前的注释
        start_idx = func.start_line - 1
        description_lines = []
        
        # 向上查找注释
        for i in range(max(0, start_idx - 5), start_idx):
            line = lines[i].strip()
            if line.startswith('(*') or line.startswith('**'):
                # 提取注释内容
                comment = re.sub(r'\(\*+|\*+\)', '', line).strip()
                if comment:
                    description_lines.append(comment)
        
        # 查看函数内容获取更多信息
        if start_idx < len(lines):
            func_line = lines[start_idx].strip()
            if 'match' in func_line:
                description_lines.append("模式匹配函数")
            elif 'function' in func_line:
                description_lines.append("函数表达式")
            elif 'let rec' in func_line:
                description_lines.append("递归函数")
        
        return '; '.join(description_lines) if description_lines else "未知功能"
        
    except Exception:
        return "无法获取描述"

def main():
    if len(sys.argv) != 2:
        print("用法: python3 analyze_long_functions.py <src_directory>")
        sys.exit(1)
    
    src_path = sys.argv[1]
    if not os.path.exists(src_path):
        print(f"目录不存在: {src_path}")
        sys.exit(1)
    
    print("正在分析长函数...")
    functions = analyze_directory(src_path)
    
    # 按优先级和行数排序
    functions.sort(key=lambda f: (-f.line_count, f.file_path))
    
    print(f"\n找到 {len(functions)} 个超过80行的长函数:\n")
    
    # 按优先级分组
    critical_functions = [f for f in functions if f.line_count >= 100]
    high_priority_functions = [f for f in functions if 80 <= f.line_count < 100]
    
    print("🔴 CRITICAL级别函数 (100行以上):")
    print("=" * 60)
    for func in critical_functions:
        description = get_function_description(func)
        rel_path = os.path.relpath(func.file_path, src_path)
        print(f"函数名: {func.name}")
        print(f"文件路径: {rel_path}")
        print(f"行数: {func.line_count} 行 (第{func.start_line}-{func.end_line}行)")
        print(f"描述: {description}")
        print("-" * 60)
    
    print(f"\n🟡 HIGH级别函数 (80-99行):")
    print("=" * 60)
    for func in high_priority_functions:
        description = get_function_description(func)
        rel_path = os.path.relpath(func.file_path, src_path)
        print(f"函数名: {func.name}")
        print(f"文件路径: {rel_path}")
        print(f"行数: {func.line_count} 行 (第{func.start_line}-{func.end_line}行)")
        print(f"描述: {description}")
        print("-" * 60)
    
    print(f"\n📊 统计摘要:")
    print(f"总计: {len(functions)} 个长函数")
    print(f"Critical级别 (≥100行): {len(critical_functions)} 个")
    print(f"High级别 (80-99行): {len(high_priority_functions)} 个")
    
    # 按文件分组统计
    file_stats = {}
    for func in functions:
        rel_path = os.path.relpath(func.file_path, src_path)
        if rel_path not in file_stats:
            file_stats[rel_path] = []
        file_stats[rel_path].append(func)
    
    print(f"\n📁 按文件分组:")
    for file_path, funcs in sorted(file_stats.items(), key=lambda x: -len(x[1])):
        print(f"{file_path}: {len(funcs)} 个长函数")

if __name__ == "__main__":
    main()