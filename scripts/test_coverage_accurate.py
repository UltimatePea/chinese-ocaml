#!/usr/bin/env python3
"""
准确的测试覆盖率分析脚本
Author: Echo, 测试工程师代理
修复Issue #1709中提到的测试覆盖率数据不准确问题
"""

import os
import subprocess
import json
from datetime import datetime
from pathlib import Path

def count_source_lines():
    """统计实际源代码行数"""
    try:
        # 统计.ml和.mli文件
        result = subprocess.run([
            'find', '.', '-name', '*.ml', '-o', '-name', '*.mli'
        ], capture_output=True, text=True, cwd='.')
        
        files = result.stdout.strip().split('\n') if result.stdout.strip() else []
        
        total_lines = 0
        source_files = []
        
        for file_path in files:
            if file_path and os.path.exists(file_path):
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        lines = len(f.readlines())
                        total_lines += lines
                        source_files.append({
                            'file': file_path,
                            'lines': lines
                        })
                except:
                    continue
        
        return total_lines, len(source_files), source_files
    except Exception as e:
        print(f"源代码统计错误: {e}")
        return 0, 0, []

def run_coverage_analysis():
    """运行测试覆盖率分析"""
    try:
        # 清理构建
        subprocess.run(['dune', 'clean'], capture_output=True)
        
        # 运行测试并收集覆盖率数据
        result = subprocess.run([
            'dune', 'runtest', '--instrument-with', 'bisect_ppx'
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("测试运行失败，使用基本统计:")
            print(result.stderr[:500])
            return None
            
        # 尝试生成bisect覆盖率报告
        coverage_result = subprocess.run([
            'bisect-ppx-report', 'summary'
        ], capture_output=True, text=True)
        
        if coverage_result.returncode == 0:
            return coverage_result.stdout
        else:
            print("Bisect覆盖率报告生成失败")
            return None
            
    except Exception as e:
        print(f"覆盖率分析错误: {e}")
        return None

def analyze_poetry_tests():
    """分析Poetry模块相关的测试情况"""
    poetry_tests = []
    test_dir = Path('test')
    
    if test_dir.exists():
        # 查找所有poetry相关测试文件
        for test_file in test_dir.rglob('*poetry*.ml'):
            poetry_tests.append(str(test_file))
        
        for test_file in test_dir.rglob('test_*poetry*.ml'):
            if str(test_file) not in poetry_tests:
                poetry_tests.append(str(test_file))
    
    return poetry_tests

def generate_accurate_report():
    """生成准确的测试覆盖率报告"""
    print("🔍 Echo测试工程师 - 准确测试覆盖率分析")
    print("=" * 50)
    
    # 统计源代码
    total_lines, total_files, source_files = count_source_lines()
    print(f"📊 源代码统计:")
    print(f"   总文件数: {total_files}")
    print(f"   总代码行数: {total_lines}")
    
    # 分析测试覆盖率
    coverage_info = run_coverage_analysis()
    
    # 分析Poetry测试
    poetry_tests = analyze_poetry_tests()
    print(f"\n🎭 Poetry模块测试:")
    print(f"   Poetry测试文件数: {len(poetry_tests)}")
    for test in poetry_tests[:10]:  # 显示前10个
        print(f"   - {test}")
    if len(poetry_tests) > 10:
        print(f"   ... 还有{len(poetry_tests) - 10}个文件")
    
    # 生成报告
    report_data = {
        'timestamp': datetime.now().isoformat(),
        'source_statistics': {
            'total_files': total_files,
            'total_lines': total_lines
        },
        'poetry_tests_count': len(poetry_tests),
        'poetry_test_files': poetry_tests,
        'coverage_raw_output': coverage_info,
        'analysis_author': 'Echo, 测试工程师代理'
    }
    
    # 保存详细报告
    report_file = f'coverage_reports/accurate_coverage_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
    os.makedirs('coverage_reports', exist_ok=True)
    
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report_data, f, indent=2, ensure_ascii=False)
    
    # 更新简单摘要
    summary_file = 'coverage_reports/coverage_summary.txt'
    with open(summary_file, 'w', encoding='utf-8') as f:
        if coverage_info and 'Coverage:' in coverage_info:
            f.write(coverage_info.strip() + '\n')
        else:
            f.write(f"Coverage: 检测中/总计{total_lines}行 (需要实际测试运行)\n")
        f.write(f"Generated: {datetime.now().isoformat()}\n")
        f.write(f"By: Echo测试工程师代理\n")
    
    print(f"\n📋 报告已生成:")
    print(f"   详细报告: {report_file}")
    print(f"   简要摘要: {summary_file}")
    
    return report_data

if __name__ == '__main__':
    generate_accurate_report()