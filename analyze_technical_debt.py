#!/usr/bin/env python3
"""
骆言项目技术债务分析工具
分析OCaml代码中的技术债务问题
"""

import os
import re
import sys
from typing import List, Dict, Tuple, Set
from collections import defaultdict

class TechnicalDebtAnalyzer:
    def __init__(self, src_dir: str):
        self.src_dir = src_dir
        self.long_functions = []
        self.complex_patterns = []
        self.duplicate_patterns = []
        self.nested_issues = []
        self.error_handling_issues = []
        
    def analyze_all(self):
        """分析所有技术债务问题"""
        print("开始分析骆言项目技术债务...")
        
        for root, dirs, files in os.walk(self.src_dir):
            for file in files:
                if file.endswith('.ml'):
                    filepath = os.path.join(root, file)
                    self.analyze_file(filepath)
        
        self.generate_report()
    
    def analyze_file(self, filepath: str):
        """分析单个文件"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
                
            # 分析长函数
            self.find_long_functions(filepath, lines)
            
            # 分析复杂模式匹配
            self.find_complex_patterns(filepath, content)
            
            # 分析深层嵌套
            self.find_nested_issues(filepath, lines)
            
            # 分析重复代码
            self.find_duplicate_patterns(filepath, content)
            
            # 分析错误处理
            self.find_error_handling_issues(filepath, content)
            
        except Exception as e:
            print(f"分析文件 {filepath} 时出错: {e}")
    
    def find_long_functions(self, filepath: str, lines: List[str]):
        """查找超过50行的长函数"""
        in_function = False
        function_start = 0
        function_name = ""
        brace_count = 0
        
        for i, line in enumerate(lines):
            stripped = line.strip()
            
            # 检测函数开始
            func_match = re.match(r'^\s*let\s+(?:rec\s+)?(\w+)', stripped)
            if func_match and not in_function:
                function_name = func_match.group(1)
                function_start = i + 1
                in_function = True
                brace_count = 0
            
            # 统计括号和缩进来确定函数结束
            if in_function:
                brace_count += stripped.count('(') - stripped.count(')')
                
                # 检测函数结束（简化版）
                if (stripped.startswith('let ') and i > function_start + 5 and brace_count <= 0) or \
                   (stripped == '' and brace_count <= 0 and i > function_start + 10):
                    
                    function_length = i - function_start + 1
                    if function_length > 50:
                        self.long_functions.append({
                            'file': filepath,
                            'function': function_name,
                            'start_line': function_start,
                            'length': function_length,
                            'complexity': self.calculate_complexity(lines[function_start:i+1])
                        })
                    
                    in_function = False
                    function_name = ""
                    brace_count = 0
    
    def calculate_complexity(self, function_lines: List[str]) -> int:
        """计算函数复杂度"""
        complexity = 1  # 基础复杂度
        
        for line in function_lines:
            stripped = line.strip()
            # 条件语句
            if re.search(r'\bif\b|\bmatch\b|\bwhen\b', stripped):
                complexity += 1
            # 循环
            if re.search(r'\bfor\b|\bwhile\b', stripped):
                complexity += 1
            # 异常处理
            if re.search(r'\btry\b|\bwith\b', stripped):
                complexity += 1
        
        return complexity
    
    def find_complex_patterns(self, filepath: str, content: str):
        """查找复杂的模式匹配"""
        # 查找深层嵌套的match表达式
        match_patterns = re.finditer(r'match\s+.*?\s+with', content, re.DOTALL)
        
        for match in match_patterns:
            start_pos = match.start()
            lines_before = content[:start_pos].count('\n')
            
            # 计算match表达式的复杂度
            match_content = self.extract_match_content(content, match.start())
            if match_content:
                branch_count = match_content.count('|')
                nesting_level = self.calculate_nesting_level(match_content)
                
                if branch_count > 10 or nesting_level > 3:
                    self.complex_patterns.append({
                        'file': filepath,
                        'line': lines_before + 1,
                        'branches': branch_count,
                        'nesting_level': nesting_level,
                        'type': 'complex_match'
                    })
    
    def extract_match_content(self, content: str, start_pos: int) -> str:
        """提取match表达式的内容"""
        # 简化版本，实际实现需要更复杂的解析
        end_pos = start_pos
        brace_count = 0
        in_match = False
        
        for i in range(start_pos, len(content)):
            if content[i:i+4] == 'with':
                in_match = True
                continue
            
            if in_match:
                if content[i] == '(':
                    brace_count += 1
                elif content[i] == ')':
                    brace_count -= 1
                elif content[i:i+3] == 'let' and brace_count == 0:
                    break
                end_pos = i
        
        return content[start_pos:end_pos]
    
    def calculate_nesting_level(self, content: str) -> int:
        """计算嵌套层次"""
        max_level = 0
        current_level = 0
        
        for line in content.split('\n'):
            stripped = line.strip()
            if 'match' in stripped:
                current_level += 1
                max_level = max(max_level, current_level)
            elif stripped.startswith('|') and current_level > 0:
                # 模式匹配分支
                pass
            elif stripped == '':
                if current_level > 0:
                    current_level -= 1
        
        return max_level
    
    def find_nested_issues(self, filepath: str, lines: List[str]):
        """查找深层嵌套问题"""
        for i, line in enumerate(lines):
            indent_level = len(line) - len(line.lstrip())
            
            # 检测深层嵌套
            if indent_level > 20:  # 超过20个空格的缩进
                self.nested_issues.append({
                    'file': filepath,
                    'line': i + 1,
                    'indent_level': indent_level,
                    'content': line.strip()[:100]  # 前100个字符
                })
    
    def find_duplicate_patterns(self, filepath: str, content: str):
        """查找重复代码模式"""
        # 查找重复的错误处理模式
        error_patterns = [
            r'failwith\s+"[^"]*"',
            r'raise\s+\([^)]*\)',
            r'try\s+.*?\s+with\s+.*?\s+->\s+.*?',
        ]
        
        for pattern in error_patterns:
            matches = re.findall(pattern, content, re.DOTALL)
            if len(matches) > 3:  # 出现超过3次
                self.duplicate_patterns.append({
                    'file': filepath,
                    'pattern': 'error_handling',
                    'count': len(matches),
                    'example': matches[0][:100]
                })
    
    def find_error_handling_issues(self, filepath: str, content: str):
        """分析错误处理一致性"""
        # 查找不一致的错误处理模式
        error_handling_styles = {
            'failwith': len(re.findall(r'failwith', content)),
            'raise': len(re.findall(r'raise', content)),
            'Option': len(re.findall(r'Some\s+|None\s+', content)),
            'Result': len(re.findall(r'Ok\s+|Error\s+', content)),
        }
        
        # 如果使用了多种错误处理风格
        used_styles = sum(1 for count in error_handling_styles.values() if count > 0)
        if used_styles > 2:
            self.error_handling_issues.append({
                'file': filepath,
                'issue': 'inconsistent_error_handling',
                'styles': {k: v for k, v in error_handling_styles.items() if v > 0}
            })
    
    def generate_report(self):
        """生成技术债务报告"""
        print("\n" + "="*80)
        print("骆言项目技术债务分析报告")
        print("="*80)
        
        # 1. 长函数分析
        print(f"\n1. 长函数分析（超过50行）")
        print(f"   发现 {len(self.long_functions)} 个长函数")
        
        if self.long_functions:
            # 按长度排序
            sorted_functions = sorted(self.long_functions, key=lambda x: x['length'], reverse=True)
            for func in sorted_functions[:10]:  # 显示前10个最长的
                print(f"   📁 {func['file']}")
                print(f"   🔧 函数: {func['function']}")
                print(f"   📏 长度: {func['length']} 行 (第 {func['start_line']} 行开始)")
                print(f"   🔥 复杂度: {func['complexity']}")
                print(f"   💡 建议: 考虑拆分为多个更小的函数")
                print()
        
        # 2. 复杂模式匹配
        print(f"\n2. 复杂模式匹配分析")
        print(f"   发现 {len(self.complex_patterns)} 个复杂模式匹配")
        
        for pattern in self.complex_patterns:
            print(f"   📁 {pattern['file']}:{pattern['line']}")
            print(f"   🌿 分支数: {pattern['branches']}")
            print(f"   🏗️ 嵌套层次: {pattern['nesting_level']}")
            print(f"   💡 建议: 考虑使用辅助函数或重构模式匹配")
            print()
        
        # 3. 深层嵌套问题
        print(f"\n3. 深层嵌套分析")
        print(f"   发现 {len(self.nested_issues)} 个深层嵌套问题")
        
        for issue in self.nested_issues[:5]:  # 显示前5个
            print(f"   📁 {issue['file']}:{issue['line']}")
            print(f"   🔄 缩进层次: {issue['indent_level']} 空格")
            print(f"   📝 内容: {issue['content']}")
            print(f"   💡 建议: 考虑提取函数或使用早期返回")
            print()
        
        # 4. 重复代码分析
        print(f"\n4. 重复代码分析")
        print(f"   发现 {len(self.duplicate_patterns)} 个重复模式")
        
        for dup in self.duplicate_patterns:
            print(f"   📁 {dup['file']}")
            print(f"   🔁 模式: {dup['pattern']}")
            print(f"   🔢 出现次数: {dup['count']}")
            print(f"   📝 示例: {dup['example']}")
            print(f"   💡 建议: 考虑提取为通用函数或模块")
            print()
        
        # 5. 错误处理一致性
        print(f"\n5. 错误处理一致性分析")
        print(f"   发现 {len(self.error_handling_issues)} 个不一致的错误处理")
        
        for issue in self.error_handling_issues:
            print(f"   📁 {issue['file']}")
            print(f"   ⚠️ 问题: {issue['issue']}")
            print(f"   🎭 使用的风格: {issue['styles']}")
            print(f"   💡 建议: 统一错误处理风格，优先使用Result类型")
            print()
        
        # 6. 总结和建议
        print(f"\n6. 总结和优先级建议")
        print(f"   🔥 高优先级:")
        
        high_priority = []
        if len(self.long_functions) > 0:
            high_priority.append(f"   • 重构 {len(self.long_functions)} 个长函数")
        if len(self.complex_patterns) > 0:
            high_priority.append(f"   • 简化 {len(self.complex_patterns)} 个复杂模式匹配")
        if len(self.error_handling_issues) > 0:
            high_priority.append(f"   • 统一 {len(self.error_handling_issues)} 个文件的错误处理")
        
        for item in high_priority:
            print(item)
        
        print(f"\n   🟡 中优先级:")
        medium_priority = []
        if len(self.nested_issues) > 0:
            medium_priority.append(f"   • 优化 {len(self.nested_issues)} 个深层嵌套问题")
        if len(self.duplicate_patterns) > 0:
            medium_priority.append(f"   • 消除 {len(self.duplicate_patterns)} 个重复代码模式")
        
        for item in medium_priority:
            print(item)
        
        print(f"\n   📊 整体健康度评分:")
        total_issues = (len(self.long_functions) + len(self.complex_patterns) + 
                       len(self.nested_issues) + len(self.duplicate_patterns) + 
                       len(self.error_handling_issues))
        
        if total_issues < 10:
            health_score = "A (优秀)"
        elif total_issues < 20:
            health_score = "B (良好)"
        elif total_issues < 30:
            health_score = "C (一般)"
        else:
            health_score = "D (需要改进)"
        
        print(f"   🏆 {health_score} - 总计 {total_issues} 个技术债务问题")
        
        print("\n" + "="*80)

if __name__ == "__main__":
    analyzer = TechnicalDebtAnalyzer("/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src")
    analyzer.analyze_all()