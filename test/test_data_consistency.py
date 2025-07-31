#!/usr/bin/env python3
"""
数据一致性验证器测试
Author: Whisky, PR Worker

测试data_consistency_validator.py的功能
"""

import unittest
import sys
import os
import tempfile
import subprocess
from pathlib import Path

# Add scripts directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from data_consistency_validator import ProjectDataValidator

class TestDataConsistencyValidator(unittest.TestCase):
    def setUp(self):
        """设置测试环境"""
        self.test_dir = tempfile.mkdtemp()
        self.validator = ProjectDataValidator(self.test_dir)
    
    def test_command_execution(self):
        """测试命令执行功能"""
        success, output, error = self.validator.run_command("echo 'test'")
        self.assertTrue(success)
        self.assertEqual(output, "test")
        self.assertEqual(error, "")
    
    def test_command_timeout(self):
        """测试命令超时功能"""
        # 测试短命令不会超时
        success, output, error = self.validator.run_command("echo 'quick'")
        self.assertTrue(success)
    
    def test_log_validation(self):
        """测试验证日志功能"""
        self.validator.log_validation("INFO", "测试日志")
        self.assertEqual(len(self.validator.validation_log), 1)
        self.assertIn("测试日志", self.validator.validation_log[0])
    
    def test_coverage_file_check(self):
        """测试覆盖率文件检查"""
        # 在真实项目中测试
        if os.path.exists("latest_coverage.txt"):
            with open("latest_coverage.txt", "r") as f:
                content = f.read().strip()
                try:
                    coverage = float(content)
                    self.assertGreaterEqual(coverage, 0.0)
                    self.assertLessEqual(coverage, 100.0)
                except ValueError:
                    self.fail("coverage文件包含无效数据")
    
    def test_project_statistics_format(self):
        """测试项目统计数据格式"""
        # 在真实项目环境中测试
        real_validator = ProjectDataValidator(".")
        if os.path.exists("src/") and os.path.exists("test/"):
            stats = real_validator.collect_project_statistics()
            
            # 检查必要的统计数据字段
            required_fields = ['ocaml_files', 'src_files', 'test_files', 
                             'git_commits', 'doc_files']
            for field in required_fields:
                self.assertIn(field, stats)
                self.assertIsInstance(stats[field], int)
                self.assertGreaterEqual(stats[field], 0)

if __name__ == '__main__':
    # 测试是否在项目根目录
    if not os.path.exists("src/") or not os.path.exists("scripts/data_consistency_validator.py"):
        print("警告: 请在项目根目录运行测试")
        sys.exit(1)
    
    unittest.main()