#!/usr/bin/env python3
"""
脚本用于批量解决merge conflict
策略：采用HEAD版本的内容，然后清理行尾空格
"""

import os
import re
import subprocess

def get_conflicted_files():
    """获取所有有冲突的文件"""
    result = subprocess.run(['git', 'diff', '--name-only', '--diff-filter=U'], 
                          capture_output=True, text=True)
    return result.stdout.strip().split('\n') if result.stdout.strip() else []

def resolve_conflict_in_file(filepath):
    """解决单个文件的冲突"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 使用正则表达式找到所有冲突标记
        conflict_pattern = r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> [^\n]+\n'
        
        def resolve_conflict(match):
            head_content = match.group(1)
            # 返回HEAD内容并清理行尾空格
            lines = head_content.split('\n')
            cleaned_lines = [line.rstrip() for line in lines]
            return '\n'.join(cleaned_lines) + '\n'
        
        # 替换所有冲突
        resolved_content = re.sub(conflict_pattern, resolve_conflict, content, flags=re.DOTALL)
        
        # 全局清理行尾空格
        lines = resolved_content.split('\n')
        cleaned_lines = [line.rstrip() for line in lines]
        final_content = '\n'.join(cleaned_lines)
        
        # 如果文件原本以换行符结尾，保持这个特性
        if content.endswith('\n'):
            final_content += '\n'
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(final_content)
        
        print(f"已解决: {filepath}")
        return True
        
    except Exception as e:
        print(f"解决 {filepath} 时出错: {e}")
        return False

def main():
    conflicted_files = get_conflicted_files()
    
    if not conflicted_files:
        print("没有冲突文件")
        return
    
    print(f"发现 {len(conflicted_files)} 个冲突文件")
    
    resolved_count = 0
    for filepath in conflicted_files:
        if resolve_conflict_in_file(filepath):
            resolved_count += 1
    
    print(f"成功解决 {resolved_count}/{len(conflicted_files)} 个文件的冲突")

if __name__ == "__main__":
    main()