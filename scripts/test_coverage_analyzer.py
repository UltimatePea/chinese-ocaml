#!/usr/bin/env python3
"""
骆言项目测试覆盖率分析工具 - Fix #732
分析项目的测试覆盖情况并生成改进建议
"""

import os
import glob
import json
from collections import defaultdict, Counter
from pathlib import Path

class TestCoverageAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.src_dir = self.project_root / "src"
        self.test_dir = self.project_root / "test"
        
    def analyze_source_files(self):
        """分析源文件结构"""
        source_files = {}
        
        for ml_file in self.src_dir.glob("**/*.ml"):
            rel_path = ml_file.relative_to(self.src_dir)
            module_name = ml_file.stem
            
            # 获取文件大小和行数
            try:
                with open(ml_file, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    line_count = len(lines)
                    
                source_files[str(rel_path)] = {
                    'module': module_name,
                    'path': str(ml_file),
                    'lines': line_count,
                    'size': ml_file.stat().st_size,
                    'category': self.categorize_module(rel_path)
                }
            except Exception as e:
                print(f"读取文件失败 {ml_file}: {e}")
                
        return source_files
    
    def analyze_test_files(self):
        """分析测试文件结构"""
        test_files = {}
        
        for test_file in self.test_dir.glob("**/*.ml"):
            rel_path = test_file.relative_to(self.test_dir)
            test_name = test_file.stem
            
            try:
                with open(test_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                test_files[str(rel_path)] = {
                    'name': test_name,
                    'path': str(test_file),
                    'lines': len(lines),
                    'content': content,
                    'tested_modules': self.extract_tested_modules(content)
                }
            except Exception as e:
                print(f"读取测试文件失败 {test_file}: {e}")
                
        return test_files
    
    def categorize_module(self, rel_path):
        """根据路径分类模块"""
        path_str = str(rel_path)
        
        if 'lexer' in path_str or 'token' in path_str:
            return '词法分析'
        elif 'parser' in path_str:
            return '语法分析'
        elif 'semantic' in path_str:
            return '语义分析'
        elif 'types' in path_str:
            return '类型系统'
        elif 'poetry' in path_str:
            return '诗词编程'
        elif 'error' in path_str:
            return '错误处理'
        elif 'codegen' in path_str or 'c_' in path_str:
            return '代码生成'
        elif 'builtin' in path_str:
            return '内置函数'
        elif 'config' in path_str:
            return '配置管理'
        elif 'unicode' in path_str or 'utf8' in path_str:
            return 'Unicode处理'
        else:
            return '其他'
    
    def extract_tested_modules(self, content):
        """从测试内容中提取被测试的模块"""
        modules = set()
        
        # 查找模块引用
        lines = content.split('\n')
        for line in lines:
            if 'open' in line and 'Yyocamlc_lib' in line:
                modules.add('Yyocamlc_lib')
            if any(mod in line for mod in ['Lexer.', 'Parser.', 'Semantic.', 'Types.']):
                for mod in ['Lexer', 'Parser', 'Semantic', 'Types']:
                    if f'{mod}.' in line:
                        modules.add(mod)
                        
        return list(modules)
    
    def calculate_coverage_stats(self, source_files, test_files):
        """计算覆盖率统计"""
        category_stats = defaultdict(lambda: {'source_count': 0, 'test_count': 0, 'covered_modules': []})
        
        # 统计源文件
        for file_info in source_files.values():
            category = file_info['category']
            category_stats[category]['source_count'] += 1
            
        # 统计测试文件覆盖情况
        for test_info in test_files.values():
            test_name = test_info['name'].lower()
            
            # 基于测试文件名进行分类映射
            if 'token' in test_name or 'lexer' in test_name:
                category_stats['词法分析']['test_count'] += 1
            elif 'unicode' in test_name or 'utf8' in test_name:
                category_stats['Unicode处理']['test_count'] += 1
            elif 'parser' in test_name:
                category_stats['语法分析']['test_count'] += 1
            elif 'semantic' in test_name:
                category_stats['语义分析']['test_count'] += 1
            elif 'types' in test_name:
                category_stats['类型系统']['test_count'] += 1
            elif 'poetry' in test_name:
                category_stats['诗词编程']['test_count'] += 1
            elif 'error' in test_name:
                category_stats['错误处理']['test_count'] += 1
            elif 'codegen' in test_name or 'c_' in test_name:
                category_stats['代码生成']['test_count'] += 1
            elif 'builtin' in test_name:
                category_stats['内置函数']['test_count'] += 1
            elif 'config' in test_name:
                category_stats['配置管理']['test_count'] += 1
            else:
                category_stats['其他']['test_count'] += 1
                    
        return dict(category_stats)
    
    def generate_coverage_report(self):
        """生成覆盖率报告"""
        print("🔍 骆言项目测试覆盖率分析报告 - Fix #732")
        print("=" * 60)
        
        source_files = self.analyze_source_files()
        test_files = self.analyze_test_files()
        coverage_stats = self.calculate_coverage_stats(source_files, test_files)
        
        print(f"\n📊 基础统计:")
        print(f"  源文件总数: {len(source_files)}")
        print(f"  测试文件总数: {len(test_files)}")
        print(f"  整体覆盖率: {len(test_files)/len(source_files)*100:.1f}%")
        
        print(f"\n📈 分类覆盖率统计:")
        for category, stats in sorted(coverage_stats.items()):
            source_count = stats['source_count']
            test_count = stats['test_count']
            coverage = (test_count / source_count * 100) if source_count > 0 else 0
            print(f"  {category:12} | 源文件: {source_count:3d} | 测试: {test_count:3d} | 覆盖率: {coverage:5.1f}%")
        
        print(f"\n🎯 核心模块覆盖率:")
        core_modules = ['词法分析', '语法分析', '语义分析', '类型系统']
        for module in core_modules:
            if module in coverage_stats:
                stats = coverage_stats[module]
                coverage = (stats['test_count'] / stats['source_count'] * 100) if stats['source_count'] > 0 else 0
                status = "✅" if coverage >= 70 else "⚠️" if coverage >= 40 else "❌"
                print(f"  {status} {module}: {coverage:.1f}%")
        
        print(f"\n🎨 诗词编程特色覆盖率:")
        poetry_categories = ['诗词编程', '错误处理']
        for category in poetry_categories:
            if category in coverage_stats:
                stats = coverage_stats[category]
                coverage = (stats['test_count'] / stats['source_count'] * 100) if stats['source_count'] > 0 else 0
                status = "✅" if coverage >= 60 else "⚠️" if coverage >= 30 else "❌"
                print(f"  {status} {category}: {coverage:.1f}%")
        
        self.generate_improvement_suggestions(coverage_stats)
        
        return {
            'source_files': len(source_files),
            'test_files': len(test_files),
            'coverage_stats': coverage_stats,
            'overall_coverage': len(test_files)/len(source_files)*100
        }
    
    def generate_improvement_suggestions(self, coverage_stats):
        """生成改进建议"""
        print(f"\n💡 测试覆盖率改进建议:")
        
        # 按优先级排序类别
        priority_order = ['词法分析', '语法分析', '语义分析', '类型系统', '错误处理', '诗词编程']
        
        for category in priority_order:
            if category in coverage_stats:
                stats = coverage_stats[category]
                coverage = (stats['test_count'] / stats['source_count'] * 100) if stats['source_count'] > 0 else 0
                
                if coverage < 70:
                    gap = 70 - coverage
                    needed_tests = int(stats['source_count'] * 0.7 - stats['test_count'])
                    priority = "🔥 高优先级" if category in ['词法分析', '语法分析', '语义分析', '类型系统'] else "📈 中优先级"
                    
                    print(f"  {priority} - {category}:")
                    print(f"    当前覆盖率: {coverage:.1f}% (目标: 70%)")
                    print(f"    建议新增测试: {needed_tests} 个")
                    print(f"    改进幅度: +{gap:.1f}%")
        
        print(f"\n🚀 第一阶段实施建议:")
        print(f"  1. 优先完善核心编译器模块测试 (词法、语法、语义、类型)")
        print(f"  2. 加强错误处理系统测试覆盖")
        print(f"  3. 扩展诗词编程特色功能测试")
        print(f"  4. 建立端到端集成测试套件")

def main():
    analyzer = TestCoverageAnalyzer(os.getcwd())
    results = analyzer.generate_coverage_report()
    
    # 保存结果到文件
    output_file = "doc/analysis/测试覆盖率分析结果_Fix_732.json"
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 详细结果已保存至: {output_file}")

if __name__ == "__main__":
    main()