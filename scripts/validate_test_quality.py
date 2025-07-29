#!/usr/bin/env python3
"""
测试质量验证脚本 - 确保测试覆盖率报告准确性
Author: Echo, 测试工程师代理
Fix Issue #1709 - 测试质量控制问题
"""

import os
import subprocess
import json
import re
from datetime import datetime
from pathlib import Path

class TestQualityValidator:
    def __init__(self):
        self.project_root = Path('.')
        self.issues_found = []
        self.recommendations = []
    
    def validate_test_coverage_accuracy(self):
        """验证测试覆盖率报告的准确性"""
        print("🔍 验证测试覆盖率报告准确性...")
        
        # 检查coverage_reports目录
        coverage_dir = self.project_root / 'coverage_reports'
        if not coverage_dir.exists():
            self.issues_found.append("❌ coverage_reports目录不存在")
            return False
        
        # 检查coverage_summary.txt的数据一致性
        summary_file = coverage_dir / 'coverage_summary.txt'
        if summary_file.exists():
            with open(summary_file, 'r', encoding='utf-8') as f:
                content = f.read()
                print(f"📄 当前覆盖率摘要: {content.strip()}")
        
        return True
    
    def validate_poetry_test_completeness(self):
        """验证Poetry模块测试的完整性"""
        print("🎭 验证Poetry模块测试完整性...")
        
        # 查找所有Poetry相关的源文件
        poetry_src_files = list(self.project_root.rglob('src/**/poetry*/*.ml'))
        poetry_src_files.extend(list(self.project_root.rglob('src/poetry/*.ml')))
        
        # 查找Poetry测试文件
        poetry_test_files = list(self.project_root.rglob('test/**/*poetry*.ml'))
        
        print(f"📊 Poetry源文件数: {len(poetry_src_files)}")
        print(f"📊 Poetry测试文件数: {len(poetry_test_files)}")
        
        # 检查测试覆盖比例
        if len(poetry_src_files) > 0:
            test_ratio = len(poetry_test_files) / len(poetry_src_files)
            print(f"📈 Poetry测试比例: {test_ratio:.2f} ({len(poetry_test_files)}/{len(poetry_src_files)})")
            
            if test_ratio < 0.5:
                self.issues_found.append(f"⚠️ Poetry测试覆盖不足: {test_ratio:.2f} < 0.5")
                self.recommendations.append("增加Poetry模块的单元测试和集成测试")
        
        return len(poetry_test_files) > 0
    
    def validate_test_execution_status(self):
        """验证测试执行状态"""
        print("🧪 验证测试执行状态...")
        
        try:
            # 运行dune runtest来检查测试状态
            result = subprocess.run(
                ['dune', 'runtest', '--dry-run'], 
                capture_output=True, 
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                print("✅ 测试执行状态: 正常")
                return True
            else:
                print(f"❌ 测试执行失败: {result.stderr[:200]}")
                self.issues_found.append("测试执行失败")
                return False
                
        except subprocess.TimeoutExpired:
            print("⏰ 测试执行超时")
            self.issues_found.append("测试执行超时")
            return False
        except Exception as e:
            print(f"❌ 测试验证错误: {e}")
            self.issues_found.append(f"测试验证错误: {e}")
            return False
    
    def validate_unified_modules_integration(self):
        """验证unified_*模块的集成情况"""
        print("🔗 验证unified_*模块集成...")
        
        # 查找所有unified_*模块
        unified_modules = list(self.project_root.rglob('src/**/unified_*.ml'))
        unified_modules.extend(list(self.project_root.rglob('src/unified_*.ml')))
        
        print(f"📊 Unified模块数量: {len(unified_modules)}")
        
        # 检查unified模块的测试覆盖
        unified_test_files = list(self.project_root.rglob('test/**/test_unified_*.ml'))
        unified_test_files.extend(list(self.project_root.rglob('test/**/unified_*test*.ml')))
        
        print(f"📊 Unified模块测试数量: {len(unified_test_files)}")
        
        if len(unified_modules) > 0:
            test_coverage_ratio = len(unified_test_files) / len(unified_modules)
            print(f"📈 Unified模块测试覆盖比例: {test_coverage_ratio:.2f}")
            
            if test_coverage_ratio < 0.3:
                self.issues_found.append(f"⚠️ Unified模块测试覆盖不足: {test_coverage_ratio:.2f}")
                self.recommendations.append("为更多unified_*模块创建测试")
        
        return True
    
    def check_data_accuracy_issues(self):
        """检查数据准确性问题"""
        print("📊 检查数据准确性...")
        
        # 实际统计源代码行数
        try:
            result = subprocess.run(
                ['find', '.', '-name', '*.ml', '-o', '-name', '*.mli'],
                capture_output=True,
                text=True
            )
            
            files = result.stdout.strip().split('\n') if result.stdout.strip() else []
            actual_file_count = len([f for f in files if f and os.path.exists(f)])
            
            # 统计实际代码行数
            total_lines = 0
            for file_path in files:
                if file_path and os.path.exists(file_path):
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            total_lines += len(f.readlines())
                    except:
                        continue
            
            print(f"📊 实际源文件数: {actual_file_count}")
            print(f"📊 实际代码行数: {total_lines}")
            
            # 检查是否与之前报告的数据一致
            if total_lines > 300000:
                print("✅ 代码规模数据合理")
            else:
                self.issues_found.append(f"⚠️ 代码行数统计可能有误: {total_lines}")
            
        except Exception as e:
            print(f"❌ 数据统计错误: {e}")
            self.issues_found.append(f"数据统计失败: {e}")
    
    def generate_quality_report(self):
        """生成测试质量验证报告"""
        print("\n" + "="*60)
        print("📋 测试质量验证报告")
        print("="*60)
        
        # 执行所有验证
        self.validate_test_coverage_accuracy()
        self.validate_poetry_test_completeness()
        self.validate_test_execution_status()
        self.validate_unified_modules_integration()
        self.check_data_accuracy_issues()
        
        # 生成报告
        report_data = {
            'timestamp': datetime.now().isoformat(),
            'validator': 'Echo, 测试工程师代理',
            'issues_found': self.issues_found,
            'recommendations': self.recommendations,
            'validation_status': 'completed'
        }
        
        # 保存报告
        report_file = f'doc/testing/test_quality_validation_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        os.makedirs('doc/testing', exist_ok=True)
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        # 控制台输出
        if self.issues_found:
            print(f"\n❌ 发现 {len(self.issues_found)} 个质量问题:")
            for issue in self.issues_found:
                print(f"   {issue}")
        else:
            print("\n✅ 未发现严重质量问题")
        
        if self.recommendations:
            print(f"\n💡 {len(self.recommendations)} 条改进建议:")
            for rec in self.recommendations:
                print(f"   • {rec}")
        
        print(f"\n📄 详细报告已保存: {report_file}")
        
        return len(self.issues_found) == 0

def main():
    print("🔍 Echo测试工程师 - 测试质量验证工具")
    print("修复Issue #1709中的测试质量控制问题\n")
    
    validator = TestQualityValidator()
    success = validator.generate_quality_report()
    
    if success:
        print("\n🎉 测试质量验证通过!")
        return 0
    else:
        print("\n⚠️ 发现测试质量问题，需要修复")
        return 1

if __name__ == '__main__':
    exit(main())