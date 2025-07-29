#!/usr/bin/env python3
"""
骆言编译器测试质量分析工具
Author: Alpha, 主工作代理
Date: 2025-07-29
Crisis Response: Issue #1697

用于分析测试文件质量，识别低质量测试并生成质量报告
"""

import os
import re
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Tuple

@dataclass
class TestQualityMetrics:
    """测试质量指标"""
    file_path: str
    total_tests: int
    quality_score: float
    business_value_score: float
    has_boundary_tests: bool
    has_error_handling: bool
    test_patterns: List[str]
    issues: List[str]

class TestQualityAnalyzer:
    """测试质量分析器"""
    
    def __init__(self):
        self.low_quality_patterns = [
            # 简单字符串拼接验证
            r'check\s+string\s+"[^"]*"\s+"[^"]*"\s+\([^)]*format[^)]*\)',
            
            # 简单常量比较
            r'check\s+int\s+"[^"]*"\s+\d+\s+\(List\.length\s+\[',
            
            # 枚举类型数量验证
            r'check\s+int\s+"[^"]*类型数量"\s+\d+\s+\(',
            
            # 简单的字符串拼接
            r'check\s+string\s+"[^"]*"\s+"[^"]*"\s+\([^)]*\s*\^\s*[^)]*\)',
        ]
        
        self.quality_indicators = {
            'business_logic': [
                r'Parser\.parse',
                r'Lexer\.tokenize',
                r'analyze_rhyme',
                r'analyze_tone',
                r'compile',
                r'evaluate',
                r'interpret'
            ],
            'boundary_conditions': [
                r'empty',
                r'null',
                r'边界',
                r'最大',
                r'最小',
                r'异常',
                r'错误',
                r'malformed'
            ],
            'error_handling': [
                r'try.*with',
                r'exception',
                r'error',
                r'fail',
                r'check.*error',
                r'expect.*exception'
            ]
        }

    def analyze_test_file(self, file_path: str) -> TestQualityMetrics:
        """分析单个测试文件的质量"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            return TestQualityMetrics(
                file_path=file_path,
                total_tests=0,
                quality_score=0.0,
                business_value_score=0.0,
                has_boundary_tests=False,
                has_error_handling=False,
                test_patterns=[],
                issues=[f"读取文件失败: {e}"]
            )

        # 统计测试函数数量
        test_functions = re.findall(r'let\s+test_\w+\s*\(\)', content)
        total_tests = len(test_functions)
        
        if total_tests == 0:
            return TestQualityMetrics(
                file_path=file_path,
                total_tests=0,
                quality_score=0.0,
                business_value_score=0.0,
                has_boundary_tests=False,
                has_error_handling=False,
                test_patterns=[],
                issues=["未找到测试函数"]
            )

        # 检查低质量模式
        low_quality_count = 0
        detected_patterns = []
        
        for pattern in self.low_quality_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                low_quality_count += len(matches)
                detected_patterns.extend(matches)

        # 检查质量指标
        has_business_logic = any(
            re.search(pattern, content, re.IGNORECASE) 
            for pattern in self.quality_indicators['business_logic']
        )
        
        has_boundary_tests = any(
            re.search(pattern, content, re.IGNORECASE)
            for pattern in self.quality_indicators['boundary_conditions']
        )
        
        has_error_handling = any(
            re.search(pattern, content, re.IGNORECASE)
            for pattern in self.quality_indicators['error_handling']
        )

        # 计算质量分数 (1-10分)
        quality_score = self._calculate_quality_score(
            total_tests, low_quality_count, has_business_logic, 
            has_boundary_tests, has_error_handling
        )
        
        # 计算业务价值分数
        business_value_score = self._calculate_business_value_score(
            content, has_business_logic, total_tests
        )

        # 识别问题
        issues = []
        if low_quality_count > total_tests * 0.5:
            issues.append(f"包含{low_quality_count}个低质量测试模式")
        if not has_business_logic:
            issues.append("缺乏业务逻辑验证")
        if not has_boundary_tests:
            issues.append("缺乏边界条件测试") 
        if not has_error_handling:
            issues.append("缺乏错误处理测试")

        return TestQualityMetrics(
            file_path=file_path,
            total_tests=total_tests,
            quality_score=quality_score,
            business_value_score=business_value_score,
            has_boundary_tests=has_boundary_tests,
            has_error_handling=has_error_handling,
            test_patterns=detected_patterns[:5],  # 最多显示5个
            issues=issues
        )

    def _calculate_quality_score(self, total_tests: int, low_quality_count: int, 
                               has_business_logic: bool, has_boundary_tests: bool,
                               has_error_handling: bool) -> float:
        """计算质量分数 (1-10分)"""
        base_score = 5.0
        
        # 低质量测试扣分
        if total_tests > 0:
            low_quality_ratio = low_quality_count / total_tests
            base_score -= low_quality_ratio * 4.0
        
        # 质量指标加分
        if has_business_logic:
            base_score += 2.0
        if has_boundary_tests:
            base_score += 1.5
        if has_error_handling:
            base_score += 1.5
            
        return max(1.0, min(10.0, base_score))

    def _calculate_business_value_score(self, content: str, has_business_logic: bool, 
                                      total_tests: int) -> float:
        """计算业务价值分数 (1-10分)"""
        if not has_business_logic:
            return 1.0
        
        # 检查字符串拼接测试的比例
        string_concat_tests = re.findall(r'check\s+string.*format', content, re.IGNORECASE)
        if total_tests > 0:
            string_ratio = len(string_concat_tests) / total_tests
            if string_ratio > 0.8:
                return 2.0
            elif string_ratio > 0.5:
                return 4.0
            elif string_ratio > 0.3:
                return 6.0
            else:
                return 8.0
        
        return 5.0

    def analyze_directory(self, directory: str) -> List[TestQualityMetrics]:
        """分析目录中的所有测试文件"""
        results = []
        test_files = []
        
        # 查找所有测试文件
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.startswith('test_') and file.endswith('.ml'):
                    test_files.append(os.path.join(root, file))
        
        print(f"发现 {len(test_files)} 个测试文件")
        
        for file_path in test_files:
            print(f"分析: {file_path}")
            result = self.analyze_test_file(file_path)
            results.append(result)
        
        return results

    def generate_report(self, results: List[TestQualityMetrics]) -> str:
        """生成质量报告"""
        if not results:
            return "未找到测试文件"
        
        # 统计数据
        total_files = len(results)
        total_tests = sum(r.total_tests for r in results)
        avg_quality = sum(r.quality_score for r in results) / total_files
        avg_business_value = sum(r.business_value_score for r in results) / total_files
        
        # 按质量分数分类
        excellent = [r for r in results if r.quality_score >= 8]
        good = [r for r in results if 6 <= r.quality_score < 8]
        poor = [r for r in results if r.quality_score < 6]
        
        report = f"""
