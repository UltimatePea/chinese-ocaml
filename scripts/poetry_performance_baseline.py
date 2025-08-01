#!/usr/bin/env python3
"""
Poetry模块性能基准测试框架
Author: Papa, Project Planner
Date: 2025年8月1日

建立Poetry模块的性能基准，为后续优化提供量化指标。
"""

import os
import time
import json
import subprocess
from datetime import datetime
from pathlib import Path

class PoetryPerformanceBaseline:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.poetry_dir = self.project_root / "src" / "poetry"
        self.results = {}
        
    def count_poetry_files(self):
        """统计Poetry模块文件数量"""
        ml_files = list(self.poetry_dir.rglob("*.ml"))
        mli_files = list(self.poetry_dir.rglob("*.mli"))
        
        return {
            "total_ml_files": len(ml_files),
            "total_mli_files": len(mli_files),
            "total_files": len(ml_files) + len(mli_files),
            "ml_files": [str(f.relative_to(self.project_root)) for f in ml_files],
            "mli_files": [str(f.relative_to(self.project_root)) for f in mli_files]
        }
    
    def analyze_file_categories(self):
        """分析文件类别分布"""
        ml_files = list(self.poetry_dir.rglob("*.ml"))
        
        categories = {
            "rhyme": [],
            "artistic": [],
            "data": [],
            "cache": [],
            "evaluation": [],
            "core": [],
            "other": []
        }
        
        for file in ml_files:
            file_name = file.name.lower()
            file_path = str(file.relative_to(self.project_root))
            
            if "rhyme" in file_name:
                categories["rhyme"].append(file_path)
            elif "artistic" in file_name:
                categories["artistic"].append(file_path)
            elif "data" in file_name:
                categories["data"].append(file_path)
            elif "cache" in file_name:
                categories["cache"].append(file_path)
            elif "evaluat" in file_name:
                categories["evaluation"].append(file_path)
            elif "core" in file_name:
                categories["core"].append(file_path)
            else:
                categories["other"].append(file_path)
        
        # 计算每个类别的统计信息
        category_stats = {}
        for category, files in categories.items():
            category_stats[category] = {
                "count": len(files),
                "files": files,
                "percentage": round(len(files) / len(ml_files) * 100, 2) if ml_files else 0
            }
        
        return category_stats
    
    def measure_compilation_time(self):
        """测量编译时间"""
        print("📊 开始编译性能测试...")
        
        # 先清理编译产物
        subprocess.run(["dune", "clean"], cwd=self.project_root, capture_output=True)
        
        # 测量完整编译时间
        start_time = time.time()
        result = subprocess.run(
            ["dune", "build"], 
            cwd=self.project_root, 
            capture_output=True, 
            text=True
        )
        end_time = time.time()
        
        compilation_time = end_time - start_time
        
        return {
            "compilation_time_seconds": round(compilation_time, 2),
            "compilation_success": result.returncode == 0,
            "compilation_output": result.stdout if result.returncode == 0 else result.stderr
        }
    
    def analyze_code_complexity(self):
        """分析代码复杂度"""
        ml_files = list(self.poetry_dir.rglob("*.ml"))
        
        total_lines = 0
        file_sizes = []
        
        for file in ml_files:
            try:
                with open(file, 'r', encoding='utf-8') as f:
                    lines = len(f.readlines())
                    total_lines += lines
                    file_sizes.append({
                        "file": str(file.relative_to(self.project_root)),
                        "lines": lines
                    })
            except Exception as e:
                print(f"⚠️  无法读取文件 {file}: {e}")
        
        # 按行数排序，找出最大的文件
        file_sizes.sort(key=lambda x: x["lines"], reverse=True)
        
        return {
            "total_lines": total_lines,
            "average_lines_per_file": round(total_lines / len(ml_files), 2) if ml_files else 0,
            "largest_files": file_sizes[:10],  # 前10个最大的文件
            "total_files_analyzed": len(ml_files)
        }
    
    def identify_duplicate_patterns(self):
        """识别可能的重复模式"""
        ml_files = list(self.poetry_dir.rglob("*.ml"))
        
        # 简单的重复模式识别：统计相似的文件名
        name_patterns = {}
        
        for file in ml_files:
            name = file.name
            # 提取基础名称模式
            base_patterns = []
            
            if "rhyme" in name:
                base_patterns.append("rhyme")
            if "artistic" in name:
                base_patterns.append("artistic")
            if "data" in name:
                base_patterns.append("data")
            if "loader" in name:
                base_patterns.append("loader")
            if "engine" in name:
                base_patterns.append("engine")
            if "core" in name:
                base_patterns.append("core")
            if "unified" in name:
                base_patterns.append("unified")
            
            for pattern in base_patterns:
                if pattern not in name_patterns:
                    name_patterns[pattern] = []
                name_patterns[pattern].append(str(file.relative_to(self.project_root)))
        
        # 识别潜在的重复文件组
        potential_duplicates = {}
        for pattern, files in name_patterns.items():
            if len(files) > 5:  # 超过5个文件使用相同模式，可能存在重复
                potential_duplicates[pattern] = {
                    "count": len(files),
                    "files": files,
                    "optimization_potential": "high" if len(files) > 10 else "medium"
                }
        
        return potential_duplicates
    
    def run_baseline_analysis(self):
        """运行完整的基准分析"""
        print("🚀 开始Poetry模块性能基准分析...")
        print(f"📁 项目路径: {self.project_root}")
        print(f"🎭 Poetry模块路径: {self.poetry_dir}")
        print()
        
        # 文件统计
        print("📊 1. 文件数量统计...")
        file_stats = self.count_poetry_files()
        self.results["file_statistics"] = file_stats
        print(f"   OCaml源文件: {file_stats['total_ml_files']}")
        print(f"   接口文件: {file_stats['total_mli_files']}")
        print(f"   总文件数: {file_stats['total_files']}")
        print()
        
        # 文件类别分析
        print("🏷️  2. 文件类别分析...")
        category_stats = self.analyze_file_categories()
        self.results["category_analysis"] = category_stats
        for category, stats in category_stats.items():
            if stats["count"] > 0:
                print(f"   {category}: {stats['count']} 文件 ({stats['percentage']}%)")
        print()
        
        # 编译性能测试
        print("⚡ 3. 编译性能测试...")
        compilation_stats = self.measure_compilation_time()
        self.results["compilation_performance"] = compilation_stats
        print(f"   编译时间: {compilation_stats['compilation_time_seconds']} 秒")
        print(f"   编译状态: {'✅ 成功' if compilation_stats['compilation_success'] else '❌ 失败'}")
        print()
        
        # 代码复杂度分析
        print("🔍 4. 代码复杂度分析...")
        complexity_stats = self.analyze_code_complexity()
        self.results["code_complexity"] = complexity_stats
        print(f"   总代码行数: {complexity_stats['total_lines']}")
        print(f"   平均每文件行数: {complexity_stats['average_lines_per_file']}")
        print(f"   最大文件: {complexity_stats['largest_files'][0]['file']} ({complexity_stats['largest_files'][0]['lines']} 行)")
        print()
        
        # 重复模式识别
        print("🔄 5. 重复模式识别...")
        duplicate_patterns = self.identify_duplicate_patterns()
        self.results["duplication_analysis"] = duplicate_patterns
        
        total_optimization_files = 0
        for pattern, stats in duplicate_patterns.items():
            print(f"   {pattern} 模式: {stats['count']} 文件 (优化潜力: {stats['optimization_potential']})")
            total_optimization_files += stats['count']
        
        optimization_percentage = round(total_optimization_files / file_stats['total_ml_files'] * 100, 2)
        print(f"   📈 总优化潜力: {total_optimization_files} 文件 ({optimization_percentage}%)")
        print()
        
        # 保存结果
        self.save_results()
        
        # 生成总结报告
        self.generate_summary_report()
        
        return self.results
    
    def save_results(self):
        """保存分析结果到JSON文件"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = self.project_root / f"poetry_performance_baseline_{timestamp}.json"
        
        result_data = {
            "timestamp": datetime.now().isoformat(),
            "analysis_type": "Poetry模块性能基准",
            "author": "Papa, Project Planner",
            "results": self.results
        }
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(result_data, f, indent=2, ensure_ascii=False)
        
        print(f"💾 结果已保存到: {output_file}")
        return output_file
    
    def generate_summary_report(self):
        """生成总结报告"""
        print("\n" + "="*60)
        print("📋 Papa战略分析 - Poetry模块性能基准总结")
        print("="*60)
        
        file_stats = self.results["file_statistics"]
        category_stats = self.results["category_analysis"]
        compilation_stats = self.results["compilation_performance"]
        duplicate_patterns = self.results["duplication_analysis"]
        
        print(f"🎯 当前状态:")
        print(f"   • Poetry模块总数: {file_stats['total_ml_files']} 个")
        print(f"   • 编译时间: {compilation_stats['compilation_time_seconds']} 秒")
        print(f"   • 编译状态: {'✅ 稳定' if compilation_stats['compilation_success'] else '❌ 有问题'}")
        
        print(f"\n🔍 优化机会:")
        rhyme_files = category_stats.get("rhyme", {}).get("count", 0)
        artistic_files = category_stats.get("artistic", {}).get("count", 0)
        data_files = category_stats.get("data", {}).get("count", 0)
        
        print(f"   • 韵律模块: {rhyme_files} 个文件 (整合潜力: 高)")
        print(f"   • 艺术评估: {artistic_files} 个文件 (整合潜力: 中)")
        print(f"   • 数据加载: {data_files} 个文件 (整合潜力: 中)")
        
        total_optimization_potential = 0
        for pattern, stats in duplicate_patterns.items():
            if stats["optimization_potential"] == "high":
                total_optimization_potential += stats["count"]
        
        optimization_percentage = round(total_optimization_potential / file_stats['total_ml_files'] * 100, 2)
        print(f"   • 总体优化潜力: {total_optimization_potential} 文件 ({optimization_percentage}%)")
        
        print(f"\n📈 Papa建议的实施目标:")
        target_files = file_stats['total_ml_files'] - min(total_optimization_potential, 34)
        reduction_percentage = round((file_stats['total_ml_files'] - target_files) / file_stats['total_ml_files'] * 100, 2)
        print(f"   • 目标文件数: {target_files} 个")
        print(f"   • 减少幅度: {file_stats['total_ml_files'] - target_files} 个 ({reduction_percentage}%)")
        print(f"   • 预期编译改善: 10-15%")
        
        print(f"\n🚀 实施建议:")
        print(f"   1. 优先整合韵律相关模块 ({rhyme_files} 个文件)")
        print(f"   2. 统一艺术评估接口 ({artistic_files} 个文件)")
        print(f"   3. 简化数据加载架构 ({data_files} 个文件)")
        print(f"   4. 建立性能监控机制")
        
        print("\n💡 Papa战略规划师分析完成！")
        print("="*60)


def main():
    """主函数"""
    import sys
    
    # 获取项目根目录
    if len(sys.argv) > 1:
        project_root = sys.argv[1]
    else:
        project_root = os.getcwd()
    
    # 创建分析器实例
    analyzer = PoetryPerformanceBaseline(project_root)
    
    # 运行基准分析
    try:
        results = analyzer.run_baseline_analysis()
        print("\n✅ Poetry模块性能基准分析完成！")
        return 0
    except Exception as e:
        print(f"\n❌ 分析过程中出现错误: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit(main())