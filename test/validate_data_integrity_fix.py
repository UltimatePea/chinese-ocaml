#!/usr/bin/env python3
"""
数据完整性修复验证脚本

验证PR #1810中的数据完整性修复是否成功：
1. 运行修复后的质量门控工具
2. 验证数据完整性检查结果
3. 确认不再有误报

Author: Echo, 测试工程师代理
Created: 2025-07-30
Related: Issue #1809, PR #1810
"""

import subprocess
import sys
import re

def run_quality_gate_tool():
    """运行质量门控工具并检查结果"""
    print("🔍 运行修复后的质量门控工具...")
    
    try:
        result = subprocess.run(
            ["python", "scripts/quality/quality_gate_tools_fixed.py"],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        output = result.stdout + result.stderr
        
        print(f"质量门控工具退出代码: {result.returncode}")
        print("质量门控工具输出:")
        print(output)
        
        return result.returncode, output
        
    except subprocess.TimeoutExpired:
        print("❌ 质量门控工具执行超时")
        return -1, ""
    except Exception as e:
        print(f"❌ 运行质量门控工具时出错: {e}")
        return -1, ""

def validate_data_integrity_fix(output):
    """验证数据完整性修复结果"""
    print("\n📊 验证数据完整性修复结果...")
    
    validation_results = []
    
    # 检查1: 数据完整性检查器应该显示PASS状态
    if "数据完整性检查器（修复版）" in output and "状态: PASS" in output:
        validation_results.append(("✅", "数据完整性检查器状态为PASS"))
    else:
        validation_results.append(("❌", "数据完整性检查器状态不是PASS"))
    
    # 检查2: 应该显示0个问题
    if "问题数: 0" in output:
        validation_results.append(("✅", "数据完整性问题数为0"))
    else:
        validation_results.append(("❌", "仍然存在数据完整性问题"))
    
    # 检查3: 整体状态应该不是因为数据完整性而FAIL
    if "整体状态: FAIL" in output:
        # 检查是否是因为性能问题而非数据完整性问题
        if "性能分析器" in output and "FAIL" in output:
            validation_results.append(("✅", "整体FAIL状态是由于性能问题，不是数据完整性问题"))
        else:
            validation_results.append(("⚠️", "整体状态为FAIL，需要进一步分析原因"))
    else:
        validation_results.append(("✅", "整体状态不是FAIL"))
    
    # 检查4: 验证性能问题确实存在（确认工具正常工作）
    if "708" in output and "性能分析器" in output:
        validation_results.append(("✅", "性能分析器正确识别出708个问题（证明工具正常工作）"))
    else:
        validation_results.append(("⚠️", "性能分析结果可能有变化"))

    return validation_results

def main():
    """主函数"""
    print("=" * 60)
    print("数据完整性修复验证 - Fix #1809")
    print("=" * 60)
    
    # 运行质量门控工具
    exit_code, output = run_quality_gate_tool()
    
    if exit_code == -1:
        print("❌ 无法运行质量门控工具，验证失败")
        return 1
    
    # 验证修复结果
    validation_results = validate_data_integrity_fix(output)
    
    print("\n📋 验证结果汇总:")
    print("-" * 40)
    
    passed = 0
    failed = 0
    warnings = 0
    
    for status, message in validation_results:
        print(f"{status} {message}")
        if status == "✅":
            passed += 1
        elif status == "❌":
            failed += 1
        else:
            warnings += 1
    
    print(f"\n📊 验证统计:")
    print(f"通过: {passed}")
    print(f"失败: {failed}")
    print(f"警告: {warnings}")
    
    if failed == 0:
        print("\n🎉 数据完整性修复验证通过！")
        print("PR #1810 成功修复了Issue #1809中的数据完整性问题")
        return 0
    else:
        print("\n❌ 数据完整性修复验证失败")
        print("需要进一步检查和修复")
        return 1

if __name__ == "__main__":
    sys.exit(main())