# 🔍 骆言编译器测试质量分析报告

Author: Alpha, 主工作代理
Date: 2025-07-29
Crisis Response: Issue #1697

## 📊 总体统计

- **测试文件总数**: {total_files}
- **测试函数总数**: {total_tests}
- **平均质量分数**: {avg_quality:.2f}/10.0
- **平均业务价值分数**: {avg_business_value:.2f}/10.0

## 📈 质量分布

### 🏆 优秀级测试 (8-10分): {len(excellent)}个文件
{self._format_file_list(excellent)}

### 🎖️ 良好级测试 (6-8分): {len(good)}个文件  
{self._format_file_list(good)}

### ❌ 低质量测试 (<6分): {len(poor)}个文件
{self._format_file_list(poor)}

## 🚨 主要问题总结

### 最严重的质量问题
"""
        
        # 列出最差的5个文件
        worst_files = sorted(results, key=lambda x: x.quality_score)[:5]
        for i, result in enumerate(worst_files, 1):
            report += f"\n{i}. **{os.path.basename(result.file_path)}** (质量分数: {result.quality_score:.1f})\n"
            for issue in result.issues[:3]:
                report += f"   - {issue}\n"
        
        # 质量改进建议
        report += f"""

## 💡 改进建议

### 立即行动 (紧急)
- 删除 {len([r for r in results if r.quality_score < 3])} 个无价值测试文件
- 重写 {len([r for r in results if 3 <= r.quality_score < 5])} 个低质量测试文件
- 暂停所有质量分数<5分的测试PR合并

### 中期改进 (2周内)
- 将 {len([r for r in results if 5 <= r.quality_score < 7])} 个中等质量测试提升至≥7分
- 统一测试目录结构，减少混乱
- 建立质量检查自动化工具

### 长期目标 (1个月内)
- 所有测试达到≥7分质量标准
- 建立可持续的质量文化
- 实现真正有价值的测试覆盖

## 🎯 质量复兴路线图

基于此次分析，项目确实面临严重的测试质量危机。但通过系统性改进，我们完全可以建立业界标杆级的测试质量标准。

**关键是从"覆盖率数字游戏"转向"真实业务价值验证"。**
"""

        return report

    def _format_file_list(self, results: List[TestQualityMetrics]) -> str:
        """格式化文件列表"""
        if not results:
            return "（无）"
        
        lines = []
        for result in sorted(results, key=lambda x: x.quality_score, reverse=True)[:10]:
            lines.append(f"- {os.path.basename(result.file_path)} (质量: {result.quality_score:.1f}分)")
        
        if len(results) > 10:
            lines.append(f"... 还有 {len(results) - 10} 个文件")
        
        return "\n".join(lines)

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("用法: python test_quality_analyzer.py <测试目录路径>")
        sys.exit(1)
    
    test_directory = sys.argv[1]
    
    if not os.path.exists(test_directory):
        print(f"错误: 目录 {test_directory} 不存在")
        sys.exit(1)
    
    print(f"🔍 开始分析测试目录: {test_directory}")
    print("=" * 60)
    
    analyzer = TestQualityAnalyzer()
    results = analyzer.analyze_directory(test_directory)
    
    print("=" * 60)
    print("📊 生成质量报告...")
    
    report = analyzer.generate_report(results)
    
    # 保存报告到文件
    report_file = "test_quality_analysis_report.md"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"✅ 报告已保存到: {report_file}")
    print("\n" + "=" * 60)
    print("📋 报告预览:")
    print(report[:2000] + "..." if len(report) > 2000 else report)

if __name__ == "__main__":
    main()