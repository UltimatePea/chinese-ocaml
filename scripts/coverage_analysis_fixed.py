#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
骆言编译器测试覆盖率分析修复脚本

Author: Alpha, 主要工作代理
修复了覆盖率分析差异问题，确保准确的测试覆盖率报告

本脚本确保了：
1. 覆盖率分析的一致性和准确性
2. 基线数据与实际测量的一致性
3. 标准化的覆盖率测量流程
"""

import subprocess
import os
import json
import sys
from datetime import datetime

def clean_coverage_data():
    """清理旧的覆盖率数据"""
    print("🧹 清理旧的覆盖率数据...")
    
    # 清理bisect文件
    subprocess.run(["find", ".", "-name", "bisect*.coverage", "-delete"], 
                   capture_output=True)
    
    # 清理构建目录
    subprocess.run(["dune", "clean"], capture_output=True)
    
    print("✅ 覆盖率数据清理完成")

def run_comprehensive_tests():
    """运行完整的测试套件以获得准确的覆盖率"""
    print("🚀 运行完整测试套件...")
    
    # 设置环境变量并运行测试
    env = os.environ.copy()
    env["BISECT_ENABLE"] = "yes"
    
    result = subprocess.run([
        "dune", "runtest", "--instrument-with", "bisect_ppx"
    ], env=env, capture_output=True, text=True, encoding='utf-8', errors='replace')
    
    if result.returncode != 0:
        print(f"❌ 测试运行失败: {result.stderr}")
        return False
    
    print("✅ 完整测试套件运行完成")
    return True

def get_coverage_data():
    """获取覆盖率数据"""
    print("📊 获取覆盖率数据...")
    
    result = subprocess.run([
        "bisect-ppx-report", "summary"
    ], capture_output=True, text=True, encoding='utf-8', errors='replace')
    
    if result.returncode != 0:
        print(f"❌ 覆盖率报告生成失败: {result.stderr}")
        return None
    
    # 解析覆盖率数据
    output = result.stdout.strip()
    print(f"📈 覆盖率输出: {output}")
    
    # 提取覆盖率信息 (格式: Coverage: 24132/33902 (71.18%))
    if "Coverage:" in output:
        parts = output.split("Coverage: ")[1]
        coverage_part = parts.split(" ")[0]  # 24132/33902
        percentage_part = parts.split("(")[1].split(")")[0]  # 71.18%
        
        covered, total = coverage_part.split("/")
        return {
            "covered_lines": int(covered),
            "total_lines": int(total),
            "percentage": float(percentage_part.replace("%", "")),
            "raw_output": output
        }
    
    return None

def generate_html_report():
    """生成HTML覆盖率报告"""
    print("📄 生成HTML覆盖率报告...")
    
    # 确保目录存在
    os.makedirs("coverage_reports/html", exist_ok=True)
    
    result = subprocess.run([
        "bisect-ppx-report", "html", "-o", "coverage_reports/html"
    ], capture_output=True, text=True, encoding='utf-8', errors='replace')
    
    if result.returncode != 0:
        print(f"⚠️ HTML报告生成警告: {result.stderr}")
    else:
        print("✅ HTML覆盖率报告生成完成")

def save_coverage_analysis(coverage_data):
    """保存覆盖率分析结果"""
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    
    analysis = {
        "timestamp": timestamp,
        "coverage_data": coverage_data,
        "baseline_comparison": {
            "baseline_percentage": 71.18,
            "current_percentage": coverage_data["percentage"],
            "difference": coverage_data["percentage"] - 71.18,
        },
        "analysis": {
            "status": "verified" if abs(coverage_data["percentage"] - 71.18) < 0.1 else "needs_investigation",
            "notes": "Coverage analysis fixed - consistent with baseline" if abs(coverage_data["percentage"] - 71.18) < 0.1 else "Coverage differs from baseline"
        }
    }
    
    # 保存JSON数据
    os.makedirs("coverage_reports/data", exist_ok=True)
    with open(f"coverage_reports/data/coverage_analysis_{timestamp}.json", "w", encoding="utf-8") as f:
        json.dump(analysis, f, indent=2, ensure_ascii=False)
    
    # 更新最新数据
    with open("coverage_reports/data/latest_coverage.txt", "w", encoding="utf-8") as f:
        f.write(f"{coverage_data['percentage']:.2f}%\n")
        f.write(f"{coverage_data['covered_lines']}/{coverage_data['total_lines']}\n")
    
    print(f"💾 覆盖率分析数据已保存: coverage_analysis_{timestamp}.json")
    return analysis

def main():
    """主函数"""
    print("🔍 骆言编译器测试覆盖率分析修复")
    print("=====================================")
    
    # 步骤1：清理旧数据
    clean_coverage_data()
    
    # 步骤2：运行完整测试
    if not run_comprehensive_tests():
        sys.exit(1)
    
    # 步骤3：获取覆盖率数据
    coverage_data = get_coverage_data()
    if not coverage_data:
        print("❌ 无法获取覆盖率数据")
        sys.exit(1)
    
    # 步骤4：生成HTML报告
    generate_html_report()
    
    # 步骤5：保存分析结果
    analysis = save_coverage_analysis(coverage_data)
    
    # 步骤6：输出结果
    print("\n📊 覆盖率分析结果")
    print("==================")
    print(f"✅ 当前覆盖率: {coverage_data['percentage']:.2f}%")
    print(f"✅ 覆盖行数: {coverage_data['covered_lines']:,}")
    print(f"✅ 总行数: {coverage_data['total_lines']:,}")
    print(f"✅ 与基线差异: {analysis['baseline_comparison']['difference']:+.2f}%")
    print(f"✅ 状态: {analysis['analysis']['status']}")
    print(f"✅ 备注: {analysis['analysis']['notes']}")
    
    if analysis['analysis']['status'] == 'verified':
        print("\n🎉 覆盖率分析修复成功！")
        print("✅ 覆盖率数据与基线一致")
        print("✅ 测试覆盖率分析差异问题已解决")
    else:
        print("\n⚠️ 覆盖率数据与基线存在差异，需要进一步调查")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())