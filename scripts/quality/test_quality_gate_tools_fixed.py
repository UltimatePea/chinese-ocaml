#!/usr/bin/env python3
"""
质量门控工具测试套件 - 修复版本

这个测试套件验证修复后的质量门控工具的正确性，
确保工具能够准确检测问题并避免误报。

Author: Charlie, 规划代理
@version 2.0 - 修复版：响应Issue #1801质量问题
@since 2025-07-30 - Fix #1801 系统性质量问题修复
"""

import unittest
import tempfile
import os
import shutil
from pathlib import Path
import sys

# 添加脚本路径以导入被测试模块
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from quality_gate_tools_fixed import (
    OCamlParser, DataIntegrityChecker, TestCoverageChecker, 
    PerformanceAnalyzer, QualityGateOrchestrator
)

class TestOCamlParser(unittest.TestCase):
    """OCaml解析器测试"""
    
    def setUp(self):
        """设置测试"""
        self.parser = OCamlParser()
    
    def test_simple_list_parsing(self):
        """测试简单列表解析"""
        content = '''
        let test_list = [
            "a"; "b"; "c"
        ]
        '''
        
        lists = self.parser.parse_character_lists(content)
        self.assertIn("test_list", lists)
        self.assertEqual(["a", "b", "c"], lists["test_list"])
    
    def test_multiline_list_parsing(self):
        """测试多行列表解析"""
        content = '''
        let ping_sheng_chars = [
            "思"; "丝"; "时"; "持"; "支"; "春"; "人"; "真"; "因"; "新";
            "身"; "神"; "深"; "心"; "今"; "金"; "林"; "临"; "音"; "吟";
        ]
        '''
        
        lists = self.parser.parse_character_lists(content)
        self.assertIn("ping_sheng_chars", lists)
        expected = ["思", "丝", "时", "持", "支", "春", "人", "真", "因", "新",
                   "身", "神", "深", "心", "今", "金", "林", "临", "音", "吟"]
        self.assertEqual(expected, lists["ping_sheng_chars"])
    
    def test_comment_handling(self):
        """测试注释处理"""
        content = '''
        (* 这是注释 *)
        let test_list = [
            "a"; "b"; (* 内联注释 *) "c"
        ]
        (* 
        多行注释
        应该被忽略
        *)
        '''
        
        lists = self.parser.parse_character_lists(content)
        self.assertIn("test_list", lists)
        self.assertEqual(["a", "b", "c"], lists["test_list"])

class TestDataIntegrityChecker(unittest.TestCase):
    """数据完整性检查器测试"""
    
    def setUp(self):
        """设置测试"""
        self.checker = DataIntegrityChecker()
        self.temp_dir = tempfile.mkdtemp()
    
    def tearDown(self):
        """清理测试"""
        shutil.rmtree(self.temp_dir)
    
    def create_test_file(self, filename: str, content: str) -> str:
        """创建测试文件"""
        file_path = os.path.join(self.temp_dir, filename)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return file_path
    
    def test_detect_duplicates_within_list(self):
        """测试检测列表内重复"""
        content = '''
        let test_chars = [
            "a"; "b"; "a"; "c"
        ]
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.checker.check_file(file_path)
        
        # 应该检测到重复的"a"
        duplicate_issues = [i for i in issues if i.issue_type == "DUPLICATE"]
        self.assertGreaterEqual(len(duplicate_issues), 1)
        self.assertTrue(any("'a'" in issue.description for issue in duplicate_issues))
    
    def test_detect_cross_list_duplicates(self):
        """测试检测跨列表重复"""
        content = '''
        let list1 = ["a"; "b"; "c"]
        let list2 = ["d"; "a"; "e"]
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.checker.check_file(file_path)
        
        # 应该检测到"a"在两个列表中
        duplicate_issues = [i for i in issues if i.issue_type == "DUPLICATE"]
        self.assertEqual(1, len(duplicate_issues))
        self.assertIn("'a'", duplicate_issues[0].description)
    
    def test_detect_classification_errors(self):
        """测试检测分类错误"""
        content = '''
        let ze_sheng_chars = ["a"; "b"; "c"]
        let qu_sheng_chars = ["a"; "b"; "c"]
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.checker.check_file(file_path)
        
        # 应该检测到声调分类完全相同
        classification_issues = [i for i in issues if i.issue_type == "CLASSIFICATION_ERROR"]
        self.assertEqual(1, len(classification_issues))
        self.assertIn("完全相同", classification_issues[0].description)
    
    def test_no_false_positives_on_correct_data(self):
        """测试正确数据不会产生误报"""
        content = '''
        let ping_sheng_chars = ["a"; "b"; "c"]
        let ze_sheng_chars = ["d"; "e"; "f"]
        let qu_sheng_chars = ["g"; "h"; "i"]
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.checker.check_file(file_path)
        
        # 正确的数据不应该产生任何问题
        self.assertEqual(0, len(issues))

