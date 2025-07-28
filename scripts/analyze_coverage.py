#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试覆盖率分析工具

Author: Echo, 测试工程师代理
Date: 2025-07-28
Issue: #1600 - 测试覆盖率技术债务分析与改进计划
"""

import os
import sys
import subprocess
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from datetime import datetime
import html.parser


class CoverageAnalyzer:
    """测试覆盖率分析器"""
    
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.coverage_dir = self.project_root / "_coverage"
        self.reports_dir = self.project_root / "coverage_reports"
        
    def run_coverage_measurement(self) -> bool:
        """运行标准化覆盖率测量"""
        print("🧪 开始运行测试覆盖率测量...")
        
        try:
            # 清理旧的覆盖率文件
            self._cleanup_old_coverage()
            
            # 运行测试并生成覆盖率数据
            print("   ⏳ 运行测试...")
            result = subprocess.run(
                ["dune", "test", "--instrument-with", "bisect_ppx"],
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"   ❌ 测试运行失败: {result.stderr}")
                return False
                
            # 生成HTML报告
            print("   📊 生成覆盖率报告...")
            result = subprocess.run(
                ["bisect-ppx-report", "html", "--ignore-missing-files"],
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"   ❌ 覆盖率报告生成失败: {result.stderr}")
                return False
                
            print("   ✅ 覆盖率测量完成")
            return True
            
        except Exception as e:
            print(f"   ❌ 覆盖率测量过程出错: {e}")
            return False
    
    def _cleanup_old_coverage(self):
        """清理旧的覆盖率文件"""
        # 清理bisect覆盖率文件
        for coverage_file in self.project_root.glob("bisect*.coverage"):
            coverage_file.unlink()
            
        # 清理_coverage目录
        if self.coverage_dir.exists():
            import shutil
            shutil.rmtree(self.coverage_dir)
    
    def parse_coverage_report(self) -> Optional[Dict]:
        """解析覆盖率报告"""
        index_file = self.coverage_dir / "index.html"
        
        if not index_file.exists():
            print(f"❌ 覆盖率报告文件不存在: {index_file}")
            return None
            
        try:
            with open(index_file, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # 解析总体覆盖率
            overall_match = re.search(r'<h2>([0-9.]+)%</h2>', content)
            if not overall_match:
                print("❌ 无法解析总体覆盖率")
                return None
                
            overall_coverage = float(overall_match.group(1))
            
            # 解析文件级覆盖率
            file_coverages = []
            file_pattern = r'<span class="percentage">([0-9]+)% <span class="stats">\(([0-9]+) / ([0-9]+)\)</span></span>\s*<a href="[^"]+"><span class="dirname">([^<]*)</span>([^<]+)</a>'
            
            for match in re.finditer(file_pattern, content):
                percentage = int(match.group(1))
                covered = int(match.group(2))
                total = int(match.group(3))
                dirname = match.group(4)
                filename = match.group(5)
                
                file_coverages.append({
                    'file': f"{dirname}{filename}",
                    'percentage': percentage,
                    'covered': covered,
                    'total': total
                })
            
            return {
                'overall_coverage': overall_coverage,
                'timestamp': datetime.now().isoformat(),
                'files': file_coverages,
                'total_files': len(file_coverages)
            }
            
        except Exception as e:
            print(f"❌ 解析覆盖率报告出错: {e}")
            return None
    
    def analyze_coverage_trends(self, current_data: Dict) -> Dict:
        """分析覆盖率趋势"""
        analysis = {
            'current_coverage': current_data['overall_coverage'],
            'file_count': current_data['total_files'],
            'low_coverage_files': [],
            'high_coverage_files': [],
            'recommendations': []
        }
        
        # 分析文件级覆盖率
        for file_info in current_data['files']:
            if file_info['percentage'] < 30:
                analysis['low_coverage_files'].append(file_info)
            elif file_info['percentage'] > 80:
                analysis['high_coverage_files'].append(file_info)
        
        # 排序
        analysis['low_coverage_files'].sort(key=lambda x: x['percentage'])
        analysis['high_coverage_files'].sort(key=lambda x: x['percentage'], reverse=True)
        
        # 生成建议
        if analysis['current_coverage'] < 30:
            analysis['recommendations'].append("🚨 整体覆盖率较低，建议优先改进核心模块测试")
        elif analysis['current_coverage'] < 50:
            analysis['recommendations'].append("⚠️ 覆盖率中等，建议重点改进低覆盖率文件")
        else:
            analysis['recommendations'].append("✅ 覆盖率良好，建议保持并优化测试质量")
            
        if len(analysis['low_coverage_files']) > 10:
            analysis['recommendations'].append("📋 发现多个低覆盖率文件，建议制定分阶段改进计划")
            
        return analysis
    
    def generate_report(self, data: Dict, analysis: Dict) -> str:
        """生成分析报告"""
        report = f"""# 测试覆盖率分析报告

