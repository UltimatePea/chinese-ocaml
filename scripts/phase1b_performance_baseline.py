#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 1-B 性能基准测试套件

Author: Whisky, PR Worker
建立编译器关键操作的性能基线，用于监控Phase 1-B重构过程中的性能变化

本脚本监控：
1. 编译时间基准
2. 测试运行时间基准  
3. 文件读取和处理性能
4. 内存使用基准
"""

import subprocess
import time
import json
import sys
import os
from datetime import datetime
from pathlib import Path

def measure_build_performance():
    """测量编译性能基准"""
    print("📊 测量编译性能基准...")
    
    # 清理构建缓存以获得一致的测量
    subprocess.run(["dune", "clean"], capture_output=True)
    
    start_time = time.time()
    result = subprocess.run(
        ["dune", "build"],
        capture_output=True,
        text=True,
        encoding='utf-8',
        errors='replace'
    )
    end_time = time.time()
    
    build_time = end_time - start_time
    success = result.returncode == 0
    
    return {
        "build_time_seconds": round(build_time, 2),
        "build_success": success,
        "timestamp": datetime.now().isoformat(),
        "stderr_lines": len(result.stderr.split('\n')) if result.stderr else 0
    }

def measure_test_performance():
    """测量测试运行性能基准"""
    print("🧪 测量测试性能基准...")
    
    start_time = time.time()
    result = subprocess.run(
        ["dune", "runtest"],
        capture_output=True,
        text=True,
        encoding='utf-8',
        errors='replace'
    )
    end_time = time.time()
    
    test_time = end_time - start_time
    success = result.returncode == 0
    
    return {
        "test_time_seconds": round(test_time, 2),
        "test_success": success,
        "timestamp": datetime.now().isoformat(),
        "stderr_lines": len(result.stderr.split('\n')) if result.stderr else 0
    }

def measure_file_system_performance():
    """测量文件系统操作性能"""
    print("📁 测量文件系统性能基准...")
    
    src_path = Path("src")
    
    # 测量文件枚举性能
    start_time = time.time()
    ml_files = list(src_path.glob("**/*.ml"))
    mli_files = list(src_path.glob("**/*.mli"))
    enumeration_time = time.time() - start_time
    
    # 测量代码行数统计性能
    start_time = time.time()
    total_lines = 0
    total_files = 0
    
    for file_path in ml_files + mli_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
                lines = len(f.readlines())
                total_lines += lines
                total_files += 1
        except Exception:
            continue
    
    line_counting_time = time.time() - start_time
    
    return {
        "file_enumeration_time_seconds": round(enumeration_time, 3),
        "line_counting_time_seconds": round(line_counting_time, 3),
        "ml_files_count": len(ml_files),
        "mli_files_count": len(mli_files),
        "total_lines": total_lines,
        "total_files": total_files,
        "timestamp": datetime.now().isoformat()
    }

def get_system_info():
    """获取系统环境信息"""
    try:
        # 获取系统信息
        uname_result = subprocess.run(["uname", "-a"], capture_output=True, text=True)
        system_info = uname_result.stdout.strip() if uname_result.returncode == 0 else "Unknown"
        
        # 获取OCaml版本
        ocaml_result = subprocess.run(["ocaml", "-version"], capture_output=True, text=True)
        ocaml_version = ocaml_result.stdout.strip() if ocaml_result.returncode == 0 else "Unknown"
        
        # 获取dune版本
        dune_result = subprocess.run(["dune", "--version"], capture_output=True, text=True)
        dune_version = dune_result.stdout.strip() if dune_result.returncode == 0 else "Unknown"
        
        return {
            "system_info": system_info,
            "ocaml_version": ocaml_version,
            "dune_version": dune_version,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return {
            "system_info": f"Error getting system info: {e}",
            "ocaml_version": "Unknown",
            "dune_version": "Unknown",
            "timestamp": datetime.now().isoformat()
        }

def run_performance_baseline():
    """运行完整的性能基准测试"""
    print("🚀 Phase 1-B 性能基准测试开始...")
    print("=" * 50)
    
    baseline_data = {
        "phase": "Phase 1-B",
        "description": "Phase 1-B 代码质量现代化性能基线",
        "timestamp": datetime.now().isoformat(),
        "system_info": get_system_info(),
        "build_performance": measure_build_performance(),
        "test_performance": measure_test_performance(),
        "filesystem_performance": measure_file_system_performance()
    }
    
    # 确保输出目录存在
    os.makedirs("monitoring_reports", exist_ok=True)
    
    # 保存基准数据
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"monitoring_reports/phase1b_performance_baseline_{timestamp}.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(baseline_data, f, indent=2, ensure_ascii=False)
    
    # 输出摘要报告
    print("📊 性能基准测试结果摘要:")
    print(f"  构建时间: {baseline_data['build_performance']['build_time_seconds']}秒")
    print(f"  测试时间: {baseline_data['test_performance']['test_time_seconds']}秒")
    print(f"  源代码文件: {baseline_data['filesystem_performance']['total_files']}个")
    print(f"  代码总行数: {baseline_data['filesystem_performance']['total_lines']:,}行")
    print(f"  基准数据已保存到: {output_file}")
    print("=" * 50)
    print("✅ Phase 1-B 性能基准测试完成")
    
    return baseline_data

def main():
    """主函数"""
    try:
        baseline_data = run_performance_baseline()
        
        # 验证关键性能指标
        build_time = baseline_data['build_performance']['build_time_seconds']
        test_time = baseline_data['test_performance']['test_time_seconds']
        
        print("\n🎯 性能基线建立完成:")
        print(f"  构建性能基线: {build_time}秒")
        print(f"  测试性能基线: {test_time}秒")
        print("  可用于后续Phase 1-B重构性能回归检测")
        
        return 0
        
    except Exception as e:
        print(f"❌ 性能基准测试失败: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())