class TestTestCoverageChecker(unittest.TestCase):
    """测试覆盖率检查器测试"""
    
    def setUp(self):
        """设置测试"""
        self.checker = TestCoverageChecker()
        self.temp_dir = tempfile.mkdtemp()
    
    def tearDown(self):
        """清理测试"""
        shutil.rmtree(self.temp_dir)
    
    def create_test_structure(self):
        """创建测试项目结构"""
        # 创建源文件
        src_dir = os.path.join(self.temp_dir, "src")
        os.makedirs(src_dir)
        
        with open(os.path.join(src_dir, "main.ml"), 'w') as f:
            f.write('''
(* 主模块 *)
let add x y = x + y
let multiply x y = x * y
let calculate x y = 
  let sum = add x y in
  let product = multiply x y in
  (sum, product)
            ''')
        
        # 创建测试文件
        test_dir = os.path.join(self.temp_dir, "test")
        os.makedirs(test_dir)
        
        with open(os.path.join(test_dir, "test_main.ml"), 'w') as f:
            f.write('''
(* 测试模块 *)
let test_add () = 
  assert (add 1 2 = 3)
            ''')
    
    def test_correct_coverage_calculation(self):
        """测试正确的覆盖率计算"""
        self.create_test_structure()
        
        analysis = self.checker.analyze_coverage(self.temp_dir)
        
        # 验证基本统计
        self.assertEqual(1, analysis["total_code_files"])
        self.assertEqual(1, analysis["total_test_files"])
        self.assertGreater(analysis["total_code_lines"], 0)
        self.assertGreater(analysis["total_test_lines"], 0)
        
        # 验证覆盖率不会超过100%或产生荒谬数值
        self.assertLessEqual(analysis["coverage_percentage"], 100)
        self.assertGreater(analysis["coverage_percentage"], 0)
    
    def test_empty_project_coverage(self):
        """测试空项目的覆盖率"""
        # 空目录
        analysis = self.checker.analyze_coverage(self.temp_dir)
        
        self.assertEqual(0, analysis["total_code_files"])
        self.assertEqual(0, analysis["total_test_files"])
        self.assertEqual(0, analysis["coverage_percentage"])

class TestPerformanceAnalyzer(unittest.TestCase):
    """性能分析器测试"""
    
    def setUp(self):
        """设置测试"""
        self.analyzer = PerformanceAnalyzer()
        self.temp_dir = tempfile.mkdtemp()
    
    def tearDown(self):
        """清理测试"""
        shutil.rmtree(self.temp_dir)
    
    def create_test_file(self, filename: str, content: str) -> str:
        """创建测试文件"""
        file_path = os.path.join(self.temp_dir, filename)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return file_path
    
    def test_detect_real_performance_issues(self):
        """测试检测真实性能问题"""
        content = '''
        let inefficient_search chars target =
          List.fold_left (fun acc char ->
            if List.mem char target_list then
              List.mem char other_list
            else acc
          ) false chars
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.analyzer.analyze_file(file_path)
        
        # 应该检测到性能问题
        self.assertGreater(len(issues), 0)
        
        # 验证问题类型
        issue_types = [issue["type"] for issue in issues]
        self.assertTrue(any(t in issue_types for t in ["inefficient_search", "o_n_squared"]))
    
    def test_no_false_positives_on_simple_code(self):
        """测试简单代码不会产生误报"""
        content = '''
        let simple_function x = x + 1
        let another_function y = y * 2
        let call_function = simple_function 42
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.analyzer.analyze_file(file_path)
        
        # 简单代码不应该产生性能问题
        self.assertEqual(0, len(issues))
    
    def test_severity_classification(self):
        """测试严重程度分类"""
        content = '''
        let nested_problem data =
          List.fold_left (fun acc1 item1 ->
            List.fold_left (fun acc2 item2 ->
              acc2 + 1
            ) acc1 data
          ) 0 data
        '''
        
        file_path = self.create_test_file("test.ml", content)
        issues = self.analyzer.analyze_file(file_path)
        
        if issues:
            # 嵌套循环应该是高严重程度
            high_severity = [i for i in issues if i["severity"] == "HIGH"]
            self.assertGreater(len(high_severity), 0)

