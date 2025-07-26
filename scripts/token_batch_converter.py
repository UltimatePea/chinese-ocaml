#!/usr/bin/env python3
"""
Token系统批量转换工具

功能:
1. 执行Token引用的自动化转换
2. 生成转换报告和验证脚本
3. 支持分批次转换和回滚
4. 提供转换前后的对比验证

Author: Alpha, 主要工作专员
"""

import os
import re
import json
import shutil
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass, asdict
from collections import defaultdict, Counter
import subprocess
import tempfile

@dataclass
class ConversionRule:
    """转换规则定义"""
    pattern: str
    replacement: str
    rule_type: str  # 'simple', 'regex', 'function'
    condition: Optional[str] = None
    description: str = ""

@dataclass
class ConversionResult:
    """转换结果"""
    file_path: str
    line_number: int
    original_line: str
    converted_line: str
    rule_applied: str
    success: bool
    error_message: str = ""

@dataclass
class BatchConversionSummary:
    """批次转换摘要"""
    batch_id: int
    batch_name: str
    total_files: int
    total_conversions: int
    successful_conversions: int
    failed_conversions: int
    skipped_conversions: int
    execution_time: float

class TokenBatchConverter:
    """Token系统批量转换器"""
    
    def __init__(self, root_path: str, analysis_file: str = "token_conversion_analysis.json"):
        self.root_path = Path(root_path)
        self.analysis_file = analysis_file
        self.conversion_results: List[ConversionResult] = []
        self.backup_dir = self.root_path / "_conversion_backups"
        
        # 确保备份目录存在
        self.backup_dir.mkdir(exist_ok=True)
        
        # 加载分析结果
        self.load_analysis_data()
        
        # 定义转换规则
        self.setup_conversion_rules()
    
    def load_analysis_data(self) -> None:
        """加载分析数据"""
        try:
            with open(self.analysis_file, 'r', encoding='utf-8') as f:
                self.analysis_data = json.load(f)
            print(f"✅ 已加载分析数据: {self.analysis_file}")
        except FileNotFoundError:
            print(f"⚠️ 分析文件不存在: {self.analysis_file}")
            print("请先运行 token_conversion_analyzer.py 生成分析数据")
            self.analysis_data = None
    
    def setup_conversion_rules(self) -> None:
        """设置转换规则"""
        self.conversion_rules = [
            # 简单Token类型转换
            ConversionRule(
                pattern=r'token_(\w+)',
                replacement=r'Token.\1',
                rule_type='regex',
                description="Token类型统一命名"
            ),
            
            # Token模块引用转换
            ConversionRule(
                pattern=r'Token_(\w+)\.(\w+)',
                replacement=r'TokenSystem.\1.\2',
                rule_type='regex',
                description="Token模块层次化重构"
            ),
            
            # 遗留Token函数调用转换
            ConversionRule(
                pattern=r'create_token_(\w+)\s*\(',
                replacement=r'TokenSystem.create_\1(',
                rule_type='regex',
                description="Token创建函数统一"
            ),
            
            # Token兼容性调用转换
            ConversionRule(
                pattern=r'compat_token_(\w+)',
                replacement=r'TokenCompat.\1',
                rule_type='regex',
                description="Token兼容性层统一"
            ),
            
            # Token转换函数调用
            ConversionRule(
                pattern=r'convert_to_token_(\w+)',
                replacement=r'TokenConverter.to_\1',
                rule_type='regex',
                description="Token转换函数统一"
            ),
            
            # Token访问模式转换
            ConversionRule(
                pattern=r'(\w+)\.token_(\w+)',
                replacement=r'\1.token.\2',
                rule_type='regex',
                condition='not_in_type_definition',
                description="Token访问路径统一"
            )
        ]
    
    def create_backup(self, file_path: Path) -> Path:
        """创建文件备份"""
        backup_path = self.backup_dir / f"{file_path.name}.backup"
        shutil.copy2(file_path, backup_path)
        return backup_path
    
    def restore_from_backup(self, file_path: Path) -> bool:
        """从备份恢复文件"""
        backup_path = self.backup_dir / f"{file_path.name}.backup"
        if backup_path.exists():
            shutil.copy2(backup_path, file_path)
            return True
        return False
    
    def apply_conversion_rule(self, line: str, rule: ConversionRule) -> Tuple[str, bool]:
        """应用转换规则"""
        try:
            if rule.rule_type == 'regex':
                # 检查条件
                if rule.condition == 'not_in_type_definition':
                    if re.search(r'type\s+.*=', line.strip()):
                        return line, False
                
                # 应用正则替换
                new_line = re.sub(rule.pattern, rule.replacement, line)
                return new_line, new_line != line
            
            elif rule.rule_type == 'simple':
                # 简单字符串替换
                new_line = line.replace(rule.pattern, rule.replacement)
                return new_line, new_line != line
            
            elif rule.rule_type == 'function':
                # 函数式转换（暂未实现）
                return line, False
            
        except Exception as e:
            print(f"⚠️ 转换规则应用失败: {rule.description} - {e}")
            return line, False
        
        return line, False
    
    def convert_file(self, file_path: Path, batch_id: int = 0) -> List[ConversionResult]:
        """转换单个文件"""
        results = []
        
        try:
            # 创建备份
            backup_path = self.create_backup(file_path)
            
            # 读取文件内容
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # 应用转换规则
            converted_lines = []
            file_changed = False
            
            for line_num, line in enumerate(lines, 1):
                original_line = line
                current_line = line
                rules_applied = []
                
                # 应用每个转换规则
                for rule in self.conversion_rules:
                    new_line, changed = self.apply_conversion_rule(current_line, rule)
                    if changed:
                        rules_applied.append(rule.description)
                        current_line = new_line
                        file_changed = True
                        
                        # 记录转换结果
                        result = ConversionResult(
                            file_path=str(file_path.relative_to(self.root_path)),
                            line_number=line_num,
                            original_line=original_line.strip(),
                            converted_line=current_line.strip(),
                            rule_applied=rule.description,
                            success=True
                        )
                        results.append(result)
                
                converted_lines.append(current_line)
            
            # 如果有变更，写入文件
            if file_changed:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(converted_lines)
                
                print(f"✅ 已转换: {file_path.relative_to(self.root_path)} "
                      f"({len([r for r in results if r.success])} 处修改)")
            
        except Exception as e:
            error_result = ConversionResult(
                file_path=str(file_path.relative_to(self.root_path)),
                line_number=0,
                original_line="",
                converted_line="",
                rule_applied="file_conversion",
                success=False,
                error_message=str(e)
            )
            results.append(error_result)
            print(f"❌ 转换失败: {file_path.relative_to(self.root_path)} - {e}")
        
        return results
    
    def convert_batch(self, batch_id: int) -> BatchConversionSummary:
        """转换指定批次"""
        if not self.analysis_data:
            print("❌ 无分析数据，无法执行批次转换")
            return None
        
        import time
        start_time = time.time()
        
        # 找到对应批次
        batch_info = None
        for batch in self.analysis_data['conversion_batches']:
            if batch['batch_id'] == batch_id:
                batch_info = batch
                break
        
        if not batch_info:
            print(f"❌ 未找到批次 {batch_id}")
            return None
        
        print(f"🚀 开始转换批次 {batch_id}: {batch_info['batch_name']}")
        print(f"📁 涉及文件: {len(batch_info['files'])} 个")
        
        batch_results = []
        successful_files = 0
        failed_files = 0
        
        for file_path_str in batch_info['files']:
            file_path = self.root_path / file_path_str
            
            if not file_path.exists():
                print(f"⚠️ 文件不存在: {file_path_str}")
                continue
            
            # 转换文件
            file_results = self.convert_file(file_path, batch_id)
            batch_results.extend(file_results)
            
            # 统计结果
            if any(r.success for r in file_results):
                successful_files += 1
            elif any(not r.success for r in file_results):
                failed_files += 1
        
        execution_time = time.time() - start_time
        
        # 计算汇总统计
        total_conversions = len(batch_results)
        successful_conversions = len([r for r in batch_results if r.success])
        failed_conversions = len([r for r in batch_results if not r.success])
        
        summary = BatchConversionSummary(
            batch_id=batch_id,
            batch_name=batch_info['batch_name'],
            total_files=len(batch_info['files']),
            total_conversions=total_conversions,
            successful_conversions=successful_conversions,
            failed_conversions=failed_conversions,
            skipped_conversions=0,
            execution_time=execution_time
        )
        
        # 保存批次结果
        self.conversion_results.extend(batch_results)
        
        print(f"✅ 批次 {batch_id} 转换完成:")
        print(f"   成功转换: {successful_conversions}")
        print(f"   转换失败: {failed_conversions}")
        print(f"   执行时间: {execution_time:.2f}秒")
        
        return summary
    
    def validate_conversion(self, batch_id: Optional[int] = None) -> bool:
        """验证转换结果"""
        print("🔍 开始验证转换结果...")
        
        # 运行基本编译检查
        try:
            result = subprocess.run(
                ['dune', 'build', '--display', 'quiet'],
                cwd=self.root_path,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode == 0:
                print("✅ 编译检查通过")
                return True
            else:
                print("❌ 编译检查失败:")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print("⚠️ 编译检查超时")
            return False
        except Exception as e:
            print(f"❌ 编译检查异常: {e}")
            return False
    
    def run_tests(self) -> bool:
        """运行测试验证"""
        print("🧪 开始运行测试...")
        
        try:
            result = subprocess.run(
                ['dune', 'runtest', '--display', 'quiet'],
                cwd=self.root_path,
                capture_output=True,
                text=True,
                timeout=600
            )
            
            if result.returncode == 0:
                print("✅ 测试验证通过")
                return True
            else:
                print("❌ 测试验证失败:")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print("⚠️ 测试验证超时")
            return False
        except Exception as e:
            print(f"❌ 测试验证异常: {e}")
            return False
    
    def generate_conversion_report(self, output_path: str) -> None:
        """生成转换报告"""
        report = {
            'conversion_summary': {
                'total_conversions': len(self.conversion_results),
                'successful_conversions': len([r for r in self.conversion_results if r.success]),
                'failed_conversions': len([r for r in self.conversion_results if not r.success]),
                'affected_files': len(set(r.file_path for r in self.conversion_results))
            },
            'conversion_details': [asdict(r) for r in self.conversion_results],
            'rule_usage': self._analyze_rule_usage(),
            'recommendations': self._generate_post_conversion_recommendations()
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print(f"📊 转换报告已保存到: {output_path}")
    
    def _analyze_rule_usage(self) -> Dict[str, int]:
        """分析规则使用情况"""
        rule_usage = Counter(r.rule_applied for r in self.conversion_results if r.success)
        return dict(rule_usage)
    
    def _generate_post_conversion_recommendations(self) -> List[str]:
        """生成转换后建议"""
        recommendations = []
        
        failed_count = len([r for r in self.conversion_results if not r.success])
        if failed_count > 0:
            recommendations.append(f"有 {failed_count} 个转换失败，需要手工检查和修复")
        
        recommendations.extend([
            "运行完整的回归测试套件",
            "检查编译警告和错误",
            "验证Token系统的功能正确性",
            "更新相关文档和注释"
        ])
        
        return recommendations
    
    def rollback_batch(self, batch_id: int) -> bool:
        """回滚批次转换"""
        print(f"🔄 开始回滚批次 {batch_id}...")
        
        if not self.analysis_data:
            print("❌ 无分析数据，无法执行回滚")
            return False
        
        # 找到批次文件
        batch_info = None
        for batch in self.analysis_data['conversion_batches']:
            if batch['batch_id'] == batch_id:
                batch_info = batch
                break
        
        if not batch_info:
            print(f"❌ 未找到批次 {batch_id}")
            return False
        
        rollback_success = True
        
        for file_path_str in batch_info['files']:
            file_path = self.root_path / file_path_str
            
            if not self.restore_from_backup(file_path):
                print(f"⚠️ 无法回滚文件: {file_path_str}")
                rollback_success = False
        
        if rollback_success:
            print(f"✅ 批次 {batch_id} 回滚成功")
        else:
            print(f"⚠️ 批次 {batch_id} 回滚部分失败")
        
        return rollback_success

def main():
    parser = argparse.ArgumentParser(description='Token系统批量转换工具')
    parser.add_argument('--root', default='.', help='项目根目录路径')
    parser.add_argument('--analysis-file', default='token_conversion_analysis.json',
                      help='分析文件路径')
    parser.add_argument('--batch', type=int, help='要转换的批次ID')
    parser.add_argument('--validate', action='store_true', help='验证转换结果')
    parser.add_argument('--test', action='store_true', help='运行测试验证')
    parser.add_argument('--report', default='conversion_report.json', 
                      help='转换报告输出路径')
    parser.add_argument('--rollback', type=int, help='回滚指定批次')
    
    args = parser.parse_args()
    
    # 创建转换器
    converter = TokenBatchConverter(args.root, args.analysis_file)
    
    if args.rollback:
        # 回滚指定批次
        converter.rollback_batch(args.rollback)
        return
    
    if args.batch:
        # 转换指定批次
        summary = converter.convert_batch(args.batch)
        if summary:
            print(f"\n📊 批次转换摘要:")
            print(f"   批次: {summary.batch_name}")
            print(f"   文件数: {summary.total_files}")
            print(f"   成功转换: {summary.successful_conversions}")
            print(f"   失败转换: {summary.failed_conversions}")
    
    if args.validate:
        # 验证转换结果
        validation_success = converter.validate_conversion()
        if not validation_success:
            print("⚠️ 验证失败，建议检查转换结果")
    
    if args.test:
        # 运行测试
        test_success = converter.run_tests()
        if not test_success:
            print("⚠️ 测试失败，建议检查转换结果")
    
    # 生成转换报告
    if converter.conversion_results:
        converter.generate_conversion_report(args.report)

if __name__ == '__main__':
    main()