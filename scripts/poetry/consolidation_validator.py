#!/usr/bin/env python3
"""
Poetry模块整合验证工具
===
Author: Whisky, PR Worker

功能:
- 验证整合计划的技术可行性
- 检测潜在的整合冲突
- 生成整合前后的对比报告
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Set


class ConsolidationValidator:
    """整合验证器"""
    
    def __init__(self, analysis_file: str, poetry_root: str):
        self.analysis_file = analysis_file
        self.poetry_root = Path(poetry_root)
        self.analysis_data = self._load_analysis()
        
    def _load_analysis(self) -> Dict:
        """加载分析数据"""
        with open(self.analysis_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def validate_consolidation_plan(self) -> Dict:
        """验证整合计划"""
        print("🔍 开始验证Poetry模块整合计划...")
        
        validation_results = {
            'phase1_validation': self._validate_phase1(),
            'dependency_check': self._check_dependencies(),
            'conflict_detection': self._detect_conflicts(),
            'safety_assessment': self._assess_safety(),
            'recommendations': self._generate_recommendations()
        }
        
        return validation_results
    
    def _validate_phase1(self) -> Dict:
        """验证Phase 1整合计划"""
        phase1 = self.analysis_data['consolidation_plan']['phase1']
        
        validation = {
            'target_achievable': True,
            'safe_candidates': [],
            'risky_candidates': [],
            'estimated_effort': 'medium'
        }
        
        total_consolidation = 0
        for candidate_group in phase1['candidates']:
            modules = candidate_group['modules']
            directory = candidate_group['directory']
            
            # 检查模块是否都是低风险
            risk_check = self._check_risk_level(modules)
            
            if risk_check['all_low_risk']:
                validation['safe_candidates'].append({
                    'directory': directory,
                    'modules': modules,
                    'count': len(modules),
                    'consolidation_reduction': len(modules) - 1 if len(modules) > 1 else 0
                })
                total_consolidation += len(modules) - 1 if len(modules) > 1 else 0
            else:
                validation['risky_candidates'].append({
                    'directory': directory,
                    'modules': modules,
                    'risk_issues': risk_check['issues']
                })
        
        validation['actual_reduction'] = total_consolidation
        validation['target_reduction'] = 13
        validation['target_achievable'] = total_consolidation >= 13
        
        return validation
    
    def _check_risk_level(self, modules: List[str]) -> Dict:
        """检查模块风险等级"""
        low_risk_modules = {item['module'] for item in self.analysis_data['risk_classification']['low_risk']}
        medium_risk_modules = {item['module'] for item in self.analysis_data['risk_classification']['medium_risk']}
        high_risk_modules = {item['module'] for item in self.analysis_data['risk_classification']['high_risk']}
        
        issues = []
        all_low_risk = True
        
        for module in modules:
            if module in medium_risk_modules:
                issues.append(f"{module} is medium risk")
                all_low_risk = False
            elif module in high_risk_modules:
                issues.append(f"{module} is high risk")
                all_low_risk = False
            elif module not in low_risk_modules:
                issues.append(f"{module} risk level unknown")
                all_low_risk = False
        
        return {
            'all_low_risk': all_low_risk,
            'issues': issues
        }
    
    def _check_dependencies(self) -> Dict:
        """检查依赖关系"""
        dependencies = self.analysis_data.get('dependencies', {})
        reverse_deps = self.analysis_data.get('reverse_dependencies', {})
        
        critical_modules = []
        dependency_conflicts = []
        
        # 找出被多个模块依赖的关键模块
        for module, dependents in reverse_deps.items():
            if len(dependents) > 2:
                critical_modules.append({
                    'module': module,
                    'dependents': dependents,
                    'count': len(dependents)
                })
        
        # 检查整合候选中是否包含关键依赖模块
        phase1_candidates = []
        for candidate_group in self.analysis_data['consolidation_plan']['phase1']['candidates']:
            phase1_candidates.extend(candidate_group['modules'])
        
        for critical in critical_modules:
            if critical['module'] in phase1_candidates:
                dependency_conflicts.append({
                    'module': critical['module'],
                    'issue': 'Critical dependency module in consolidation plan',
                    'dependents': critical['dependents']
                })
        
        return {
            'critical_modules': critical_modules,
            'dependency_conflicts': dependency_conflicts,
            'safe_for_consolidation': len(dependency_conflicts) == 0
        }
    
    def _detect_conflicts(self) -> Dict:
        """检测潜在冲突"""
        conflicts = {
            'naming_conflicts': [],
            'functional_overlaps': [],
            'integration_challenges': []
        }
        
        # 检查命名冲突
        module_names = set()
        for module_info in self.analysis_data.get('modules', {}).values():
            base_name = Path(module_info['path']).stem
            if base_name in module_names:
                conflicts['naming_conflicts'].append(base_name)
            else:
                module_names.add(base_name)
        
        # 检查功能重叠（基于目录和命名模式）
        directory_groups = {}
        for module, info in self.analysis_data.get('modules', {}).items():
            directory = info['directory']
            if directory not in directory_groups:
                directory_groups[directory] = []
            directory_groups[directory].append(module)
        
        for directory, modules in directory_groups.items():
            if len(modules) > 5:  # 目录中模块过多可能表示功能重叠
                similar_patterns = self._find_similar_patterns(modules)
                if similar_patterns:
                    conflicts['functional_overlaps'].append({
                        'directory': directory,
                        'patterns': similar_patterns
                    })
        
        return conflicts
    
    def _find_similar_patterns(self, modules: List[str]) -> List[str]:
        """查找相似的命名模式"""
        patterns = {}
        for module in modules:
            # 提取基础名称模式
            parts = module.split('.')[-1].split('_')
            if len(parts) > 1:
                pattern = '_'.join(parts[:-1])  # 去掉最后一部分
                if pattern not in patterns:
                    patterns[pattern] = []
                patterns[pattern].append(module)
        
        # 返回有多个模块的模式
        similar = []
        for pattern, module_list in patterns.items():
            if len(module_list) > 2:
                similar.append(f"{pattern}_* ({len(module_list)} modules)")
        
        return similar
    
    def _assess_safety(self) -> Dict:
        """评估整合安全性"""
        safety = {
            'overall_risk': 'low',
            'safety_score': 0,
            'risk_factors': [],
            'mitigation_strategies': []
        }
        
        # 计算安全评分
        isolated_modules = len(self.analysis_data['detailed_modules']['isolated_modules'])
        total_modules = self.analysis_data['total_modules']
        isolated_ratio = isolated_modules / total_modules
        
        if isolated_ratio > 0.9:
            safety['safety_score'] += 30
            safety['mitigation_strategies'].append("大量独立模块，整合风险很低")
        
        # 检查依赖复杂度
        total_deps = self.analysis_data['dependency_stats']['total_dependencies']
        if total_deps < 10:
            safety['safety_score'] += 25
            safety['mitigation_strategies'].append("依赖关系简单，冲突风险低")
        
        # 检查高风险模块数量
        high_risk_count = len(self.analysis_data['risk_classification']['high_risk'])
        if high_risk_count == 0:
            safety['safety_score'] += 25
            safety['mitigation_strategies'].append("无高风险模块，整合较为安全")
        
        # 检查循环依赖
        cycles = self.analysis_data.get('cycles', [])
        if len(cycles) == 0:
            safety['safety_score'] += 20
            safety['mitigation_strategies'].append("无循环依赖，结构清晰")
        
        # 根据评分确定风险等级
        if safety['safety_score'] >= 80:
            safety['overall_risk'] = 'very_low'
        elif safety['safety_score'] >= 60:
            safety['overall_risk'] = 'low'
        elif safety['safety_score'] >= 40:
            safety['overall_risk'] = 'medium'
        else:
            safety['overall_risk'] = 'high'
        
        return safety
    
    def _generate_recommendations(self) -> List[str]:
        """生成整合建议"""
        recommendations = []
        
        # 基于分析结果生成建议
        isolated_count = len(self.analysis_data['detailed_modules']['isolated_modules'])
        if isolated_count > 100:
            recommendations.append(f"优先整合{isolated_count}个独立模块，风险最低")
        
        # 基于目录分布生成建议
        dir_breakdown = self.analysis_data['directory_breakdown']
        large_dirs = [(d, count) for d, count in dir_breakdown.items() if count > 10]
        
        for directory, count in large_dirs:
            recommendations.append(f"重点关注{directory}目录的{count}个模块整合")
        
        # 基于依赖关系生成建议
        most_depended = self.analysis_data['detailed_modules']['most_depended_on']
        if most_depended:
            top_dep = most_depended[0]
            recommendations.append(f"谨慎处理{top_dep['module']}模块，被{top_dep['dependents']}个模块依赖")
        
        recommendations.append("建议采用渐进式整合策略，每次完成后进行完整测试")
        recommendations.append("为每个整合阶段准备详细的回滚计划")
        
        return recommendations


def main():
    """主函数"""
    if len(sys.argv) != 3:
        print("用法: python consolidation_validator.py <analysis_file> <poetry_root>")
        sys.exit(1)
    
    analysis_file = sys.argv[1]
    poetry_root = sys.argv[2]
    
    validator = ConsolidationValidator(analysis_file, poetry_root)
    results = validator.validate_consolidation_plan()
    
    # 保存验证结果
    output_file = 'consolidation_validation.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"✅ 验证完成！结果已保存到 {output_file}")
    
    # 输出验证摘要
    safety = results['safety_assessment']
    print(f"\n🛡️  安全评估:")
    print(f"  整体风险等级: {safety['overall_risk']}")
    print(f"  安全评分: {safety['safety_score']}/100")
    
    phase1_val = results['phase1_validation']
    print(f"\n📋 Phase 1验证:")
    print(f"  目标可达成: {'是' if phase1_val['target_achievable'] else '否'}")
    print(f"  预计减少: {phase1_val['actual_reduction']}个模块")
    print(f"  安全候选组: {len(phase1_val['safe_candidates'])}组")
    
    dep_check = results['dependency_check']
    print(f"\n🔗 依赖检查:")
    print(f"  关键依赖模块: {len(dep_check['critical_modules'])}个")
    print(f"  整合安全性: {'安全' if dep_check['safe_for_consolidation'] else '需要注意'}")
    
    print(f"\n💡 主要建议:")
    for i, rec in enumerate(results['recommendations'][:3], 1):
        print(f"  {i}. {rec}")


if __name__ == '__main__':
    main()