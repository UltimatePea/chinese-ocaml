#!/usr/bin/env python3
"""
安全的Token转换工具 - 保守的转换策略

功能:
1. 只进行明确安全的转换
2. 避免语法破坏
3. 提供详细的转换验证

Author: Alpha, 主要工作专员
"""

import os
import re
import json
import shutil
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass, asdict
from collections import defaultdict, Counter
import subprocess

@dataclass
class SafeConversionRule:
    """安全转换规则"""
    name: str
    pattern: re.Pattern
    replacement: str
    description: str
    safety_checks: List[str]

class SafeTokenConverter:
    """安全Token转换器"""
    
    def __init__(self, root_path: str):
        self.root_path = Path(root_path)
        self.backup_dir = self.root_path / "_safe_conversion_backups"
        self.backup_dir.mkdir(exist_ok=True)
        
        # 设置安全的转换规则
        self.setup_safe_conversion_rules()
    
    def setup_safe_conversion_rules(self) -> None:
        """设置安全的转换规则 - 只进行明确安全的转换"""
        self.conversion_rules = [
            # 规则1: 注释中的token_引用更新
            SafeConversionRule(
                name="comment_token_references",
                pattern=re.compile(r'(\(\*.*?)token_(\w+)(.*?\*\))'),
                replacement=r'\1TokenSystem.\2\3',
                description="更新注释中的token_引用",
                safety_checks=["is_in_comment"]
            ),
            
            # 规则2: 字符串字面量中的token_引用
            SafeConversionRule(
                name="string_token_references", 
                pattern=re.compile(r'(".*?)token_(\w+)(.*?")'),
                replacement=r'\1TokenSystem.\2\3',
                description="更新字符串中的token_引用",
                safety_checks=["is_in_string"]
            ),
            
            # 规则3: 明确的函数调用转换（安全模式）
            SafeConversionRule(
                name="safe_function_calls",
                pattern=re.compile(r'\btoken_(\w+)_to_string\s*\('),
                replacement=r'TokenSystem.string_of_\1(',
                description="转换明确的token_*_to_string函数调用",
                safety_checks=["is_function_call", "not_in_type_def"]
            ),
            
            # 规则4: 明确的创建函数
            SafeConversionRule(
                name="create_functions",
                pattern=re.compile(r'\bcreate_token_(\w+)\s*\('),
                replacement=r'TokenSystem.create_\1(',
                description="转换create_token_*函数调用",
                safety_checks=["is_function_call", "not_in_type_def"]
            ),
            
            # 规则5: 模块开放语句
            SafeConversionRule(
                name="module_open",
                pattern=re.compile(r'\bopen\s+Token_(\w+)\b'),
                replacement=r'open TokenSystem.\1',
                description="转换模块open语句",
                safety_checks=["is_module_open"]
            )
        ]
    
    def is_safe_to_convert(self, line: str, rule: SafeConversionRule, match) -> bool:
        """检查转换是否安全"""
        for check in rule.safety_checks:
            if check == "is_in_comment":
                # 检查是否在注释中
                comment_start = line.find('(*')
                comment_end = line.find('*)')
                match_pos = match.start()
                if not (comment_start != -1 and comment_end != -1 and 
                       comment_start < match_pos < comment_end):
                    return False
            
            elif check == "is_in_string":
                # 检查是否在字符串中
                quote_positions = [m.start() for m in re.finditer(r'"', line)]
                match_pos = match.start()
                in_string = False
                for i in range(0, len(quote_positions), 2):
                    if i + 1 < len(quote_positions):
                        if quote_positions[i] < match_pos < quote_positions[i + 1]:
                            in_string = True
                            break
                if not in_string:
                    return False
            
            elif check == "is_function_call":
                # 检查是否是函数调用（后面跟着括号）
                if not re.search(r'\s*\(', line[match.end():]):
                    return False
            
            elif check == "not_in_type_def":
                # 检查不在类型定义中
                if re.search(r'\btype\s+.*=', line.strip()):
                    return False
            
            elif check == "is_module_open":
                # 检查是否是模块open语句
                if not line.strip().startswith('open '):
                    return False
        
        return True
    
    def convert_file_safely(self, file_path: Path) -> List[Dict]:
        """安全地转换单个文件"""
        results = []
        
        try:
            # 创建备份
            backup_path = self.backup_dir / f"{file_path.name}.backup"
            shutil.copy2(file_path, backup_path)
            
            # 读取文件
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # 处理每一行
            converted_lines = []
            file_changed = False
            
            for line_num, line in enumerate(lines, 1):
                original_line = line
                current_line = line
                
                # 应用每个安全规则
                for rule in self.conversion_rules:
                    matches = list(rule.pattern.finditer(current_line))
                    for match in reversed(matches):  # 从后往前替换，避免位置偏移
                        if self.is_safe_to_convert(current_line, rule, match):
                            # 安全转换
                            new_text = rule.pattern.sub(rule.replacement, match.group(0))
                            current_line = (current_line[:match.start()] + 
                                          new_text + 
                                          current_line[match.end():])
                            file_changed = True
                            
                            results.append({
                                'file': str(file_path.relative_to(self.root_path)),
                                'line': line_num,
                                'rule': rule.name,
                                'original': original_line.strip(),
                                'converted': current_line.strip(),
                                'description': rule.description
                            })
                
                converted_lines.append(current_line)
            
            # 如果有变更，写入文件
            if file_changed:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(converted_lines)
                print(f"✅ 安全转换: {file_path.relative_to(self.root_path)} ({len(results)} 处修改)")
            
        except Exception as e:
            print(f"❌ 转换失败: {file_path.relative_to(self.root_path)} - {e}")
            results.append({
                'file': str(file_path.relative_to(self.root_path)),
                'error': str(e)
            })
        
        return results
    
    def convert_batch_safely(self, target_dirs: List[str]) -> Dict:
        """安全地转换指定目录"""
        print("🛡️ 开始安全Token转换...")
        
        all_results = []
        processed_files = 0
        
        for target_dir in target_dirs:
            dir_path = self.root_path / target_dir
            if not dir_path.exists():
                print(f"⚠️ 目录不存在: {target_dir}")
                continue
            
            # 扫描目录中的ML文件
            for pattern in ['**/*.ml', '**/*.mli']:
                for file_path in dir_path.glob(pattern):
                    if self._should_skip_file(file_path):
                        continue
                    
                    results = self.convert_file_safely(file_path)
                    all_results.extend(results)
                    processed_files += 1
        
        # 生成摘要
        successful_conversions = len([r for r in all_results if 'error' not in r])
        failed_conversions = len([r for r in all_results if 'error' in r])
        
        summary = {
            'total_files': processed_files,
            'total_conversions': len(all_results),
            'successful_conversions': successful_conversions,
            'failed_conversions': failed_conversions,
            'conversion_details': all_results
        }
        
        print(f"✅ 安全转换完成:")
        print(f"   处理文件: {processed_files}")
        print(f"   成功转换: {successful_conversions}")
        print(f"   转换失败: {failed_conversions}")
        
        return summary
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """判断是否应该跳过文件"""
        skip_patterns = [
            '_build/', '.git/', 'bisect',
            'backup', 'old', 'deprecated'
        ]
        return any(pattern in str(file_path) for pattern in skip_patterns)
    
    def validate_conversion(self) -> bool:
        """验证转换结果"""
        print("🔍 验证安全转换结果...")
        
        try:
            result = subprocess.run(
                ['dune', 'build', '--display', 'quiet'],
                cwd=self.root_path,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode == 0:
                print("✅ 编译验证通过")
                return True
            else:
                print("❌ 编译验证失败:")
                print(result.stderr)
                return False
                
        except Exception as e:
            print(f"❌ 验证异常: {e}")
            return False
    
    def rollback_conversion(self) -> bool:
        """回滚转换"""
        print("🔄 回滚安全转换...")
        
        rollback_success = True
        backup_files = list(self.backup_dir.glob("*.backup"))
        
        for backup_file in backup_files:
            original_name = backup_file.name.replace('.backup', '')
            
            # 查找原始文件
            for pattern in ['**/*.ml', '**/*.mli']:
                for file_path in self.root_path.glob(pattern):
                    if file_path.name == original_name:
                        try:
                            shutil.copy2(backup_file, file_path)
                            print(f"✅ 回滚: {file_path.relative_to(self.root_path)}")
                        except Exception as e:
                            print(f"❌ 回滚失败: {file_path.relative_to(self.root_path)} - {e}")
                            rollback_success = False
                        break
        
        return rollback_success

def main():
    parser = argparse.ArgumentParser(description='安全Token转换工具')
    parser.add_argument('--root', default='.', help='项目根目录路径')
    parser.add_argument('--targets', nargs='+', 
                      default=['src/tokens', 'src/utils'],
                      help='要转换的目标目录')
    parser.add_argument('--validate', action='store_true', help='验证转换结果')
    parser.add_argument('--rollback', action='store_true', help='回滚转换')
    parser.add_argument('--report', default='safe_conversion_report.json',
                      help='转换报告输出路径')
    
    args = parser.parse_args()
    
    converter = SafeTokenConverter(args.root)
    
    if args.rollback:
        converter.rollback_conversion()
        return
    
    # 执行安全转换
    summary = converter.convert_batch_safely(args.targets)
    
    # 保存报告
    with open(args.report, 'w', encoding='utf-8') as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    print(f"📊 转换报告已保存到: {args.report}")
    
    # 验证转换
    if args.validate:
        converter.validate_conversion()

if __name__ == '__main__':
    main()