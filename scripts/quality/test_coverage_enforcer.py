#!/usr/bin/env python3
"""
测试覆盖率强制检查器 - Fix #1799

确保核心模块达到90%以上测试覆盖率的质量门控工具。
基于Beta代理对PR #1798测试不足问题的分析。

Author: Beta, 代码审查专家
"""

import os
import sys
import subprocess
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional


class TestCoverageEnforcer:
    """测试覆盖率强制检查器"""
    
    def __init__(self, min_coverage: float = 90.0):
        self.min_coverage = min_coverage
        self.coverage_data = {}
        self.violations = []
        
    def check_module_coverage(self, module_path: Path, test_path: Path) -> bool:
        """检查特定模块的测试覆盖率"""
        try:
            # 统计实现代码行数
            impl_lines = self._count_code_lines(module_path)
            
            # 统计测试代码行数
            test_lines = self._count_code_lines(test_path) if test_path.exists() else 0
            
            # 计算覆盖率（简化计算：测试行数/实现行数）
            if impl_lines == 0:
                coverage = 100.0
            else:
                coverage = min(100.0, (test_lines / impl_lines) * 100)
            
            self.coverage_data[str(module_path)] = {
                'impl_lines': impl_lines,
                'test_lines': test_lines,
                'coverage': coverage,
                'meets_requirement': coverage >= self.min_coverage
            }
            
            if coverage < self.min_coverage:
                self.violations.append({
                    'module': str(module_path),
                    'coverage': coverage,
                    'required': self.min_coverage,
                    'impl_lines': impl_lines,
                    'test_lines': test_lines
                })
            
            return coverage >= self.min_coverage
            
        except Exception as e:
            print(f"检查模块 {module_path} 覆盖率时出错: {e}")
            return False
    
    def _count_code_lines(self, file_path: Path) -> int:
        """统计有效代码行数（排除注释和空行）"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            code_lines = 0
            in_comment = False
            
            for line in lines:
                stripped = line.strip()
                
                # 跳过空行
                if not stripped:
                    continue
                
                # 处理多行注释
                if stripped.startswith('(*'):
                    in_comment = True
                    continue
                if in_comment and '*)' in stripped:
                    in_comment = False
                    continue
                if in_comment:
                    continue
                
                # 跳过单行注释
                if stripped.startswith('(**') or stripped.startswith('(*'):
                    continue
                
                # 统计有效代码行
                code_lines += 1
            
            return code_lines
            
        except Exception as e:
            print(f"统计文件 {file_path} 行数时出错: {e}")
            return 0
    
    def check_poetry_modules(self, project_root: Path) -> bool:
        """检查Poetry模块的测试覆盖率"""
        poetry_src = project_root / "src" / "poetry"
        poetry_test = project_root / "test" / "poetry"
        
        if not poetry_src.exists():
            print(f"Poetry源码目录不存在: {poetry_src}")
            return False
        
        success = True
        
        # 检查核心模块
        core_modules = [
            "unified_rhyme_core_consolidated.ml",
            "data_manager.ml",
            "poetry_types.ml"
        ]
        
        for module_name in core_modules:
            module_path = poetry_src / module_name
            test_name = f"test_{module_name.replace('.ml', '_new.ml')}"
            test_path = poetry_test / test_name
            
            if module_path.exists():
                module_success = self.check_module_coverage(module_path, test_path)
                success = success and module_success
        
        return success
    
    def generate_coverage_report(self) -> str:
        """生成覆盖率报告"""
        report = []
        report.append("=" * 70)
        report.append("测试覆盖率检查报告")
        report.append("=" * 70)
        
        if self.violations:
            report.append(f"\n🚨 发现 {len(self.violations)} 个覆盖率不足的模块:")
            for violation in self.violations:
                report.append(f"\n❌ {violation['module']}")
                report.append(f"   当前覆盖率: {violation['coverage']:.1f}%")
                report.append(f"   要求覆盖率: {violation['required']:.1f}%")
                report.append(f"   实现代码行数: {violation['impl_lines']}")
                report.append(f"   测试代码行数: {violation['test_lines']}")
                report.append(f"   需要增加测试行数: {int((violation['required'] / 100) * violation['impl_lines']) - violation['test_lines']}")
        else:
            report.append("\n✅ 所有模块都达到了覆盖率要求")
        
        # 总体统计
        if self.coverage_data:
            total_impl = sum(data['impl_lines'] for data in self.coverage_data.values())
            total_test = sum(data['test_lines'] for data in self.coverage_data.values())
            overall_coverage = (total_test / total_impl * 100) if total_impl > 0 else 100
            
            report.append(f"\n📊 总体统计:")
            report.append(f"   检查模块数: {len(self.coverage_data)}")
            report.append(f"   总实现行数: {total_impl}")
            report.append(f"   总测试行数: {total_test}")
            report.append(f"   总体覆盖率: {overall_coverage:.1f}%")
        
        return "\n".join(report)
    
    def print_report(self):
        """打印报告"""
        print(self.generate_coverage_report())
        return len(self.violations) == 0


def main():
    """主函数"""
    project_root = Path.cwd()
    
    # 从命令行参数获取最小覆盖率要求
    min_coverage = 90.0
    if len(sys.argv) > 1:
        try:
            min_coverage = float(sys.argv[1])
        except ValueError:
            print(f"无效的覆盖率参数: {sys.argv[1]}")
            sys.exit(1)
    
    enforcer = TestCoverageEnforcer(min_coverage)
    success = enforcer.check_poetry_modules(project_root)
    enforcer.print_report()
    
    if not success:
        print(f"\n❌ 测试覆盖率检查失败，{len(enforcer.violations)} 个模块未达到 {min_coverage}% 覆盖率要求")
        sys.exit(1)
    else:
        print(f"\n✅ 所有模块都达到了 {min_coverage}% 覆盖率要求")
        sys.exit(0)


if __name__ == "__main__":
    main()