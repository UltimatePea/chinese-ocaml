#!/usr/bin/env python3
"""
comprehensive OCaml function length analyzer
找出OCaml文件中最长的函数
"""

import os
import re
import glob
from typing import List, Tuple, Dict
from dataclasses import dataclass

@dataclass
class FunctionInfo:
    name: str
    file_path: str
    start_line: int
    end_line: int
    line_count: int
    code_lines: int  # 不包含注释和空行的行数

def strip_comments_and_empty_lines(lines: List[str]) -> List[str]:
    """移除注释和空行，返回只包含代码的行"""
    code_lines = []
    in_comment = False
    
    for line in lines:
        stripped = line.strip()
        
        # 跳过空行
        if not stripped:
            continue
            
        # 处理多行注释 (* ... *)
        if '(*' in stripped and '*)' in stripped:
            # 单行注释
            before_comment = stripped[:stripped.find('(*')]
            after_comment = stripped[stripped.rfind('*)') + 2:]
            cleaned_line = before_comment + after_comment
            if cleaned_line.strip():
                code_lines.append(cleaned_line.strip())
            continue
        elif '(*' in stripped:
            # 多行注释开始
            in_comment = True
            before_comment = stripped[:stripped.find('(*')]
            if before_comment.strip():
                code_lines.append(before_comment.strip())
            continue
        elif '*)' in stripped and in_comment:
            # 多行注释结束
            in_comment = False
            after_comment = stripped[stripped.rfind('*)') + 2:]
            if after_comment.strip():
                code_lines.append(after_comment.strip())
            continue
        elif in_comment:
            # 在多行注释中
            continue
            
        # 处理单行注释 //
        if '//' in stripped:
            before_comment = stripped[:stripped.find('//')]
            if before_comment.strip():
                code_lines.append(before_comment.strip())
            continue
            
        # 普通代码行
        code_lines.append(stripped)
    
    return code_lines

def find_function_end(lines: List[str], start_idx: int, func_name: str) -> int:
    """
    找到函数定义的结束位置
    使用括号匹配来确定函数边界
    """
    paren_count = 0
    brace_count = 0
    bracket_count = 0
    in_string = False
    in_char = False
    
    i = start_idx
    while i < len(lines):
        line = lines[i].strip()
        
        if not line:
            i += 1
            continue
            
        # 简单的字符串和字符处理
        j = 0
        while j < len(line):
            char = line[j]
            
            if not in_string and not in_char:
                if char == '"' and (j == 0 or line[j-1] != '\\'):
                    in_string = True
                elif char == "'" and (j == 0 or line[j-1] != '\\'):
                    in_char = True
                elif char == '(':
                    paren_count += 1
                elif char == ')':
                    paren_count -= 1
                elif char == '{':
                    brace_count += 1
                elif char == '}':
                    brace_count -= 1
                elif char == '[':
                    bracket_count += 1
                elif char == ']':
                    bracket_count -= 1
            else:
                if in_string and char == '"' and (j == 0 or line[j-1] != '\\'):
                    in_string = False
                elif in_char and char == "'" and (j == 0 or line[j-1] != '\\'):
                    in_char = False
            
            j += 1
        
        # 检查是否到达函数结束
        if paren_count == 0 and brace_count == 0 and bracket_count == 0:
            # 检查是否是下一个顶级定义
            if re.match(r'^\s*(let|type|module|val|open|include)\s+', line) and i > start_idx:
                return i - 1
            
            # 检查是否遇到了 'in' 关键字（对于 let ... in 结构）
            if re.search(r'\bin\s*$', line) or line.endswith(' in'):
                return i
        
        i += 1
    
    return len(lines) - 1

def analyze_ocaml_file(file_path: str) -> List[FunctionInfo]:
    """分析单个OCaml文件，返回函数信息列表"""
    if not os.path.exists(file_path):
        return []
        
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return []
    
    functions = []
    
    # 查找函数定义
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        # 匹配 let 函数定义
        # let function_name = ...
        # let rec function_name = ...
        # let function_name param1 param2 = ...
        
        let_match = re.match(r'^\s*let\s+(rec\s+)?([a-zA-Z_][a-zA-Z0-9_\']*)', stripped)
        if let_match:
            func_name = let_match.group(2)
            
            # 跳过简单的值绑定 (let x = 42)
            if '=' in stripped and not re.search(r'\bfun\b|\bfunction\b|->|\bif\b|\bmatch\b', stripped):
                # 检查是否是简单赋值
                after_equals = stripped[stripped.find('=') + 1:].strip()
                if len(after_equals.split()) <= 3 and not '(' in after_equals:
                    continue
            
            end_line = find_function_end(lines, i, func_name)
            total_lines = end_line - i + 1
            
            # 计算代码行数（不包含注释和空行）
            function_lines = lines[i:end_line + 1]
            code_lines = strip_comments_and_empty_lines(function_lines)
            code_line_count = len(code_lines)
            
            # 只记录超过一定长度的函数
            if total_lines >= 5 or code_line_count >= 3:
                functions.append(FunctionInfo(
                    name=func_name,
                    file_path=file_path,
                    start_line=i + 1,  # 1-based line numbers
                    end_line=end_line + 1,
                    line_count=total_lines,
                    code_lines=code_line_count
                ))
    
    return functions

