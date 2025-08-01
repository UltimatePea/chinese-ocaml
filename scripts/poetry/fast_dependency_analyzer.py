#!/usr/bin/env python3
"""
Poetry模块快速依赖分析工具
===
Author: Whisky, PR Worker

优化版本：专注于核心依赖分析和整合规划
"""

import os
import re
import json
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Set, Tuple


class FastPoetryAnalyzer:
    """快速Poetry依赖分析器"""
    
    def __init__(self, poetry_root: str):
        self.poetry_root = Path(poetry_root)
        self.modules = {}
        self.dependencies = defaultdict(set)
        
    def analyze(self) -> Dict:
        """执行快速依赖分析"""
        print("🚀 开始快速Poetry模块分析...")
        
        # 1. 发现模块并计算基本信息
        self._discover_modules()
        print(f"✅ 发现 {len(self.modules)} 个模块")
        
        # 2. 快速解析依赖关系
        self._parse_dependencies_fast()
        total_deps = sum(len(deps) for deps in self.dependencies.values())
        print(f"✅ 解析完成，发现 {total_deps} 个依赖关系")
        
        # 3. 分析和分类
        analysis = self._analyze_fast()
        print("✅ 分析完成")
        
        return analysis
    
    def _discover_modules(self):
        """发现所有模块"""
        for ml_file in self.poetry_root.rglob("*.ml"):
            if ml_file.is_file():
                module_name = self._get_module_name(ml_file)
                rel_path = ml_file.relative_to(self.poetry_root)
                self.modules[module_name] = {
                    'path': str(ml_file),
                    'relative_path': str(rel_path),
                    'directory': str(ml_file.parent.relative_to(self.poetry_root)),
                    'size': ml_file.stat().st_size,
                    'name_only': ml_file.stem
                }
    
    def _get_module_name(self, ml_file: Path) -> str:
        """从文件路径提取模块名"""
        relative_path = ml_file.relative_to(self.poetry_root)
        return str(relative_path).replace('.ml', '').replace('/', '.')
    
    def _parse_dependencies_fast(self):
        """快速解析依赖关系"""
        # 创建模块名称查找映射
        name_to_module = {}
        for module_name, info in self.modules.items():
            name_only = info['name_only']
            name_to_module[name_only] = module_name
            # 添加驼峰命名版本
            camel_case = self._to_camel_case(name_only)
            name_to_module[camel_case] = module_name
        
        for module_name, module_info in self.modules.items():
            deps = self._extract_dependencies_fast(module_info['path'], name_to_module)
            self.dependencies[module_name] = deps
    
    def _to_camel_case(self, snake_str: str) -> str:
        """下划线转驼峰"""
        components = snake_str.split('_')
        return ''.join(word.capitalize() for word in components)
    
    def _extract_dependencies_fast(self, file_path: str, name_mapping: Dict) -> Set[str]:
        """快速提取依赖关系"""
        dependencies = set()
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # 匹配open语句
            open_matches = re.findall(r'open\s+([A-Z][a-zA-Z0-9_]*)', content)
            for match in open_matches:
                if match in name_mapping:
                    dependencies.add(name_mapping[match])
            
            # 匹配模块引用
            ref_matches = re.findall(r'([A-Z][a-zA-Z0-9_]*)\.[a-z]', content)
            for match in ref_matches:
                if match in name_mapping:
                    dependencies.add(name_mapping[match])
                    
        except Exception as e:
            print(f"⚠️  解析 {file_path} 时出错: {e}")
            
        return dependencies
    
    def _analyze_fast(self) -> Dict:
        """快速分析"""
        # 计算依赖统计
        dep_counts = {module: len(deps) for module, deps in self.dependencies.items()}
        reverse_deps = defaultdict(int)
        
        for module, deps in self.dependencies.items():
            for dep in deps:
                reverse_deps[dep] += 1
        
        # 按目录分组
        dir_groups = defaultdict(list)
        for module, info in self.modules.items():
            dir_groups[info['directory']].append(module)
        
        # 风险分类
        risk_classification = self._classify_risk_fast(dep_counts, reverse_deps)
        
        # 整合建议
        consolidation_plan = self._create_consolidation_plan(dir_groups, risk_classification)
        
        return {
            'total_modules': len(self.modules),
            'directory_breakdown': {d: len(modules) for d, modules in dir_groups.items()},
            'dependency_stats': {
                'total_dependencies': sum(dep_counts.values()),
                'average_per_module': sum(dep_counts.values()) / len(self.modules),
                'max_dependencies': max(dep_counts.values()) if dep_counts else 0,
                'modules_with_no_deps': sum(1 for count in dep_counts.values() if count == 0)
            },
            'risk_classification': risk_classification,
            'consolidation_plan': consolidation_plan,
            'detailed_modules': self._get_detailed_analysis(dep_counts, reverse_deps)
        }
    
    def _classify_risk_fast(self, dep_counts: Dict, reverse_deps: Dict) -> Dict:
        """快速风险分类"""
        classification = {'low_risk': [], 'medium_risk': [], 'high_risk': []}
        
        for module in self.modules:
            out_deps = dep_counts.get(module, 0)
            in_deps = reverse_deps.get(module, 0)
            
            risk_score = 0
            if out_deps > 5: risk_score += 2
            elif out_deps > 2: risk_score += 1
            if in_deps > 5: risk_score += 2
            elif in_deps > 2: risk_score += 1
            
            if risk_score >= 3:
                classification['high_risk'].append({
                    'module': module,
                    'out_deps': out_deps,
                    'in_deps': in_deps,
                    'directory': self.modules[module]['directory']
                })
            elif risk_score >= 1:
                classification['medium_risk'].append({
                    'module': module,
                    'out_deps': out_deps,
                    'in_deps': in_deps,
                    'directory': self.modules[module]['directory']
                })
            else:
                classification['low_risk'].append({
                    'module': module,
                    'out_deps': out_deps,
                    'in_deps': in_deps,
                    'directory': self.modules[module]['directory']
                })
        
        return classification
    
    def _create_consolidation_plan(self, dir_groups: Dict, risk_classification: Dict) -> Dict:
        """创建整合规划"""
        plan = {
            'phase1': {'target': '201→188', 'candidates': []},
            'phase2': {'target': '188→175', 'candidates': []},
            'phase3': {'target': '175→150', 'candidates': []}
        }
        
        # Phase 1: 整合低风险、小文件模块 (13个模块)
        low_risk_by_dir = defaultdict(list)
        for item in risk_classification['low_risk']:
            low_risk_by_dir[item['directory']].append(item['module'])
        
        consolidation_count = 0
        for directory, modules in low_risk_by_dir.items():
            if len(modules) >= 2 and consolidation_count < 13:
                remaining = min(len(modules), 13 - consolidation_count)
                plan['phase1']['candidates'].append({
                    'directory': directory,
                    'modules': modules[:remaining],
                    'count': len(modules[:remaining]),
                    'strategy': '合并功能相似的低风险模块'
                })
                consolidation_count += len(modules[:remaining]) - 1  # -1因为合并后减少的数量
        
        # Phase 2: 整合中风险模块 (13个模块)
        medium_risk_by_dir = defaultdict(list)
        for item in risk_classification['medium_risk']:
            medium_risk_by_dir[item['directory']].append(item['module'])
        
        consolidation_count = 0
        for directory, modules in medium_risk_by_dir.items():
            if len(modules) >= 2 and consolidation_count < 13:
                remaining = min(len(modules), 13 - consolidation_count)
                plan['phase2']['candidates'].append({
                    'directory': directory,
                    'modules': modules[:remaining],
                    'count': len(modules[:remaining]),
                    'strategy': '重构后合并中风险模块'
                })
                consolidation_count += len(modules[:remaining]) - 1
        
        # Phase 3: 深度重构和整合 (25个模块)
        plan['phase3']['candidates'].append({
            'strategy': '深度架构重构',
            'targets': ['大型模块拆分重组', '核心API统一', '数据层整合'],
            'estimated_reduction': 25
        })
        
        return plan
    
    def _get_detailed_analysis(self, dep_counts: Dict, reverse_deps: Dict) -> Dict:
        """获取详细分析"""
        # 最高耦合模块
        high_coupling = sorted(dep_counts.items(), key=lambda x: x[1], reverse=True)[:10]
        
        # 最被依赖模块
        high_dependents = sorted(reverse_deps.items(), key=lambda x: x[1], reverse=True)[:10]
        
        # 独立模块
        isolated = [module for module, count in dep_counts.items() 
                   if count == 0 and reverse_deps.get(module, 0) == 0]
        
        return {
            'highest_coupling': [{'module': m, 'dependencies': c} for m, c in high_coupling],
            'most_depended_on': [{'module': m, 'dependents': c} for m, c in high_dependents],
            'isolated_modules': isolated
        }


def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("用法: python fast_dependency_analyzer.py <poetry_root_path>")
        sys.exit(1)
    
    poetry_root = sys.argv[1]
    analyzer = FastPoetryAnalyzer(poetry_root)
    results = analyzer.analyze()
    
    # 保存结果
    output_file = 'poetry_fast_analysis.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"✅ 快速分析完成！结果已保存到 {output_file}")
    
    # 输出统计
    print(f"\n📊 统计结果:")
    print(f"  总模块数: {results['total_modules']}")
    print(f"  总依赖数: {results['dependency_stats']['total_dependencies']}")
    print(f"  平均依赖: {results['dependency_stats']['average_per_module']:.1f}")
    
    risk = results['risk_classification']
    print(f"\n🎯 风险分类:")
    print(f"  低风险: {len(risk['low_risk'])}个")
    print(f"  中风险: {len(risk['medium_risk'])}个") 
    print(f"  高风险: {len(risk['high_risk'])}个")
    
    print(f"\n📋 整合计划:")
    for phase, info in results['consolidation_plan'].items():
        print(f"  {phase}: {info['target']} - {len(info['candidates'])}组候选")


if __name__ == '__main__':
    main()