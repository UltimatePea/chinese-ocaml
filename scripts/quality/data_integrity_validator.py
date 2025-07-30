#!/usr/bin/env python3
"""
数据完整性验证器 - Fix #1799

检测韵律数据中的重复、分类错误和完整性问题。
基于Beta代理对PR #1798的分析建立的质量门控工具。

Author: Beta, 代码审查专家
"""

import re
import sys
from pathlib import Path
from collections import defaultdict, Counter
from typing import Dict, List, Set, Tuple, Optional


class RhymeDataValidator:
    """韵律数据完整性验证器"""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.rhyme_characters = defaultdict(list)  # char -> [(group, category, line_no)]
        
    def validate_file(self, file_path: Path) -> bool:
        """验证单个文件的韵律数据完整性"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            self._extract_rhyme_data(content, file_path)
            self._check_duplicates_in_lists(content, file_path)
            self._check_character_classification()
            
            return len(self.errors) == 0
            
        except Exception as e:
            self.errors.append(f"读取文件 {file_path} 失败: {e}")
            return False
    
    def _extract_rhyme_data(self, content: str, file_path: Path):
        """提取韵律数据进行分析"""
        lines = content.split('\n')
        current_group = None
        
        for i, line in enumerate(lines, 1):
            # 识别韵组定义
            group_match = re.search(r'let\s+(\w+)_rhyme_group_data\s*=', line)
            if group_match:
                current_group = group_match.group(1)
                continue
            
            # 识别声调分类
            category_match = re.search(r'(ping_sheng_chars|ze_sheng_chars|shang_sheng_chars|qu_sheng_chars|ru_sheng_chars)\s*=\s*\[', line)
            if category_match and current_group:
                category = category_match.group(1)
                self._extract_characters_from_list(line, current_group, category, i, file_path)
    
    def _extract_characters_from_list(self, line: str, group: str, category: str, line_no: int, file_path: Path):
        """从字符列表中提取韵字"""
        # 简化的字符提取（实际实现需要处理多行列表）
        char_pattern = r'"([^"]+)"'
        chars = re.findall(char_pattern, line)
        
        for char in chars:
            self.rhyme_characters[char].append((group, category, line_no, file_path))
    
    def _check_duplicates_in_lists(self, content: str, file_path: Path):
        """检查单个列表内的重复"""
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            if 'chars = [' in line or '"' in line:
                chars = re.findall(r'"([^"]+)"', line)
                char_counts = Counter(chars)
                
                for char, count in char_counts.items():
                    if count > 1:
                        self.errors.append(
                            f"数据重复错误 {file_path}:{i} - 字符 '{char}' 在同一行重复 {count} 次"
                        )
    
    def _check_character_classification(self):
        """检查字符分类一致性"""
        for char, occurrences in self.rhyme_characters.items():
            if len(occurrences) > 1:
                # 检查是否在不同韵组中重复
                groups = set(occ[0] for occ in occurrences)
                if len(groups) > 1:
                    self.errors.append(
                        f"字符分类错误 - '{char}' 同时出现在多个韵组: {groups}"
                    )
                
                # 检查是否在同一韵组的不同声调中重复
                group_categories = defaultdict(set)
                for group, category, line_no, file_path in occurrences:
                    group_categories[group].add(category)
                
                for group, categories in group_categories.items():
                    if len(categories) > 1:
                        self.warnings.append(
                            f"字符声调重复 - '{char}' 在韵组 '{group}' 中出现在多个声调: {categories}"
                        )
    
    def print_report(self):
        """打印验证报告"""
        print("=" * 60)
        print("韵律数据完整性验证报告")
        print("=" * 60)
        
        if self.errors:
            print(f"\n🚨 发现 {len(self.errors)} 个严重错误:")
            for error in self.errors:
                print(f"  ❌ {error}")
        
        if self.warnings:
            print(f"\n⚠️  发现 {len(self.warnings)} 个警告:")
            for warning in self.warnings:
                print(f"  ⚠️  {warning}")
        
        if not self.errors and not self.warnings:
            print("\n✅ 所有验证通过，数据完整性良好")
        
        print(f"\n总结: {len(self.errors)} 错误, {len(self.warnings)} 警告")
        return len(self.errors) == 0


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python data_integrity_validator.py <file_path>")
        sys.exit(1)
    
    file_path = Path(sys.argv[1])
    if not file_path.exists():
        print(f"错误: 文件 {file_path} 不存在")
        sys.exit(1)
    
    validator = RhymeDataValidator()
    success = validator.validate_file(file_path)
    validator.print_report()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()