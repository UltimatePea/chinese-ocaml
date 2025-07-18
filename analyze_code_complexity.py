#\!/usr/bin/env python3
"""
更精确的OCaml代码复杂度分析
"""

import os
import re
import glob
from typing import List, Dict, Tuple

def is_data_definition(lines: List[str]) -> bool:
    """判断是否为纯数据定义"""
    content = ''.join(lines)
    
    # 如果主要由简单的数据结构组成（列表、元组等），认为是数据定义
    data_patterns = [
        r'^\s*\[[\s\S]*\]\s*$',  # 列表定义
        r'^\s*\{[\s\S]*\}\s*$',  # 记录定义
    ]
    
    for pattern in data_patterns:
        if re.search(pattern, content, re.MULTILINE):
            return True
    
    # 检查是否主要由简单的构造器组成
    lines_with_logic = 0
    total_meaningful_lines = 0
    
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith('(*') or stripped.startswith('('):
            continue
            
        total_meaningful_lines += 1
        
        # 检查是否包含逻辑（控制流、函数调用等）
        if any(keyword in stripped for keyword in [
            'if ', 'match ', 'let ', 'fun ', 'function',
            '如果', '匹配', '让', '函数'
        ]):
            lines_with_logic += 1
    
    if total_meaningful_lines == 0:
        return True
        
    # 如果90%以上的行都是简单数据，认为是数据定义
    return (lines_with_logic / total_meaningful_lines) < 0.1

def analyze_function_complexity(func_lines: List[str]) -> Dict:
    """分析函数的实际复杂度"""
    complexity = {
        'cyclomatic_complexity': 1,  # 基础复杂度
        'nesting_depth': 0,
        'max_nesting': 0,
        'conditions': 0,
        'loops': 0,
        'pattern_matches': 0,
        'function_calls': 0,
        'is_data_definition': False,
        'has_recursion': False,
        'parameter_count': 0
    }
    
    # 检查是否为数据定义
    if is_data_definition(func_lines):
        complexity['is_data_definition'] = True
        return complexity
    
    func_name = None
    current_nesting = 0
    
    for line in func_lines:
        stripped = line.strip()
        
        # 获取函数名和参数
        if not func_name:
            let_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)\s*(.*)$', stripped)
            and_match = re.match(r'^and\s+([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)\s*(.*)$', stripped)
            
            if let_match:
                func_name = let_match.group(2)
                params_part = let_match.group(3)
                # 简单统计参数（不精确但有用）
                complexity['parameter_count'] = params_part.count(' ') if params_part else 0
            elif and_match:
                func_name = and_match.group(1)
        
        # 统计条件语句
        if re.search(r'\bif\b < /dev/null | \b如果\b|\bthen\b|\belse\b|\b那么\b|\b否则\b', stripped):
            complexity['conditions'] += 1
            complexity['cyclomatic_complexity'] += 1
        
        # 统计循环
        if re.search(r'\bfor\b|\bwhile\b|\brecursive\b|\b递归\b', stripped):
            complexity['loops'] += 1
            complexity['cyclomatic_complexity'] += 1
        
        # 统计模式匹配
        if re.search(r'\bmatch\b|\bwith\b|\b匹配\b|\b与\b', stripped):
            complexity['pattern_matches'] += 1
            complexity['cyclomatic_complexity'] += 1
        
        # 统计函数调用
        if re.search(r'[a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*\s*\(', stripped):
            complexity['function_calls'] += 1
        
        # 检查递归
        if func_name and func_name in stripped and stripped != func_lines[0]:
            complexity['has_recursion'] = True
        
        # 计算嵌套深度
        for char in stripped:
            if char in '({[':
                current_nesting += 1
                complexity['max_nesting'] = max(complexity['max_nesting'], current_nesting)
            elif char in ')}]':
                current_nesting = max(0, current_nesting - 1)
    
    return complexity