class TestQualityGateOrchestrator(unittest.TestCase):
    """质量门控协调器测试"""
    
    def setUp(self):
        """设置测试"""
        self.temp_dir = tempfile.mkdtemp()
        self.orchestrator = QualityGateOrchestrator(self.temp_dir)
    
    def tearDown(self):
        """清理测试"""
        shutil.rmtree(self.temp_dir)
    
    def test_integration_with_good_project(self):
        """测试与良好项目的集成"""
        # 创建一个模拟的良好项目结构
        src_dir = os.path.join(self.temp_dir, "src")
        test_dir = os.path.join(self.temp_dir, "test")
        os.makedirs(src_dir)
        os.makedirs(test_dir)
        
        # 创建源文件
        with open(os.path.join(src_dir, "rhyme_data.ml"), 'w') as f:
            f.write('''
            let ping_sheng_chars = ["a"; "b"; "c"]
            let ze_sheng_chars = ["d"; "e"; "f"]
            ''')
        
        # 创建测试文件
        with open(os.path.join(test_dir, "test_rhyme.ml"), 'w') as f:
            f.write('''
            let test_function () = assert true
            let test_another () = assert true
            ''')
        
        # 运行所有检查
        reports = self.orchestrator.run_all_checks()
        summary = self.orchestrator.generate_summary_report(reports)
        
        # 验证报告结构
        self.assertIn("overall_status", summary)
        self.assertIn("individual_reports", summary)
        self.assertIn("quality_gate_version", summary)
        
        # 良好的项目应该通过大部分检查
        self.assertIn(summary["overall_status"], ["PASS", "WARN"])

class TestKnownIssueValidation(unittest.TestCase):
    """已知问题验证测试 - 确保工具能检测Delta代理发现的问题"""
    
    def setUp(self):
        """设置测试"""
        self.temp_dir = tempfile.mkdtemp()
        self.checker = DataIntegrityChecker()
    
    def tearDown(self):
        """清理测试"""
        shutil.rmtree(self.temp_dir)
    
    def test_detect_delta_reported_duplicates(self):
        """测试检测Delta代理报告的重复问题"""
        # 模拟Delta代理发现的问题
        content = '''
        let an_rhyme_group_data = {
          ping_sheng_chars = [
            "班"; "团"; "关"; "班"; "团"; "关"
          ];
        }
        '''
        
        file_path = os.path.join(self.temp_dir, "test.ml")
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        issues = self.checker.check_file(file_path)
        
        # 应该检测到所有重复
        duplicate_issues = [i for i in issues if i.issue_type == "DUPLICATE"]
        self.assertGreaterEqual(len(duplicate_issues), 3)  # "班", "团", "关" 各一个重复
    
    def test_detect_delta_reported_classification_error(self):
        """测试检测Delta代理报告的分类错误"""
        # 模拟思韵组ze_sheng和qu_sheng完全重复的问题
        content = '''
        let ze_sheng_chars = ["信"; "印"; "引"; "隐"; "问"; "闻"]
        let qu_sheng_chars = ["信"; "印"; "引"; "隐"; "问"; "闻"]
        '''
        
        file_path = os.path.join(self.temp_dir, "test.ml")
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        issues = self.checker.check_file(file_path)
        
        # 应该检测到分类错误
        classification_issues = [i for i in issues if i.issue_type == "CLASSIFICATION_ERROR"]
        self.assertEqual(1, len(classification_issues))

def create_test_suite():
    """创建测试套件"""
    suite = unittest.TestSuite()
    
    # 添加所有测试类
    test_classes = [
        TestOCamlParser,
        TestDataIntegrityChecker,
        TestTestCoverageChecker,
        TestPerformanceAnalyzer,
        TestQualityGateOrchestrator,
        TestKnownIssueValidation
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        suite.addTests(tests)
    
    return suite

def main():
    """主函数"""
    print("🧪 运行质量门控工具测试套件...")
    
    suite = create_test_suite()
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # 输出测试结果摘要
    print(f"\n📊 测试结果摘要:")
    print(f"运行测试: {result.testsRun}")
    print(f"失败: {len(result.failures)}")
    print(f"错误: {len(result.errors)}")
    print(f"跳过: {len(result.skipped)}")
    
    if result.failures:
        print("\n❌ 失败的测试:")
        for test, traceback in result.failures:
            lines = traceback.split('\n') if traceback else []
            error_msg = lines[-2] if len(lines) >= 2 else 'Unknown error'
            print(f"  - {test}: {error_msg}")
    
    if result.errors:
        print("\n💥 错误的测试:")
        for test, traceback in result.errors:
            lines = traceback.split('\n') if traceback else []
            error_msg = lines[-2] if len(lines) >= 2 else 'Unknown error'
            print(f"  - {test}: {error_msg}")
    
    # 设置退出码
    if result.failures or result.errors:
        print("\n❌ 测试套件失败")
        sys.exit(1)
    else:
        print("\n✅ 所有测试通过")
        sys.exit(0)

if __name__ == "__main__":
    main()