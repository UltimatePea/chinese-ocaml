#!/usr/bin/env python3
"""
性能基准验证器 - Fix #1799

检测算法复杂度和性能回归问题的质量门控工具。
基于Beta代理对PR #1798性能问题的分析。

Author: Beta, 代码审查专家
"""

import re
import sys
import time
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
from collections import defaultdict


class PerformanceValidator:
    """性能基准验证器"""
    
    def __init__(self):
        self.performance_issues = []
        self.complexity_warnings = []
        self.benchmarks = {}
        
    def analyze_algorithm_complexity(self, file_path: Path) -> bool:
        """分析算法复杂度"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            self._detect_nested_loops(content, file_path)
            self._detect_inefficient_search(content, file_path)
            self._detect_recursive_patterns(content, file_path)
            
            return len(self.performance_issues) == 0
            
        except Exception as e:
            print(f"分析文件 {file_path} 性能时出错: {e}")
            return False
    
    def _detect_nested_loops(self, content: str, file_path: Path):
        """检测嵌套循环（可能导致O(n²)或更高复杂度）"""
        lines = content.split('\n')
        loop_depth = 0
        loop_stack = []
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # 检测循环开始
            if re.search(r'\b(List\.fold|List\.map|List\.filter|List\.iter|for\s+|while\s+)', stripped):
                loop_depth += 1
                loop_stack.append((i, stripped))
                
                if loop_depth >= 2:
                    self.performance_issues.append({
                        'type': 'nested_loops',
                        'file': str(file_path),
                        'line': i,
                        'severity': 'high' if loop_depth >= 3 else 'medium',
                        'message': f"检测到 {loop_depth} 层嵌套循环，可能导致O(n^{loop_depth})复杂度",
                        'code': stripped
                    })
            
            # 简化的循环结束检测
            if loop_depth > 0 and (stripped.endswith(')') or 'in' in stripped):
                loop_depth = max(0, loop_depth - 1)
                if loop_stack:
                    loop_stack.pop()
    
    def _detect_inefficient_search(self, content: str, file_path: Path):
        """检测低效搜索模式（如线性搜索）"""
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # 检测List.mem在循环中使用（O(n²)模式）
            if 'List.mem' in stripped and ('List.fold' in content or 'List.map' in content):
                self.performance_issues.append({
                    'type': 'inefficient_search',
                    'file': str(file_path),
                    'line': i,
                    'severity': 'high',
                    'message': "List.mem在循环中使用，建议使用Set或Hashtbl",
                    'code': stripped
                })
            
            # 检测find_opt在循环中使用
            if 'find_opt' in stripped and 'List.find_opt' in stripped:
                self.performance_issues.append({
                    'type': 'linear_search',
                    'file': str(file_path),
                    'line': i,
                    'severity': 'medium',
                    'message': "使用线性搜索List.find_opt，考虑使用哈希表优化",
                    'code': stripped
                })
    
    def _detect_recursive_patterns(self, content: str, file_path: Path):
        """检测可能导致栈溢出的递归模式"""
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # 检测没有尾递归优化的递归
            if re.search(r'let\s+rec\s+\w+', stripped):
                func_name = re.search(r'let\s+rec\s+(\w+)', stripped)
                if func_name:
                    name = func_name.group(1)
                    # 检查是否可能是尾递归
                    if f'{name}' in content and '|' in content:
                        self.complexity_warnings.append({
                            'type': 'recursion',
                            'file': str(file_path),
                            'line': i,
                            'severity': 'medium',
                            'message': f"递归函数 {name} 需要验证是否为尾递归优化",
                            'code': stripped
                        })
    
    def run_simple_benchmark(self, module_path: Path) -> Dict[str, Any]:
        """运行简单的性能基准测试"""
        if not module_path.exists():
            return {'error': f'模块文件不存在: {module_path}'}
        
        # 这里可以集成实际的OCaml性能测试
        # 当前仅提供框架
        return {
            'file': str(module_path),
            'timestamp': time.time(),
            'note': '需要集成实际OCaml基准测试'
        }
    
    def validate_performance_requirements(self, project_root: Path) -> bool:
        """验证性能要求"""
        poetry_src = project_root / "src" / "poetry"
        
        if not poetry_src.exists():
            return True
        
        success = True
        
        # 检查关键模块
        critical_modules = [
            "unified_rhyme_core_consolidated.ml",
            "data_manager.ml"
        ]
        
        for module_name in critical_modules:
            module_path = poetry_src / module_name
            if module_path.exists():
                module_success = self.analyze_algorithm_complexity(module_path)
                success = success and module_success
                
                # 运行基准测试
                benchmark = self.run_simple_benchmark(module_path)
                self.benchmarks[module_name] = benchmark
        
        return success
    
    def generate_performance_report(self) -> str:
        """生成性能分析报告"""
        report = []
        report.append("=" * 70)
        report.append("性能基准验证报告")
        report.append("=" * 70)
        
        # 性能问题
        if self.performance_issues:
            report.append(f"\n🚨 发现 {len(self.performance_issues)} 个性能问题:")
            for issue in self.performance_issues:
                severity_icon = "🔴" if issue['severity'] == 'high' else "🟡"
                report.append(f"\n{severity_icon} {issue['file']}:{issue['line']}")
                report.append(f"   类型: {issue['type']}")
                report.append(f"   严重程度: {issue['severity']}")
                report.append(f"   问题: {issue['message']}")
                report.append(f"   代码: {issue['code'][:80]}...")
        
        # 复杂度警告
        if self.complexity_warnings:
            report.append(f"\n⚠️ 发现 {len(self.complexity_warnings)} 个复杂度警告:")
            for warning in self.complexity_warnings:
                report.append(f"\n⚠️ {warning['file']}:{warning['line']}")
                report.append(f"   {warning['message']}")
        
        # 基准测试结果
        if self.benchmarks:
            report.append(f"\n📊 基准测试结果:")
            for module, benchmark in self.benchmarks.items():
                report.append(f"\n📈 {module}")
                if 'error' in benchmark:
                    report.append(f"   错误: {benchmark['error']}")
                else:
                    report.append(f"   状态: {benchmark.get('note', '已完成')}")
        
        if not self.performance_issues and not self.complexity_warnings:
            report.append("\n✅ 未发现明显的性能问题")
        
        report.append(f"\n总结: {len(self.performance_issues)} 性能问题, {len(self.complexity_warnings)} 复杂度警告")
        
        return "\n".join(report)
    
    def print_report(self):
        """打印报告"""
        print(self.generate_performance_report())
        return len(self.performance_issues) == 0


def main():
    """主函数"""
    project_root = Path.cwd()
    
    validator = PerformanceValidator()
    success = validator.validate_performance_requirements(project_root)
    validator.print_report()
    
    if not success:
        print(f"\n❌ 性能验证失败，发现 {len(validator.performance_issues)} 个性能问题")
        sys.exit(1)
    else:
        print("\n✅ 性能验证通过")
        sys.exit(0)


if __name__ == "__main__":
    main()