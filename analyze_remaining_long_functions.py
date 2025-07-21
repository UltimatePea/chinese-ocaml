#!/usr/bin/env python3
"""
骆言项目剩余超长函数分析脚本
专门分析src/目录中剩余的超过60行的函数
重点关注parser、lexer等核心模块
"""

import os
import re
import sys
from typing import Dict, List, Tuple, NamedTuple
from collections import defaultdict
import json

class FunctionInfo(NamedTuple):
    name: str
    file_path: str
    start_line: int
    end_line: int
    line_count: int
    complexity_score: int

class LongFunctionAnalyzer:
    def __init__(self, src_dir: str, min_lines: int = 60):
        self.src_dir = src_dir
        self.min_lines = min_lines
        self.core_modules = {
            'parser': ['parser.ml', 'parser_expressions.ml', 'parser_statements.ml', 'parser_patterns.ml'],
            'lexer': ['lexer.ml', 'lexer_utils.ml', 'lexer_token_converter.ml'],
            'codegen': ['codegen.ml', 'c_codegen.ml'],
            'types': ['types.ml', 'types_infer.ml', 'types_unify.ml'],
            'interpreter': ['interpreter.ml', 'expression_evaluator.ml'],
            'semantic': ['semantic.ml', 'semantic_expressions.ml']
        }
        self.priority_files = []
        for files in self.core_modules.values():
            self.priority_files.extend(files)

    def analyze_function_complexity(self, content: str, start_line: int, end_line: int) -> int:
        """分析函数复杂度评分"""
        function_lines = content.split('\n')[start_line-1:end_line]
        function_content = '\n'.join(function_lines)
        
        complexity = 0
        
        # 控制流复杂度
        complexity += len(re.findall(r'\bif\b', function_content)) * 2
        complexity += len(re.findall(r'\bmatch\b', function_content)) * 3
        complexity += len(re.findall(r'\bwhile\b', function_content)) * 2
        complexity += len(re.findall(r'\bfor\b', function_content)) * 2
        complexity += len(re.findall(r'\btry\b', function_content)) * 2
        
        # 嵌套深度
        max_indent = 0
        for line in function_lines:
            if line.strip():
                indent = len(line) - len(line.lstrip())
                max_indent = max(max_indent, indent)
        complexity += max_indent // 2
        
        # 模式匹配复杂度
        pattern_count = len(re.findall(r'\|', function_content))
        complexity += pattern_count
        
        return complexity

    def find_functions_in_file(self, file_path: str) -> List[FunctionInfo]:
        """在单个文件中查找函数定义"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"无法读取文件 {file_path}: {e}")
            return []

        lines = content.split('\n')
        functions = []
        
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            
            # 查找函数定义
            let_match = re.search(r'^let\s+(rec\s+)?([a-zA-Z_][a-zA-Z0-9_\']*)', line)
            and_match = re.search(r'^and\s+([a-zA-Z_][a-zA-Z0-9_\']*)', line)
            
            if let_match or and_match:
                if let_match:
                    func_name = let_match.group(2) if let_match.group(1) else let_match.group(2)
                else:
                    func_name = and_match.group(1)
                
                start_line = i + 1
                
                # 查找函数结束位置
                end_line = self.find_function_end(lines, i)
                line_count = end_line - start_line + 1
                
                if line_count >= self.min_lines:
                    complexity = self.analyze_function_complexity(content, start_line, end_line)
                    
                    functions.append(FunctionInfo(
                        name=func_name,
                        file_path=file_path,
                        start_line=start_line,
                        end_line=end_line,
                        line_count=line_count,
                        complexity_score=complexity
                    ))
                
                i = end_line
            else:
                i += 1
        
        return functions

    def find_function_end(self, lines: List[str], start_idx: int) -> int:
        """查找函数定义的结束位置"""
        # 简化的函数结束检测
        indent_level = len(lines[start_idx]) - len(lines[start_idx].lstrip())
        
        i = start_idx + 1
        while i < len(lines):
            line = lines[i]
            
            # 空行跳过
            if not line.strip():
                i += 1
                continue
                
            current_indent = len(line) - len(line.lstrip())
            
            # 如果遇到同级别或更低级别的 let/and/in/end 等，说明函数结束
            if current_indent <= indent_level:
                if re.match(r'^\s*(let|and|in|end|type|module|val)', line):
                    return i - 1
            
            i += 1
        
        return len(lines) - 1

    def analyze_directory(self) -> List[FunctionInfo]:
        """分析整个src目录"""
        all_functions = []
        
        for root, dirs, files in os.walk(self.src_dir):
            # 跳过特定目录
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            
            for file in files:
                if file.endswith('.ml'):
                    file_path = os.path.join(root, file)
                    functions = self.find_functions_in_file(file_path)
                    all_functions.extend(functions)
        
        # 按行数和复杂度排序
        all_functions.sort(key=lambda f: (f.line_count + f.complexity_score), reverse=True)
        return all_functions

    def categorize_by_module(self, functions: List[FunctionInfo]) -> Dict[str, List[FunctionInfo]]:
        """按模块类型分类函数"""
        categorized = defaultdict(list)
        
        for func in functions:
            file_name = os.path.basename(func.file_path)
            
            # 确定模块类别
            category = 'other'
            for module_type, files in self.core_modules.items():
                if any(file_name.startswith(f.replace('.ml', '')) for f in files):
                    category = module_type
                    break
            
            categorized[category].append(func)
        
        return dict(categorized)

    def generate_report(self, functions: List[FunctionInfo]) -> str:
        """生成分析报告"""
        if not functions:
            return "未发现超过60行的函数"
        
        categorized = self.categorize_by_module(functions)
        
        report = "# 骆言项目剩余超长函数分析报告\n\n"
        report += f"## 总体统计\n"
        report += f"- 总计发现超过{self.min_lines}行的函数: {len(functions)}个\n"
        report += f"- 涉及文件数: {len(set(f.file_path for f in functions))}个\n\n"
        
        # 按优先级排序的前5个函数
        report += "## 前5个优先重构的超长函数\n\n"
        priority_functions = []
        
        # 优先核心模块
        for category in ['parser', 'lexer', 'codegen', 'types', 'interpreter', 'semantic']:
            if category in categorized:
                priority_functions.extend(categorized[category])
        
        # 补充其他函数
        if 'other' in categorized:
            priority_functions.extend(categorized['other'])
        
        for i, func in enumerate(priority_functions[:5], 1):
            file_rel_path = os.path.relpath(func.file_path, self.src_dir)
            report += f"### {i}. {func.name} ({file_rel_path})\n"
            report += f"- **文件路径**: `{func.file_path}`\n"
            report += f"- **函数名**: `{func.name}`\n"
            report += f"- **行数**: {func.line_count}行 (第{func.start_line}-{func.end_line}行)\n"
            report += f"- **复杂度评分**: {func.complexity_score}\n"
            report += f"- **综合评分**: {func.line_count + func.complexity_score}\n\n"
        
        # 按模块分类统计
        report += "## 按模块分类统计\n\n"
        for category, funcs in categorized.items():
            if funcs:
                report += f"### {category.upper()}模块\n"
                report += f"超长函数数量: {len(funcs)}个\n\n"
                for func in funcs[:3]:  # 每个模块显示前3个
                    file_rel_path = os.path.relpath(func.file_path, self.src_dir)
                    report += f"- `{func.name}` ({file_rel_path}) - {func.line_count}行\n"
                if len(funcs) > 3:
                    report += f"- ... 还有{len(funcs) - 3}个函数\n"
                report += "\n"
        
        # 重构建议
        report += "## 重构建议\n\n"
        report += "### 立即行动项\n"
        for i, func in enumerate(priority_functions[:5], 1):
            report += f"{i}. **{func.name}函数重构**: 建议分解为多个子函数，降低复杂度\n"
        
        report += "\n### 重构策略\n"
        report += "1. **函数分解**: 将超长函数拆分为多个功能单一的子函数\n"
        report += "2. **提取公共逻辑**: 识别重复代码并提取为共用函数\n"
        report += "3. **简化控制流**: 减少嵌套深度，使用早期返回模式\n"
        report += "4. **引入数据结构**: 使用记录类型或变体类型简化参数传递\n"
        
        return report

def main():
    if len(sys.argv) > 1:
        src_dir = sys.argv[1]
    else:
        src_dir = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    
    if not os.path.exists(src_dir):
        print(f"源码目录不存在: {src_dir}")
        return 1
    
    analyzer = LongFunctionAnalyzer(src_dir)
    print("正在分析骆言项目中的超长函数...")
    
    functions = analyzer.analyze_directory()
    report = analyzer.generate_report(functions)
    
    print(report)
    
    # 保存到文件
    report_file = "remaining_long_functions_analysis_report.md"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    print(f"\n分析报告已保存到: {report_file}")
    
    # 保存JSON格式数据
    json_data = {
        'total_functions': len(functions),
        'analysis_date': '2025-07-21',
        'functions': [
            {
                'name': f.name,
                'file_path': f.file_path,
                'line_count': f.line_count,
                'complexity_score': f.complexity_score,
                'start_line': f.start_line,
                'end_line': f.end_line
            }
            for f in functions[:10]  # 只保存前10个
        ]
    }
    
    with open('remaining_long_functions_data.json', 'w', encoding='utf-8') as f:
        json.dump(json_data, f, ensure_ascii=False, indent=2)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())