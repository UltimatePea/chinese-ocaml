#!/usr/bin/env python3
"""
Phase 1-B 测试覆盖率分析工具 - 修复版
Author: Whisky, PR Implementation Specialist
Date: 2025-08-04

修复UTF-8编码问题，提供准确的测试覆盖率分析
"""

import os
import subprocess
import json
from datetime import datetime
from pathlib import Path
import sys

def count_source_lines():
    """统计实际源代码行数（修复UTF-8编码问题）"""
    try:
        # 统计.ml和.mli文件
        result = subprocess.run([
            'find', '.', '-name', '*.ml', '-o', '-name', '*.mli'
        ], capture_output=True, text=True, cwd='.')
        
        files = result.stdout.strip().split('\n') if result.stdout.strip() else []
        
        total_lines = 0
        source_files = []
        encoding_errors = []
        
        for file_path in files:
            if file_path and os.path.exists(file_path):
                try:
                    # 尝试多种编码方式
                    encodings = ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']
                    content = None
                    
                    for encoding in encodings:
                        try:
                            with open(file_path, 'r', encoding=encoding) as f:
                                content = f.readlines()
                                break
                        except UnicodeDecodeError:
                            continue
                    
                    if content is not None:
                        lines = len(content)
                        total_lines += lines
                        source_files.append({
                            'file': file_path,
                            'lines': lines
                        })
                    else:
                        encoding_errors.append(file_path)
                        
                except Exception as e:
                    encoding_errors.append(f"{file_path}: {e}")
                    continue
        
        return total_lines, len(source_files), source_files, encoding_errors
    except Exception as e:
        print(f"源代码统计错误: {e}")
        return 0, 0, [], []

def run_test_execution_analysis():
    """运行测试执行分析（不依赖bisect）"""
    try:
        print("🔬 执行测试套件分析...")
        
        # 运行基本测试
        result = subprocess.run([
            'dune', 'runtest', '--verbose'
        ], capture_output=True, text=True, timeout=300)
        
        test_output = result.stdout + result.stderr
        
        # 分析测试结果
        tests_run = 0
        tests_passed = 0
        tests_failed = 0
        
        lines = test_output.split('\n')
        for line in lines:
            if 'Test Successful' in line:
                tests_passed += 1
            elif 'Test Failed' in line or 'FAILED' in line:
                tests_failed += 1
            elif 'tests run' in line:
                try:
                    # 提取运行的测试数量
                    parts = line.split()
                    for i, part in enumerate(parts):
                        if part == 'tests' and i > 0:
                            tests_run += int(parts[i-1])
                            break
                except:
                    pass
        
        return {
            'tests_executed': tests_run,
            'tests_passed': tests_passed,
            'tests_failed': tests_failed,
            'test_output_sample': test_output[:1000],
            'return_code': result.returncode
        }
        
    except subprocess.TimeoutExpired:
        return {'error': '测试执行超时'}
    except Exception as e:
        return {'error': f'测试执行错误: {e}'}

def analyze_test_files():
    """分析测试文件结构"""
    test_info = {
        'total_test_files': 0,
        'poetry_test_files': 0,
        'core_test_files': 0,
        'test_directories': [],
        'poetry_tests': []
    }
    
    test_dir = Path('test')
    if test_dir.exists():
        for test_file in test_dir.rglob('*.ml'):
            test_info['total_test_files'] += 1
            
            file_str = str(test_file)
            if 'poetry' in file_str.lower():
                test_info['poetry_test_files'] += 1
                test_info['poetry_tests'].append(file_str)
            
            if 'core' in file_str.lower():
                test_info['core_test_files'] += 1
        
        # 统计测试目录
        for item in test_dir.iterdir():
            if item.is_dir():
                test_info['test_directories'].append(str(item))
    
    return test_info

def estimate_coverage_from_test_execution():
    """基于测试执行情况估算覆盖率"""
    try:
        # 运行构建检查源代码的健康度
        build_result = subprocess.run([
            'dune', 'build', '--verbose'
        ], capture_output=True, text=True, timeout=180)
        
        build_success = build_result.returncode == 0
        
        # 检查可执行的测试文件
        test_exes = []
        build_dir = Path('_build/default/test')
        if build_dir.exists():
            for exe_file in build_dir.rglob('*.exe'):
                test_exes.append(str(exe_file))
        
        return {
            'build_success': build_success,
            'executable_tests': len(test_exes),
            'build_output_sample': build_result.stdout[:500] if build_result.stdout else '',
            'build_errors': build_result.stderr[:500] if build_result.stderr else ''
        }
        
    except subprocess.TimeoutExpired:
        return {'error': '构建超时'}
    except Exception as e:
        return {'error': f'构建分析错误: {e}'}