**生成时间**: {data['timestamp']}  
**工具**: Echo代理覆盖率分析器  
**Issue**: #1600

## 📊 覆盖率概览

- **总体覆盖率**: {data['overall_coverage']:.2f}%
- **分析文件数**: {data['total_files']} 个
- **低覆盖率文件**: {len(analysis['low_coverage_files'])} 个 (<30%)
- **高覆盖率文件**: {len(analysis['high_coverage_files'])} 个 (>80%)

## 🎯 改进建议

"""
        
        for i, rec in enumerate(analysis['recommendations'], 1):
            report += f"{i}. {rec}\n"
            
        report += "\n## 📋 低覆盖率文件 (需要改进)\n\n"
        
        if analysis['low_coverage_files']:
            report += "| 文件 | 覆盖率 | 已覆盖 | 总行数 |\n"
            report += "|------|--------|--------|--------|\n"
            
            for file_info in analysis['low_coverage_files'][:10]:  # 只显示前10个
                report += f"| {file_info['file']} | {file_info['percentage']}% | {file_info['covered']} | {file_info['total']} |\n"
                
            if len(analysis['low_coverage_files']) > 10:
                report += f"\n... 还有 {len(analysis['low_coverage_files']) - 10} 个文件需要改进\n"
        else:
            report += "✅ 没有发现低覆盖率文件\n"
            
        report += "\n## 🏆 高覆盖率文件 (保持现状)\n\n"
        
        if analysis['high_coverage_files']:
            report += "| 文件 | 覆盖率 | 已覆盖 | 总行数 |\n"
            report += "|------|--------|--------|--------|\n"
            
            for file_info in analysis['high_coverage_files'][:5]:  # 只显示前5个
                report += f"| {file_info['file']} | {file_info['percentage']}% | {file_info['covered']} | {file_info['total']} |\n"
        else:
            report += "⚠️ 暂无高覆盖率文件\n"
            
        report += f"""
## 🔧 下一步行动

### 立即改进 (本周)
1. 重点关注覆盖率最低的3-5个核心文件
2. 为这些文件添加基础测试用例
3. 验证测试有效性

### 中期改进 (本月)
1. 将低覆盖率文件数量减少50%
2. 整体覆盖率提升至35%+
3. 建立CI覆盖率监控

---

**Author: Echo, 测试工程师代理**  
🤖 Generated with [Claude Code](https://claude.ai/code)
"""
        
        return report
    
    def save_results(self, data: Dict, analysis: Dict, report: str):
        """保存分析结果"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 确保报告目录存在
        self.reports_dir.mkdir(exist_ok=True)
        
        # 保存JSON数据
        json_file = self.reports_dir / f"coverage_analysis_{timestamp}.json"
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump({
                'data': data,
                'analysis': analysis
            }, f, indent=2, ensure_ascii=False)
            
        # 保存Markdown报告
        md_file = self.reports_dir / f"coverage_analysis_{timestamp}.md"
        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(report)
            
        print(f"📊 分析结果已保存:")
        print(f"   JSON: {json_file}")
        print(f"   报告: {md_file}")
        
        return md_file, json_file


def main():
    """主函数"""
    print("📊 Echo代理测试覆盖率分析工具")
    print("=" * 50)
    
    analyzer = CoverageAnalyzer()
    
    # 运行覆盖率测量
    if not analyzer.run_coverage_measurement():
        print("❌ 覆盖率测量失败，退出")
        sys.exit(1)
    
    # 解析覆盖率报告
    data = analyzer.parse_coverage_report()
    if not data:
        print("❌ 解析覆盖率报告失败，退出")
        sys.exit(1)
    
    # 分析覆盖率趋势
    analysis = analyzer.analyze_coverage_trends(data)
    
    # 生成报告
    report = analyzer.generate_report(data, analysis)
    
    # 保存结果
    md_file, json_file = analyzer.save_results(data, analysis, report)
    
    # 输出概要
    print("\n📊 分析概要:")
    print(f"   总体覆盖率: {data['overall_coverage']:.2f}%")
    print(f"   分析文件数: {data['total_files']}")
    print(f"   低覆盖率文件: {len(analysis['low_coverage_files'])}")
    print(f"   高覆盖率文件: {len(analysis['high_coverage_files'])}")
    print(f"\n📋 详细报告: {md_file}")
    
    print("\n✅ 覆盖率分析完成!")


if __name__ == "__main__":
    main()