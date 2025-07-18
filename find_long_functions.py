#\!/usr/bin/env python3
"""
分析OCaml源代码文件中的长函数
"""

import os
import re
import glob
from typing import List, Dict, Tuple

def analyze_ocaml_file(file_path: str) -> List[Dict]:
    """分析单个OCaml文件中的函数"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
        return []
    
    functions = []
    current_function = None
    
    for line_num, line in enumerate(lines, 1):
        stripped = line.strip()
        
        # 检测函数定义开始
        let_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
        and_match = re.match(r'^and\s+([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
        
        if let_match:
            # 如果正在分析一个函数，先保存它
            if current_function:
                functions.append(current_function)
            
            # 开始新函数
            func_name = let_match.group(2)
            current_function = {
                'name': func_name,
                'start_line': line_num,
                'lines': [line],
                'file': file_path
            }
        elif and_match:
            # 如果正在分析一个函数，先保存它
            if current_function:
                functions.append(current_function)
            
            # 开始新函数
            func_name = and_match.group(1)
            current_function = {
                'name': func_name,
                'start_line': line_num,
                'lines': [line],
                'file': file_path
            }
        elif current_function:
            # 检测函数结束条件
            if stripped.startswith('let ') or stripped.startswith('and ') or stripped.startswith('type ') or stripped.startswith('module ') or stripped.startswith('exception '):
                # 新的定义开始，当前函数结束
                functions.append(current_function)
                current_function = None
                
                # 检查是否是新的函数定义
                let_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
                and_match = re.match(r'^and\s+([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
                
                if let_match:
                    func_name = let_match.group(2)
                    current_function = {
                        'name': func_name,
                        'start_line': line_num,
                        'lines': [line],
                        'file': file_path
                    }
                elif and_match:
                    func_name = and_match.group(1)
                    current_function = {
                        'name': func_name,
                        'start_line': line_num,
                        'lines': [line],
                        'file': file_path
                    }
            else:
                # 继续当前函数
                current_function['lines'].append(line)
    
    # 处理文件末尾的函数
    if current_function:
        functions.append(current_function)
    
    return functions

def find_long_functions(src_dir: str, min_lines: int = 100) -> List[Dict]:
    """查找长函数"""
    all_functions = []
    
    # 查找所有.ml文件
    ml_files = glob.glob(os.path.join(src_dir, "**/*.ml"), recursive=True)
    
    for file_path in ml_files:
        if '/test/' in file_path or 'test_' in os.path.basename(file_path):
            continue  # 跳过测试文件
            
        functions = analyze_ocaml_file(file_path)
        for func in functions:
            func['line_count'] = len(func['lines'])
            if func['line_count'] >= min_lines:
                all_functions.append(func)
    
    return sorted(all_functions, key=lambda x: x['line_count'], reverse=True)

def analyze_complexity(func_lines: List[str]) -> Dict:
    """分析函数复杂度"""
    complexity = {
        'nested_if_count': 0,
        'match_count': 0,
        'recursive_calls': 0,
        'nested_functions': 0,
        'max_nesting_depth': 0,
        'current_depth': 0
    }
    
    func_name = None
    
    for line in func_lines:
        stripped = line.strip()
        
        # 获取函数名
        if not func_name:
            let_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
            and_match = re.match(r'^and\s+([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
            if let_match:
                func_name = let_match.group(2)
            elif and_match:
                func_name = and_match.group(1)
        
        # 计算嵌套深度
        if 'if ' in stripped or 'match ' in stripped or 'let ' in stripped:
            complexity['current_depth'] += 1
            complexity['max_nesting_depth'] = max(complexity['max_nesting_depth'], complexity['current_depth'])
        
        # 统计条件语句
        if re.search(r'\bif\b < /dev/null | \b如果\b', stripped):
            complexity['nested_if_count'] += 1
        
        # 统计模式匹配
        if re.search(r'\bmatch\b|\b匹配\b', stripped):
            complexity['match_count'] += 1
        
        # 统计递归调用
        if func_name and func_name in stripped:
            complexity['recursive_calls'] += 1
        
        # 统计嵌套函数
        if re.search(r'\blet\b.*\bfun\b|\blet\b.*→', stripped):
            complexity['nested_functions'] += 1
    
    return complexity

def generate_report(long_functions: List[Dict]) -> str:
    """生成技术债务分析报告"""
    report = []
    report.append("# 骆言项目技术债务分析报告 - 长函数分析")
    report.append("")
    report.append("## 执行摘要")
    report.append(f"- 发现 {len(long_functions)} 个超过100行的长函数")
    if long_functions:
        report.append(f"- 最长函数: {max(func['line_count'] for func in long_functions)} 行")
        report.append(f"- 平均长度: {sum(func['line_count'] for func in long_functions) // len(long_functions)} 行")
    report.append("")
    
    if not long_functions:
        report.append("## 结论")
        report.append("🎉 **优秀\!** 项目中没有发现超过100行的长函数。代码保持了良好的模块化结构。")
        return "\n".join(report)
    
    report.append("## 详细分析")
    report.append("")
    
    # 按严重性分类
    critical = [f for f in long_functions if f['line_count'] > 200]
    high = [f for f in long_functions if 150 <= f['line_count'] <= 200]
    medium = [f for f in long_functions if 100 <= f['line_count'] < 150]
    
    if critical:
        report.append("### 🔴 严重级别 (>200行)")
        for func in critical:
            complexity = analyze_complexity(func['lines'])
            report.append(f"**{func['name']}** ({func['line_count']}行)")
            report.append(f"- 文件: `{func['file']}`")
            report.append(f"- 起始行: {func['start_line']}")
            report.append(f"- 复杂度指标:")
            report.append(f"  - 最大嵌套深度: {complexity['max_nesting_depth']}")
            report.append(f"  - 条件语句数: {complexity['nested_if_count']}")
            report.append(f"  - 模式匹配数: {complexity['match_count']}")
            report.append(f"  - 嵌套函数数: {complexity['nested_functions']}")
            report.append(f"- **重构建议**: 立即分解为多个小函数")
            report.append(f"- **优先级**: 高")
            report.append("")
    
    if high:
        report.append("### 🟡 高级别 (150-200行)")
        for func in high:
            complexity = analyze_complexity(func['lines'])
            report.append(f"**{func['name']}** ({func['line_count']}行)")
            report.append(f"- 文件: `{func['file']}`")
            report.append(f"- 起始行: {func['start_line']}")
            report.append(f"- **重构建议**: 考虑分解为2-3个子函数")
            report.append(f"- **优先级**: 中高")
            report.append("")
    
    if medium:
        report.append("### 🟢 中级别 (100-149行)")
        for func in medium:
            report.append(f"**{func['name']}** ({func['line_count']}行)")
            report.append(f"- 文件: `{func['file']}`")
            report.append(f"- 起始行: {func['start_line']}")
            report.append(f"- **重构建议**: 可选择性重构")
            report.append(f"- **优先级**: 低")
            report.append("")
    
    report.append("## 重构建议")
    report.append("")
    report.append("### 1. 分解策略")
    report.append("- **单一职责原则**: 每个函数只负责一个明确的任务")
    report.append("- **提取方法**: 将重复的代码块提取为独立函数")
    report.append("- **参数对象**: 对于参数过多的函数，考虑使用记录类型")
    report.append("")
    
    report.append("### 2. 优先级排序")
    report.append("1. 首先重构超过200行的严重级别函数")
    report.append("2. 然后处理150-200行的高级别函数")
    report.append("3. 最后考虑100-149行的中级别函数")
    report.append("")
    
    report.append("### 3. 实施步骤")
    report.append("1. **识别功能边界**: 确定可以独立的功能模块")
    report.append("2. **创建辅助函数**: 提取可重用的代码片段")
    report.append("3. **保持测试覆盖**: 重构过程中保持单元测试")
    report.append("4. **逐步重构**: 避免一次性大规模重构")
    
    return "\n".join(report)

if __name__ == "__main__":
    src_dir = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    long_functions = find_long_functions(src_dir, min_lines=100)
    
    report = generate_report(long_functions)
    print(report)
