#!/usr/bin/env python3
"""
Poetry模块依赖分析工具
===
Author: Whisky, PR Worker

功能:
- 分析201个Poetry模块的完整依赖关系
- 生成模块依赖图和关系矩阵
- 识别低风险、中风险、高风险整合模块
- 创建依赖关系可视化数据

技术实现:
- 解析OCaml源码中的'open'语句和模块引用
- 构建有向依赖图
- 检测循环依赖
- 计算模块内聚性和耦合度
"""

import os
import re
import json
import sys
from collections import defaultdict, deque
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
import networkx as nx


class PoetryDependencyAnalyzer:
    """Poetry模块依赖分析器"""
    
    def __init__(self, poetry_root: str):
        self.poetry_root = Path(poetry_root)
        self.modules = {}  # module_name -> ModuleInfo
        self.dependencies = defaultdict(set)  # module -> set of dependencies
        self.reverse_dependencies = defaultdict(set)  # module -> set of dependents
        
    def analyze(self) -> Dict:
        """执行完整的依赖分析"""
        print("🔍 开始Poetry模块依赖分析...")
        
        # 1. 发现所有模块
        self._discover_modules()
        print(f"✅ 发现 {len(self.modules)} 个模块")
        
        # 2. 解析依赖关系
        self._parse_dependencies()
        print(f"✅ 解析完成，发现 {sum(len(deps) for deps in self.dependencies.values())} 个依赖关系")
        
        # 3. 构建依赖图
        dependency_graph = self._build_dependency_graph()
        print("✅ 依赖图构建完成")
        
        # 4. 分析模块特征
        module_analysis = self._analyze_modules(dependency_graph)
        print("✅ 模块特征分析完成")
        
        # 5. 检测循环依赖
        cycles = self._detect_cycles(dependency_graph)
        print(f"⚠️  发现 {len(cycles)} 个循环依赖")
        
        # 6. 风险分类
        risk_classification = self._classify_integration_risk(module_analysis, cycles)
        print("✅ 整合风险分类完成")
        
        return {
            'modules': self.modules,
            'dependencies': {k: list(v) for k, v in self.dependencies.items()},
            'reverse_dependencies': {k: list(v) for k, v in self.reverse_dependencies.items()},
            'module_analysis': module_analysis,
            'cycles': cycles,
            'risk_classification': risk_classification,
            'statistics': self._generate_statistics()
        }
    
    def _discover_modules(self):
        """发现所有Poetry模块"""
        for ml_file in self.poetry_root.rglob("*.ml"):
            if ml_file.is_file():
                module_name = self._get_module_name(ml_file)
                self.modules[module_name] = {
                    'path': str(ml_file),
                    'relative_path': str(ml_file.relative_to(self.poetry_root)),
                    'directory': str(ml_file.parent.relative_to(self.poetry_root)),
                    'size': ml_file.stat().st_size,
                    'lines': self._count_lines(ml_file)
                }
    
    def _get_module_name(self, ml_file: Path) -> str:
        """从文件路径提取模块名"""
        relative_path = ml_file.relative_to(self.poetry_root)
        # 移除.ml扩展名并替换路径分隔符
        module_name = str(relative_path).replace('.ml', '').replace('/', '.')
        return module_name
    
    def _count_lines(self, file_path: Path) -> int:
        """计算文件行数"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                return sum(1 for _ in f)
        except:
            return 0
    
    def _parse_dependencies(self):
        """解析所有模块的依赖关系"""
        for module_name, module_info in self.modules.items():
            deps = self._extract_dependencies(module_info['path'])
            self.dependencies[module_name] = deps
            
            # 构建反向依赖
            for dep in deps:
                self.reverse_dependencies[dep].add(module_name)
    
    def _extract_dependencies(self, file_path: str) -> Set[str]:
        """从OCaml文件中提取依赖关系"""
        dependencies = set()
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
            # 匹配open语句
            open_pattern = r'open\s+([A-Z][a-zA-Z0-9_]*(?:\.[A-Z][a-zA-Z0-9_]*)*)'
            for match in re.finditer(open_pattern, content):
                dep_module = match.group(1)
                # 将模块名转换为我们的命名约定
                normalized_dep = self._normalize_module_name(dep_module)
                if normalized_dep in self.modules:
                    dependencies.add(normalized_dep)
            
            # 匹配模块引用 (如 Module.function)
            module_ref_pattern = r'([A-Z][a-zA-Z0-9_]*)\.[a-z][a-zA-Z0-9_]*'
            for match in re.finditer(module_ref_pattern, content):
                dep_module = match.group(1)
                normalized_dep = self._normalize_module_name(dep_module)
                if normalized_dep in self.modules:
                    dependencies.add(normalized_dep)
                    
        except Exception as e:
            print(f"⚠️  解析 {file_path} 时出错: {e}")
            
        return dependencies
    
    def _normalize_module_name(self, module_name: str) -> str:
        """标准化模块名称"""
        # 将驼峰命名转换为下划线命名，然后查找匹配的模块
        snake_case = re.sub(r'([A-Z])', r'_\1', module_name).lower().lstrip('_')
        
        # 尝试在现有模块中查找匹配项
        for existing_module in self.modules:
            if existing_module.endswith(snake_case) or snake_case in existing_module:
                return existing_module
                
        return snake_case
    
    def _build_dependency_graph(self) -> nx.DiGraph:
        """构建NetworkX依赖图"""
        G = nx.DiGraph()
        
        # 添加节点
        for module in self.modules:
            G.add_node(module)
            
        # 添加边
        for module, deps in self.dependencies.items():
            for dep in deps:
                if dep in self.modules:  # 确保依赖模块存在
                    G.add_edge(module, dep)
                    
        return G
    
    def _analyze_modules(self, graph: nx.DiGraph) -> Dict:
        """分析模块特征"""
        analysis = {}
        
        for module in self.modules:
            in_degree = graph.in_degree(module)  # 被多少模块依赖
            out_degree = graph.out_degree(module)  # 依赖多少模块
            
            analysis[module] = {
                'in_degree': in_degree,
                'out_degree': out_degree,
                'coupling': out_degree,  # 耦合度
                'cohesion_potential': in_degree,  # 内聚潜力
                'centrality': nx.betweenness_centrality(graph).get(module, 0),
                'clustering': nx.clustering(graph.to_undirected()).get(module, 0)
            }
            
        return analysis
    
    def _detect_cycles(self, graph: nx.DiGraph) -> List[List[str]]:
        """检测循环依赖"""
        try:
            cycles = list(nx.simple_cycles(graph))
            return cycles
        except:
            return []
    
    def _classify_integration_risk(self, module_analysis: Dict, cycles: List) -> Dict:
        """分类整合风险"""
        risk_classification = {
            'low_risk': [],      # 低风险：低耦合，少依赖
            'medium_risk': [],   # 中风险：中等耦合或有一些复杂性
            'high_risk': [],     # 高风险：高耦合，循环依赖，核心模块
            'consolidation_candidates': []  # 整合候选：相似功能模块
        }
        
        # 获取循环依赖中的所有模块
        cyclic_modules = set()
        for cycle in cycles:
            cyclic_modules.update(cycle)
        
        for module, analysis in module_analysis.items():
            risk_score = 0
            
            # 基于耦合度评分
            if analysis['coupling'] > 10:
                risk_score += 3
            elif analysis['coupling'] > 5:
                risk_score += 2
            elif analysis['coupling'] > 2:
                risk_score += 1
                
            # 基于被依赖程度评分
            if analysis['in_degree'] > 10:
                risk_score += 3
            elif analysis['in_degree'] > 5:
                risk_score += 2
            elif analysis['in_degree'] > 2:
                risk_score += 1
                
            # 循环依赖加分
            if module in cyclic_modules:
                risk_score += 2
                
            # 中心性评分
            if analysis['centrality'] > 0.1:
                risk_score += 2
            elif analysis['centrality'] > 0.05:
                risk_score += 1
            
            # 分类
            if risk_score >= 6:
                risk_classification['high_risk'].append({
                    'module': module,
                    'score': risk_score,
                    'reasons': self._get_risk_reasons(module, analysis, cyclic_modules)
                })
            elif risk_score >= 3:
                risk_classification['medium_risk'].append({
                    'module': module,
                    'score': risk_score,
                    'reasons': self._get_risk_reasons(module, analysis, cyclic_modules)
                })
            else:
                risk_classification['low_risk'].append({
                    'module': module,
                    'score': risk_score,
                    'reasons': self._get_risk_reasons(module, analysis, cyclic_modules)
                })
        
        # 识别整合候选
        self._identify_consolidation_candidates(risk_classification)
        
        return risk_classification
    
    def _get_risk_reasons(self, module: str, analysis: Dict, cyclic_modules: Set) -> List[str]:
        """获取风险原因"""
        reasons = []
        
        if analysis['coupling'] > 10:
            reasons.append(f"高耦合度({analysis['coupling']}个依赖)")
        if analysis['in_degree'] > 10:
            reasons.append(f"被大量模块依赖({analysis['in_degree']}个)")
        if module in cyclic_modules:
            reasons.append("存在循环依赖")
        if analysis['centrality'] > 0.1:
            reasons.append("高中心性模块")
            
        return reasons
    
    def _identify_consolidation_candidates(self, risk_classification: Dict):
        """识别整合候选模块"""
        # 按目录分组，寻找相似功能的模块
        directory_groups = defaultdict(list)
        
        for module in self.modules:
            directory = self.modules[module]['directory']
            directory_groups[directory].append(module)
        
        # 在每个目录中寻找低风险模块作为整合候选
        for directory, modules in directory_groups.items():
            if len(modules) > 1:  # 至少有2个模块才考虑整合
                low_risk_in_dir = []
                for risk_category in ['low_risk', 'medium_risk']:
                    for item in risk_classification[risk_category]:
                        if item['module'] in modules:
                            low_risk_in_dir.append(item['module'])
                
                if len(low_risk_in_dir) >= 2:
                    risk_classification['consolidation_candidates'].append({
                        'directory': directory,
                        'modules': low_risk_in_dir,
                        'count': len(low_risk_in_dir),
                        'consolidation_potential': 'high' if len(low_risk_in_dir) > 3 else 'medium'
                    })
    
    def _generate_statistics(self) -> Dict:
        """生成统计信息"""
        total_modules = len(self.modules)
        total_dependencies = sum(len(deps) for deps in self.dependencies.values())
        
        return {
            'total_modules': total_modules,
            'total_dependencies': total_dependencies,
            'average_dependencies_per_module': total_dependencies / total_modules if total_modules > 0 else 0,
            'modules_by_directory': self._count_by_directory(),
            'largest_modules': self._get_largest_modules(),
            'most_coupled_modules': self._get_most_coupled_modules()
        }
    
    def _count_by_directory(self) -> Dict[str, int]:
        """按目录统计模块数量"""
        counts = defaultdict(int)
        for module_info in self.modules.values():
            counts[module_info['directory']] += 1
        return dict(counts)
    
    def _get_largest_modules(self) -> List[Dict]:
        """获取最大的模块"""
        modules_by_size = sorted(
            [(name, info) for name, info in self.modules.items()],
            key=lambda x: x[1]['lines'],
            reverse=True
        )
        return [
            {'module': name, 'lines': info['lines'], 'size': info['size']}
            for name, info in modules_by_size[:10]
        ]
    
    def _get_most_coupled_modules(self) -> List[Dict]:
        """获取耦合度最高的模块"""
        coupled_modules = sorted(
            [(module, len(deps)) for module, deps in self.dependencies.items()],
            key=lambda x: x[1],
            reverse=True
        )
        return [
            {'module': module, 'dependencies': dep_count}
            for module, dep_count in coupled_modules[:10]
        ]


def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("用法: python dependency_analyzer.py <poetry_root_path>")
        sys.exit(1)
    
    poetry_root = sys.argv[1]
    if not os.path.exists(poetry_root):
        print(f"错误: 路径 {poetry_root} 不存在")
        sys.exit(1)
    
    # 执行分析
    analyzer = PoetryDependencyAnalyzer(poetry_root)
    results = analyzer.analyze()
    
    # 保存结果
    output_file = 'poetry_dependency_analysis.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"✅ 分析完成！结果已保存到 {output_file}")
    
    # 输出简要统计
    stats = results['statistics']
    print("\n📊 简要统计:")
    print(f"  总模块数: {stats['total_modules']}")
    print(f"  总依赖关系数: {stats['total_dependencies']}")
    print(f"  平均每模块依赖数: {stats['average_dependencies_per_module']:.2f}")
    
    risk = results['risk_classification']
    print(f"\n🎯 风险分类:")
    print(f"  低风险模块: {len(risk['low_risk'])}个")
    print(f"  中风险模块: {len(risk['medium_risk'])}个")
    print(f"  高风险模块: {len(risk['high_risk'])}个")
    print(f"  整合候选组: {len(risk['consolidation_candidates'])}组")
    
    if results['cycles']:
        print(f"\n⚠️  循环依赖: {len(results['cycles'])}个")


if __name__ == '__main__':
    main()