def generate_phase1b_coverage_report():
    """生成Phase 1-B测试覆盖率报告"""
    print("🎯 Phase 1-B 测试覆盖率分析 - Whisky实施")
    print("=" * 60)
    
    # 统计源代码
    total_lines, total_files, source_files, encoding_errors = count_source_lines()
    print(f"📊 源代码统计:")
    print(f"   总文件数: {total_files}")
    print(f"   总代码行数: {total_lines}")
    
    if encoding_errors:
        print(f"⚠️  编码问题文件: {len(encoding_errors)}个")
        for error in encoding_errors[:5]:  # 只显示前5个
            print(f"     {error}")
    
    # 分析测试文件
    test_info = analyze_test_files()
    print(f"\n🧪 测试文件分析:")
    print(f"   总测试文件: {test_info['total_test_files']}")
    print(f"   Poetry测试: {test_info['poetry_test_files']}")
    print(f"   Core测试: {test_info['core_test_files']}")
    print(f"   测试目录: {len(test_info['test_directories'])}")
    
    # 构建和执行分析
    build_info = estimate_coverage_from_test_execution()
    print(f"\n🔨 构建状态:")
    print(f"   构建成功: {'✅' if build_info.get('build_success', False) else '❌'}")
    print(f"   可执行测试: {build_info.get('executable_tests', 0)}")
    
    # 测试执行分析
    execution_info = run_test_execution_analysis()
    print(f"\n⚡ 测试执行:")
    if 'error' in execution_info:
        print(f"   执行状态: ❌ {execution_info['error']}")
    else:
        print(f"   测试通过: {execution_info.get('tests_passed', 0)}")
        print(f"   测试失败: {execution_info.get('tests_failed', 0)}")
        print(f"   返回码: {execution_info.get('return_code', 'unknown')}")
    
    # 计算估算覆盖率
    if total_files > 0 and test_info['total_test_files'] > 0:
        # 简单的启发式估算
        test_file_ratio = test_info['total_test_files'] / total_files
        estimated_coverage = min(test_file_ratio * 100, 50.0)  # 最高估算50%
        
        print(f"\n📈 Phase 1-B 覆盖率估算:")
        print(f"   估算覆盖率: {estimated_coverage:.1f}%")
        print(f"   测试/源码比率: {test_file_ratio:.3f}")
    
    # 生成改进建议
    print(f"\n💡 Phase 1-B 改进建议:")
    
    if test_info['poetry_test_files'] < 20:
        print("   🎭 Poetry模块测试不足，需要增加覆盖")
    
    if build_info.get('executable_tests', 0) < test_info['total_test_files']:
        print("   🔧 部分测试文件无法构建，需要修复")
    
    if execution_info.get('tests_failed', 0) > 0:
        print("   ❌ 存在失败测试，需要修复")
    
    if encoding_errors:
        print("   🔤 存在编码问题文件，需要修复UTF-8兼容性")
    
    # 保存报告
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = f"doc/analysis/phase1b-test-coverage-analysis-{timestamp}.md"
    
    # 确保目录存在
    os.makedirs(os.path.dirname(report_file), exist_ok=True)
    
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write("# Phase 1-B 测试覆盖率分析报告\n\n")
        f.write(f"**Author: Whisky, PR Implementation Specialist**\n")
        f.write(f"**生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}**\n\n")
        
        f.write("## 源代码统计\n\n")
        f.write(f"- **总文件数**: {total_files}\n")
        f.write(f"- **总代码行数**: {total_lines}\n")
        f.write(f"- **编码问题文件**: {len(encoding_errors)}\n\n")
        
        f.write("## 测试覆盖现状\n\n")
        f.write(f"- **测试文件总数**: {test_info['total_test_files']}\n")
        f.write(f"- **Poetry相关测试**: {test_info['poetry_test_files']}\n")
        f.write(f"- **Core模块测试**: {test_info['core_test_files']}\n")
        f.write(f"- **可执行测试**: {build_info.get('executable_tests', 0)}\n\n")
        
        if 'error' not in execution_info:
            f.write("## 测试执行结果\n\n")
            f.write(f"- **测试通过**: {execution_info.get('tests_passed', 0)}\n")
            f.write(f"- **测试失败**: {execution_info.get('tests_failed', 0)}\n\n")
        
        f.write("## Phase 1-B 技术债务清理建议\n\n")
        f.write("### 高优先级改进:\n")
        f.write("1. **修复编码问题** - 确保所有文件UTF-8兼容\n")
        f.write("2. **构建系统优化** - 确保所有测试可构建\n")
        f.write("3. **失败测试修复** - 修复现有失败测试\n\n")
        
        f.write("### 测试覆盖率提升策略:\n")
        f.write("1. **Poetry模块**: 增加特定功能测试\n")
        f.write("2. **Core模块**: 提升基础功能覆盖\n")
        f.write("3. **集成测试**: 建立端到端测试\n\n")
        
        f.write("---\n")
        f.write("**下一步**: 基于此分析开始Phase 1-B的测试基础设施现代化工作\n")
    
    print(f"\n📋 报告已生成: {report_file}")
    
    return {
        'total_files': total_files,
        'total_lines': total_lines,
        'test_files': test_info['total_test_files'],
        'poetry_tests': test_info['poetry_test_files'],
        'encoding_errors': len(encoding_errors),
        'build_success': build_info.get('build_success', False),
        'executable_tests': build_info.get('executable_tests', 0)
    }

def main():
    try:
        report_data = generate_phase1b_coverage_report()
        
        print(f"\n✅ Phase 1-B 测试覆盖率分析完成")
        print(f"   源代码: {report_data['total_files']} 文件, {report_data['total_lines']} 行")
        print(f"   测试文件: {report_data['test_files']} 个")
        print(f"   Poetry测试: {report_data['poetry_tests']} 个")
        
        if report_data['encoding_errors'] > 0:
            print(f"   ⚠️  需要修复 {report_data['encoding_errors']} 个编码问题文件")
        
        if not report_data['build_success']:
            print("   ⚠️  构建系统需要修复")
        
        print(f"\n🚀 准备继续Phase 1-B技术债务清理工作...")
        
    except Exception as e:
        print(f"❌ 分析过程出错: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()