def find_complex_functions(src_dir: str) -> List[Dict]:
    """查找复杂函数（排除数据定义）"""
    complex_functions = []
    
    ml_files = glob.glob(os.path.join(src_dir, "**/*.ml"), recursive=True)
    
    for file_path in ml_files:
        if '/test/' in file_path or 'test_' in os.path.basename(file_path):
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except:
            continue
        
        current_function = None
        
        for line_num, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # 检测函数定义
            let_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
            and_match = re.match(r'^and\s+([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
            
            if let_match or and_match:
                # 保存前一个函数
                if current_function and len(current_function['lines']) > 50:  # 降低行数阈值
                    complexity = analyze_function_complexity(current_function['lines'])
                    
                    if not complexity['is_data_definition']:
                        current_function['complexity'] = complexity
                        current_function['line_count'] = len(current_function['lines'])
                        
                        # 基于复杂度判断是否需要重构
                        if (current_function['line_count'] > 100 or 
                            complexity['cyclomatic_complexity'] > 10 or
                            complexity['max_nesting'] > 5):
                            complex_functions.append(current_function)
                
                # 开始新函数
                func_name = let_match.group(2) if let_match else and_match.group(1)
                current_function = {
                    'name': func_name,
                    'start_line': line_num,
                    'lines': [line],
                    'file': file_path
                }
            elif current_function:
                if (stripped.startswith('let ') or stripped.startswith('and ') or 
                    stripped.startswith('type ') or stripped.startswith('module ') or 
                    stripped.startswith('exception ')):
                    # 函数结束
                    if len(current_function['lines']) > 50:
                        complexity = analyze_function_complexity(current_function['lines'])
                        
                        if not complexity['is_data_definition']:
                            current_function['complexity'] = complexity
                            current_function['line_count'] = len(current_function['lines'])
                            
                            if (current_function['line_count'] > 100 or 
                                complexity['cyclomatic_complexity'] > 10 or
                                complexity['max_nesting'] > 5):
                                complex_functions.append(current_function)
                    
                    # 检查新的函数定义
                    let_match = re.match(r'^let\s+(rec\s+)?([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
                    and_match = re.match(r'^and\s+([a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*)', stripped)
                    
                    if let_match or and_match:
                        func_name = let_match.group(2) if let_match else and_match.group(1)
                        current_function = {
                            'name': func_name,
                            'start_line': line_num,
                            'lines': [line],
                            'file': file_path
                        }
                    else:
                        current_function = None
                else:
                    current_function['lines'].append(line)
        
        # 处理文件末尾的函数
        if current_function and len(current_function['lines']) > 50:
            complexity = analyze_function_complexity(current_function['lines'])
            
            if not complexity['is_data_definition']:
                current_function['complexity'] = complexity
                current_function['line_count'] = len(current_function['lines'])
                
                if (current_function['line_count'] > 100 or 
                    complexity['cyclomatic_complexity'] > 10 or
                    complexity['max_nesting'] > 5):
                    complex_functions.append(current_function)
    
    return sorted(complex_functions, key=lambda x: x['complexity']['cyclomatic_complexity'], reverse=True)

def generate_comprehensive_report(complex_functions: List[Dict]) -> str:
    """生成全面的技术债务分析报告"""
    report = []
    report.append("# 骆言项目技术债务分析报告")
    report.append("")
    report.append("## 执行摘要")
    
    if not complex_functions:
        report.append("✅ **优秀！** 项目代码质量良好，没有发现需要重构的复杂函数。")
        report.append("")
        report.append("### 分析结果")
        report.append("- 超过100行的非数据定义函数：0个")
        report.append("- 环形复杂度超过10的函数：0个")
        report.append("- 嵌套深度超过5的函数：0个")
        report.append("")
        report.append("### 项目优势")
        report.append("1. **函数长度控制良好**：所有函数都保持在合理长度内")
        report.append("2. **复杂度适中**：函数的环形复杂度都在可接受范围内")
        report.append("3. **嵌套层次合理**：代码结构清晰，嵌套层次不深")
        report.append("")
        report.append("### 继续保持的最佳实践")
        report.append("- 遵循单一职责原则")
        report.append("- 控制函数长度在100行以内")
        report.append("- 保持适度的复杂度")
        report.append("- 使用清晰的命名和注释")
        return "\n".join(report)
    
    total_functions = len(complex_functions)
    avg_lines = sum(f['line_count'] for f in complex_functions) // total_functions
    avg_complexity = sum(f['complexity']['cyclomatic_complexity'] for f in complex_functions) // total_functions
    
    report.append(f"- 发现 {total_functions} 个需要关注的复杂函数")
    report.append(f"- 平均长度：{avg_lines} 行")
    report.append(f"- 平均环形复杂度：{avg_complexity}")
    report.append("")
    
    # 按问题类型分类
    long_functions = [f for f in complex_functions if f['line_count'] > 100]
    complex_logic = [f for f in complex_functions if f['complexity']['cyclomatic_complexity'] > 10]
    deep_nesting = [f for f in complex_functions if f['complexity']['max_nesting'] > 5]
    
    report.append("## 详细分析")
    report.append("")
    
    if long_functions:
        report.append("### 🔴 长函数问题 (>100行)")
        for func in long_functions:
            complexity = func['complexity']
            report.append(f"**{func['name']}** ({func['line_count']}行)")
            report.append(f"- 文件：`{func['file']}`")
            report.append(f"- 起始行：{func['start_line']}")
            report.append(f"- 环形复杂度：{complexity['cyclomatic_complexity']}")
            report.append(f"- 最大嵌套深度：{complexity['max_nesting']}")
            report.append(f"- 条件语句数：{complexity['conditions']}")
            report.append(f"- 模式匹配数：{complexity['pattern_matches']}")
            if complexity['has_recursion']:
                report.append(f"- ⚠️ 包含递归调用")
            report.append("")
    
    if complex_logic:
        report.append("### 🟡 逻辑复杂度过高 (环形复杂度>10)")
        for func in complex_logic:
            if func not in long_functions:  # 避免重复
                complexity = func['complexity']
                report.append(f"**{func['name']}** (复杂度：{complexity['cyclomatic_complexity']})")
                report.append(f"- 文件：`{func['file']}`")
                report.append(f"- 行数：{func['line_count']}")
                report.append(f"- 条件分支：{complexity['conditions']}")
                report.append("")
    
    if deep_nesting:
        report.append("### 🟠 嵌套过深 (>5层)")
        for func in deep_nesting:
            if func not in long_functions and func not in complex_logic:  # 避免重复
                complexity = func['complexity']
                report.append(f"**{func['name']}** (最大嵌套：{complexity['max_nesting']}层)")
                report.append(f"- 文件：`{func['file']}`")
                report.append(f"- 行数：{func['line_count']}")
                report.append("")
    
    report.append("## 重构建议")
    report.append("")
    
    report.append("### 优先级排序")
    report.append("1. **立即处理**：长函数（>100行）且高复杂度（>10）")
    report.append("2. **短期处理**：长函数或高复杂度函数")
    report.append("3. **中期处理**：嵌套过深的函数")
    report.append("")
    
    report.append("### 具体重构策略")
    report.append("")
    report.append("#### 1. 函数分解")
    report.append("- **提取方法**：将独立的功能块提取为独立函数")
    report.append("- **参数对象**：使用记录类型减少参数数量")
    report.append("- **策略模式**：将条件分支转换为模式匹配")
    report.append("")
    
    report.append("#### 2. 复杂度降低")
    report.append("- **早期返回**：使用早期返回减少嵌套")
    report.append("- **状态机**：将复杂的状态逻辑重构为状态机")
    report.append("- **组合函数**：使用函数组合替代长链式调用")
    report.append("")
    
    report.append("#### 3. 代码组织")
    report.append("- **模块拆分**：将相关函数组织到专门的模块中")
    report.append("- **接口抽象**：定义清晰的模块接口")
    report.append("- **文档完善**：为复杂函数添加详细注释")
    
    return "\n".join(report)

if __name__ == "__main__":
    src_dir = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    complex_functions = find_complex_functions(src_dir)
    
    report = generate_comprehensive_report(complex_functions)
    print(report)