def main():
    # 要分析的文件
    target_files = [
        "src/config.ml",
        "src/poetry/data/an_yun_data.ml",
        "src/poetry/rhyme_data.ml",
        "src/keyword_matcher.ml",
        "src/semantic_statements.ml",
        "src/parser_statements.ml"
    ]
    
    # 添加所有src目录下的.ml文件
    all_ml_files = glob.glob("src/**/*.ml", recursive=True)
    
    # 合并文件列表并去重
    files_to_analyze = list(set(target_files + all_ml_files))
    
    all_functions = []
    
    print("正在分析OCaml文件中的函数长度...")
    print("=" * 60)
    
    for file_path in files_to_analyze:
        if os.path.exists(file_path):
            print(f"分析文件: {file_path}")
            functions = analyze_ocaml_file(file_path)
            all_functions.extend(functions)
    
    # 按代码行数排序（降序）
    all_functions.sort(key=lambda x: x.code_lines, reverse=True)
    
    print("\n\n超长函数分析结果")
    print("=" * 60)
    print(f"总共找到 {len(all_functions)} 个函数")
    
    # 显示超过50行的函数
    long_functions = [f for f in all_functions if f.code_lines >= 50]
    
    if long_functions:
        print(f"\n发现 {len(long_functions)} 个超过50行代码的函数:")
        print("-" * 80)
        print(f"{'函数名':<30} {'文件路径':<40} {'总行数':<8} {'代码行数':<8}")
        print("-" * 80)
        
        for func in long_functions:
            print(f"{func.name:<30} {func.file_path:<40} {func.line_count:<8} {func.code_lines:<8}")
    
    # 显示前20个最长的函数
    print(f"\n前20个最长的函数 (按代码行数):")
    print("-" * 100)
    print(f"{'排名':<4} {'函数名':<25} {'文件路径':<35} {'起始行':<6} {'结束行':<6} {'总行数':<6} {'代码行数':<6}")
    print("-" * 100)
    
    for i, func in enumerate(all_functions[:20], 1):
        file_short = func.file_path.replace("src/", "")
        print(f"{i:<4} {func.name:<25} {file_short:<35} {func.start_line:<6} {func.end_line:<6} {func.line_count:<6} {func.code_lines:<6}")
    
    # 统计分析
    print(f"\n统计分析:")
    print("-" * 40)
    
    if all_functions:
        total_code_lines = sum(f.code_lines for f in all_functions)
        avg_lines = total_code_lines / len(all_functions)
        
        super_long = len([f for f in all_functions if f.code_lines >= 100])
        very_long = len([f for f in all_functions if f.code_lines >= 50])
        long_funcs = len([f for f in all_functions if f.code_lines >= 20])
        
        print(f"平均函数长度: {avg_lines:.1f} 行代码")
        print(f"超长函数 (>=100行): {super_long} 个")
        print(f"很长函数 (>=50行): {very_long} 个") 
        print(f"长函数 (>=20行): {long_funcs} 个")
        
        # 按文件分组统计
        print(f"\n按文件统计长函数分布:")
        print("-" * 50)
        
        file_stats = {}
        for func in all_functions:
            if func.code_lines >= 20:
                file_short = func.file_path.replace("src/", "")
                if file_short not in file_stats:
                    file_stats[file_short] = []
                file_stats[file_short].append(func)
        
        for file_path, funcs in sorted(file_stats.items(), key=lambda x: len(x[1]), reverse=True):
            if len(funcs) > 0:
                print(f"{file_path}: {len(funcs)} 个长函数")
                for func in sorted(funcs, key=lambda x: x.code_lines, reverse=True)[:3]:
                    print(f"  - {func.name}: {func.code_lines} 行")

if __name__ == "__main__":
    main()