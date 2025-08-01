#!/usr/bin/env python3
"""
骆言项目健康度监控脚本
Author: Whisky, PR Worker
Date: 2025-08-01

用于监控项目构建健康度、性能指标和模块统计
"""

import subprocess
import time
import json
import os
from datetime import datetime
from pathlib import Path

class HealthMonitor:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.metrics_file = self.project_root / "health_metrics.json"
        
    def run_command(self, cmd, timeout=30):
        """运行命令并返回结果"""
        try:
            start_time = time.time()
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=timeout,
                cwd=self.project_root
            )
            end_time = time.time()
            return {
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'duration': end_time - start_time,
                'returncode': result.returncode
            }
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'stdout': '',
                'stderr': f'命令超时 (>{timeout}s)',
                'duration': timeout,
                'returncode': -1
            }
        except Exception as e:
            return {
                'success': False,
                'stdout': '',
                'stderr': str(e),
                'duration': 0,
                'returncode': -2
            }
    
    def check_build_health(self):
        """检查构建健康度"""
        print("🔨 检查构建健康度...")
        build_result = self.run_command("dune build")
        
        return {
            'build_success': build_result['success'],
            'build_time': build_result['duration'],
            'build_output': build_result['stderr'] if not build_result['success'] else "构建成功",
            'warnings_count': build_result['stderr'].count('Warning') if build_result['stderr'] else 0
        }
    
    def check_test_health(self):
        """检查测试健康度"""
        print("🧪 检查测试健康度...")
        test_result = self.run_command("dune runtest", timeout=60)
        
        return {
            'test_success': test_result['success'],
            'test_time': test_result['duration'],
            'test_output': test_result['stderr'] if not test_result['success'] else "测试通过"
        }
    
    def count_modules(self):
        """统计模块数量"""
        print("📊 统计模块数量...")
        
        stats = {}
        
        # 总ML文件数
        ml_count = self.run_command("find . -name '*.ml' -type f | wc -l")
        stats['total_ml_files'] = int(ml_count['stdout'].strip()) if ml_count['success'] else 0
        
        # 诗词模块数
        poetry_count = self.run_command("find ./src/poetry -name '*.ml' -type f | wc -l")
        stats['poetry_modules'] = int(poetry_count['stdout'].strip()) if poetry_count['success'] else 0
        
        # 测试文件数
        test_count = self.run_command("find ./test -name '*.ml' -type f | wc -l")
        stats['test_files'] = int(test_count['stdout'].strip()) if test_count['success'] else 0
        
        # 诗词测试文件数
        poetry_test_count = self.run_command("find ./test -name '*poetry*' -name '*.ml' -type f | wc -l")
        stats['poetry_test_files'] = int(poetry_test_count['stdout'].strip()) if poetry_test_count['success'] else 0
        
        return stats
    
    def check_git_status(self):
        """检查Git状态"""
        print("📝 检查Git状态...")
        
        branch_result = self.run_command("git branch --show-current")
        status_result = self.run_command("git status --porcelain")
        
        return {
            'current_branch': branch_result['stdout'].strip() if branch_result['success'] else "unknown",
            'dirty_files_count': len([line for line in status_result['stdout'].splitlines() if line.strip()]) if status_result['success'] else 0,
            'has_uncommitted_changes': bool(status_result['stdout'].strip()) if status_result['success'] else False
        }
    
    def generate_report(self):
        """生成健康度报告"""
        timestamp = datetime.now().isoformat()
        print(f"🏥 生成健康度报告 - {timestamp}")
        
        report = {
            'timestamp': timestamp,
            'build_health': self.check_build_health(),
            'test_health': self.check_test_health(),
            'module_stats': self.count_modules(),
            'git_status': self.check_git_status()
        }
        
        # 保存到文件
        with open(self.metrics_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        return report
    
    def print_summary(self, report):
        """打印摘要"""
        print("\n" + "="*50)
        print("📋 骆言项目健康度报告摘要")
        print("="*50)
        
        # 构建状态
        build = report['build_health']
        build_status = "✅ 成功" if build['build_success'] else "❌ 失败"
        print(f"🔨 构建状态: {build_status} ({build['build_time']:.2f}s)")
        if build['warnings_count'] > 0:
            print(f"⚠️  警告数量: {build['warnings_count']}")
        
        # 测试状态
        test = report['test_health']
        test_status = "✅ 通过" if test['test_success'] else "❌ 失败"
        print(f"🧪 测试状态: {test_status} ({test['test_time']:.2f}s)")
        
        # 模块统计
        stats = report['module_stats']
        print(f"📊 总ML文件: {stats['total_ml_files']}")
        print(f"🎭 诗词模块: {stats['poetry_modules']}")
        print(f"🧪 测试文件: {stats['test_files']} (诗词: {stats['poetry_test_files']})")
        
        # Git状态
        git = report['git_status']
        print(f"📝 当前分支: {git['current_branch']}")
        if git['has_uncommitted_changes']:
            print(f"⚠️  未提交文件: {git['dirty_files_count']}")
        else:
            print("✅ 工作目录干净")
        
        print("\n📄 详细报告已保存到: health_metrics.json")
        print("="*50)

def main():
    monitor = HealthMonitor()
    report = monitor.generate_report()
    monitor.print_summary(report)

if __name__ == "__main__":
    main()