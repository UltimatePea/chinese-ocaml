#!/usr/bin/env python3
"""
代码重复分析工具 - 骆言项目专用
专门用于分析OCaml代码中的重复模式
"""

import os
import re
import hashlib
from collections import defaultdict, Counter
from dataclasses import dataclass
from typing import List, Dict, Set, Tuple
import json
import difflib

@dataclass
class CodeBlock:
    """代码块信息"""
    file_path: str
    start_line: int
    end_line: int
    content: str
    hash_value: str
    normalized_content: str

@dataclass
class DuplicationResult:
    """重复代码结果"""
    blocks: List[CodeBlock]
    similarity: float
    pattern_type: str
    refactor_suggestion: str

class CodeDuplicationAnalyzer:
    """代码重复分析器"""
    
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.min_block_size = 10  # 增加最小代码块行数，减少分析量
        self.similarity_threshold = 0.85  # 提高相似度阈值
        self.exact_duplicates = []
        self.similar_blocks = []
        self.max_files = 50  # 限制分析文件数量
        
    def normalize_code(self, code: str) -> str:
        """标准化代码，去除变量名、空格等差异"""
        # 去除注释
        code = re.sub(r'\(\*.*?\*\)', '', code, flags=re.DOTALL)
        # 去除空行和多余空格
        lines = [line.strip() for line in code.split('\n') if line.strip()]
        # 标准化标识符
        code = '\n'.join(lines)
        # 将变量名替换为占位符
        code = re.sub(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b', 'VAR', code)
        # 将字符串字面量替换为占位符
        code = re.sub(r'"[^"]*"', 'STRING', code)
        # 将数字替换为占位符
        code = re.sub(r'\b\d+\b', 'NUM', code)
        return code
    
    def extract_code_blocks(self, file_path: str) -> List[CodeBlock]:
        """从文件中提取代码块"""
        blocks = []
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # 滑动窗口提取代码块
            for i in range(len(lines) - self.min_block_size + 1):
                block_lines = lines[i:i + self.min_block_size]
                content = ''.join(block_lines)
                normalized = self.normalize_code(content)
                
                if normalized.strip():  # 只考虑非空代码块
                    hash_value = hashlib.md5(normalized.encode()).hexdigest()
                    block = CodeBlock(
                        file_path=file_path,
                        start_line=i + 1,
                        end_line=i + self.min_block_size,
                        content=content,
                        hash_value=hash_value,
                        normalized_content=normalized
                    )
                    blocks.append(block)
                    
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
            
        return blocks
    
    def find_exact_duplicates(self, all_blocks: List[CodeBlock]) -> List[DuplicationResult]:
        """查找完全重复的代码块"""
        hash_groups = defaultdict(list)
        
        for block in all_blocks:
            hash_groups[block.hash_value].append(block)
        
        duplicates = []
        for hash_value, blocks in hash_groups.items():
            if len(blocks) > 1:
                # 确保不是来自同一个文件的相邻块
                unique_locations = []
                for block in blocks:
                    is_unique = True
                    for existing in unique_locations:
                        if (block.file_path == existing.file_path and 
                            abs(block.start_line - existing.start_line) < self.min_block_size):
                            is_unique = False
                            break
                    if is_unique:
                        unique_locations.append(block)
                
                if len(unique_locations) > 1:
                    duplicates.append(DuplicationResult(
                        blocks=unique_locations,
                        similarity=1.0,
                        pattern_type="完全重复",
                        refactor_suggestion="提取为公共函数或模块"
                    ))
        
        return duplicates
    
    def find_similar_blocks(self, all_blocks: List[CodeBlock]) -> List[DuplicationResult]:
        """查找相似的代码块（优化版本）"""
        similar_groups = []
        processed = set()
        
        # 只分析前500个块以提高性能
        limited_blocks = all_blocks[:500]
        
        for i, block1 in enumerate(limited_blocks):
            if i in processed or len(block1.normalized_content) < 50:  # 跳过太短的块
                continue
                
            similar_blocks = [block1]
            # 只与后续50个块比较，减少复杂度
            for j in range(i+1, min(i+51, len(limited_blocks))):
                block2 = limited_blocks[j]
                if j in processed or block1.file_path == block2.file_path:
                    continue
                
                # 快速预筛选
                if abs(len(block1.normalized_content) - len(block2.normalized_content)) > 100:
                    continue
                
                # 计算相似度
                similarity = difflib.SequenceMatcher(
                    None, 
                    block1.normalized_content, 
                    block2.normalized_content
                ).ratio()
                
                if similarity >= self.similarity_threshold:
                    similar_blocks.append(block2)
                    processed.add(j)
            
            if len(similar_blocks) > 1:
                processed.add(i)
                similar_groups.append(DuplicationResult(
                    blocks=similar_blocks,
                    similarity=min(difflib.SequenceMatcher(
                        None, similar_blocks[0].normalized_content, block.normalized_content
                    ).ratio() for block in similar_blocks[1:]),
                    pattern_type="结构相似",
                    refactor_suggestion="提取通用模式，使用参数化函数"
                ))
        
        return similar_groups
    
    def analyze_pattern_types(self, duplications: List[DuplicationResult]) -> Dict[str, int]:
        """分析重复模式类型"""
        patterns = defaultdict(int)
        
        for dup in duplications:
            first_block = dup.blocks[0]
            content = first_block.normalized_content
            
            # 分析模式类型
            if "match" in content and "with" in content:
                patterns["模式匹配重复"] += 1
            elif "let" in content and "=" in content:
                patterns["变量绑定重复"] += 1
            elif "if" in content and "then" in content:
                patterns["条件判断重复"] += 1
            elif "List." in content or "Array." in content:
                patterns["集合操作重复"] += 1
            elif "printf" in content or "print" in content:
                patterns["输出操作重复"] += 1
            elif "raise" in content or "try" in content:
                patterns["错误处理重复"] += 1
            else:
                patterns["其他重复"] += 1
        
        return dict(patterns)
    
    def get_refactor_suggestions(self, dup: DuplicationResult) -> List[str]:
        """生成重构建议"""
        suggestions = []
        content = dup.blocks[0].normalized_content.lower()
        
        if dup.similarity == 1.0:
            suggestions.append("完全重复：提取为独立函数")
            suggestions.append(f"涉及文件：{[block.file_path for block in dup.blocks]}")
        
        if "match" in content:
            suggestions.append("考虑抽象模式匹配逻辑为通用函数")
        
        if "error" in content or "exception" in content:
            suggestions.append("统一错误处理逻辑，创建错误处理模块")
        
        if "list" in content or "array" in content:
            suggestions.append("抽象集合操作为通用工具函数")
        
        if len(dup.blocks) > 3:
            suggestions.append("高频重复：优先重构")
        
        return suggestions
    
    def analyze_project(self) -> Dict:
        """分析整个项目的代码重复"""
        all_blocks = []
        ml_files = []
        
        # 收集所有OCaml文件（限制数量）
        for root, dirs, files in os.walk(self.project_root):
            # 跳过构建目录
            if '_build' in dirs:
                dirs.remove('_build')
            if 'output' in dirs:
                dirs.remove('output')
                
            for file in files:
                if file.endswith('.ml') and len(ml_files) < self.max_files:
                    file_path = os.path.join(root, file)
                    # 优先分析重要的文件
                    if any(important in file for important in ['lexer', 'parser', 'semantic', 'builtin', 'codegen']):
                        ml_files.insert(0, file_path)
                    else:
                        ml_files.append(file_path)
        
        print(f"分析 {len(ml_files)} 个OCaml文件...")
        
        # 提取所有代码块
        for file_path in ml_files:
            blocks = self.extract_code_blocks(file_path)
            all_blocks.extend(blocks)
        
        print(f"提取了 {len(all_blocks)} 个代码块")
        
        # 查找重复
        exact_duplicates = self.find_exact_duplicates(all_blocks)
        similar_blocks = self.find_similar_blocks(all_blocks)
        
        # 分析模式
        all_duplications = exact_duplicates + similar_blocks
        pattern_analysis = self.analyze_pattern_types(all_duplications)
        
        # 生成详细建议
        detailed_suggestions = []
        for dup in all_duplications[:10]:  # 只显示前10个最重要的
            suggestions = self.get_refactor_suggestions(dup)
            detailed_suggestions.append({
                'files': [block.file_path for block in dup.blocks],
                'lines': [(block.start_line, block.end_line) for block in dup.blocks],
                'similarity': dup.similarity,
                'pattern_type': dup.pattern_type,
                'suggestions': suggestions,
                'content_preview': dup.blocks[0].content[:200] + "..." if len(dup.blocks[0].content) > 200 else dup.blocks[0].content
            })
        
        return {
            'summary': {
                'total_files': len(ml_files),
                'total_blocks': len(all_blocks),
                'exact_duplicates': len(exact_duplicates),
                'similar_blocks': len(similar_blocks),
                'total_duplications': len(all_duplications)
            },
            'pattern_analysis': pattern_analysis,
            'top_duplications': detailed_suggestions,
            'recommendations': self.generate_recommendations(all_duplications, pattern_analysis)
        }
    
    def generate_recommendations(self, duplications: List[DuplicationResult], patterns: Dict[str, int]) -> List[str]:
        """生成总体重构建议"""
        recommendations = []
        
        total_dups = len(duplications)
        if total_dups > 20:
            recommendations.append(f"发现 {total_dups} 处代码重复，建议优先重构")
        
        # 根据模式类型给出建议
        if patterns.get("模式匹配重复", 0) > 5:
            recommendations.append("大量模式匹配重复，建议创建通用模式匹配工具")
        
        if patterns.get("错误处理重复", 0) > 3:
            recommendations.append("错误处理逻辑重复，建议统一错误处理框架")
        
        if patterns.get("集合操作重复", 0) > 5:
            recommendations.append("集合操作重复较多，建议扩展标准库工具函数")
        
        # 文件级别建议
        file_occurrences = Counter()
        for dup in duplications:
            for block in dup.blocks:
                file_occurrences[block.file_path] += 1
        
        high_dup_files = [f for f, count in file_occurrences.most_common(5) if count > 3]
        if high_dup_files:
            recommendations.append(f"高重复文件需重点关注：{high_dup_files}")
        
        return recommendations

def main():
    """主函数"""
    project_root = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src"
    analyzer = CodeDuplicationAnalyzer(project_root)
    
    print("开始分析代码重复...")
    results = analyzer.analyze_project()
    
    # 输出结果
    print("\n=== 骆言项目代码重复分析报告 ===")
    print(f"分析文件数量: {results['summary']['total_files']}")
    print(f"代码块总数: {results['summary']['total_blocks']}")
    print(f"完全重复代码块: {results['summary']['exact_duplicates']}")
    print(f"相似代码块: {results['summary']['similar_blocks']}")
    print(f"总重复问题: {results['summary']['total_duplications']}")
    
    print("\n=== 重复模式分析 ===")
    for pattern, count in results['pattern_analysis'].items():
        print(f"{pattern}: {count} 处")
    
    print("\n=== 重点重复代码案例 ===")
    for i, dup in enumerate(results['top_duplications'][:5], 1):
        print(f"\n{i}. 相似度: {dup['similarity']:.2f} | 类型: {dup['pattern_type']}")
        print(f"   涉及文件: {len(dup['files'])} 个")
        for j, (file_path, (start, end)) in enumerate(zip(dup['files'], dup['lines'])):
            print(f"   - {os.path.basename(file_path)}:{start}-{end}")
        print(f"   代码预览: {dup['content_preview'][:100]}...")
        print(f"   建议: {'; '.join(dup['suggestions'][:2])}")
    
    print("\n=== 重构建议 ===")
    for rec in results['recommendations']:
        print(f"• {rec}")
    
    # 保存详细报告
    output_file = "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/code_duplication_report.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"\n详细报告已保存到: {output_file}")

if __name__ == "__main__":
    main()