#!/usr/bin/env python3
"""
快速ASCII字符修复脚本 - 针对最常见的模式
"""

import os
import re
import glob

def is_comment_line(line):
    """检查是否为注释行"""
    stripped = line.strip()
    return (stripped.startswith('#') or 
            stripped.startswith('//') or 
            stripped.startswith('(*') or
            stripped.startswith('*') or
            '/*' in stripped)

def quick_fix_line(line):
    """快速修复常见的ASCII字符模式"""
    if is_comment_line(line):
        return line  # 保持注释行不变
    
    # 最常见的替换模式
    replacements = [
        # 函数定义语法
        (r'函数\s+([a-zA-Z_]+)\s*->', r'夫「」者受 \1 焉算法乃'),
        (r'函数\s+([a-zA-Z_]+)\s+([a-zA-Z_]+)\s*->', r'夫「」者受 \1 \2 焉算法乃'),
        
        # 常见变量名（作为独立单词）
        (r'\bx\b', '甲'),
        (r'\by\b', '乙'),
        (r'\bn\b', '数'),
        (r'\bf\b', '函'),
        (r'\bg\b', '辅'),
        (r'\ba\b', '甲'),
        (r'\bb\b', '乙'),
        (r'\bc\b', '丙'),
        (r'\bd\b', '丁'),
        
        # 操作符
        (r'\s+\+\s+', ' 加 '),
        (r'\s+-\s+', ' 减 '),
        (r'\s+\*\s+', ' 乘 '),
        (r'\s+/\s+', ' 除 '),
        (r'\s+%\s+', ' 除余 '),
        (r'\s+<=\s+', ' 小于等于 '),
        (r'\s+>=\s+', ' 大于等于 '),
        (r'\s+<\s+', ' 小于 '),
        (r'\s+>\s+', ' 大于 '),
        (r'\s+==\s+', ' 等等于 '),
        (r'\s+=\s+', ' 等于 '),
        
        # 常见英文标识符
        ('identity', '恒等'),
        ('int_identity', '整数恒等'),
        ('string_identity', '字符串恒等'),
        ('num_result', '数字结果'),
        ('str_result', '字符串结果'),
        ('list_result', '列表结果'),
        ('compose', '复合'),
        ('add_one', '加一'),
        ('double', '双倍'),
        ('add_one_then_double', '加一后双倍'),
        ('result', '结果'),
        ('number', '数字'),
        ('text', '文本'),
        ('calculation', '计算'),
        ('add_function', '加法函数'),
        ('numbers', '数字们'),
        ('sum_result', '求和结果'),
        ('max_result', '最大结果'),
        
        # 文件相关
        ('demo_output.txt', '演示输出。文本'),
        ('demo', '演示'),
        ('output', '输出'),
        ('txt', '文本'),
        
        # 类型关键字
        (' of ', ' 之 '),
        ('int', '整数'),
        ('string', '字符串'),
        ('bool', '布尔'),
        ('true', '真'),
        ('false', '假'),
    ]
    
    result = line
    for pattern, replacement in replacements:
        if pattern.startswith(r'\b') or pattern.startswith(r'\s+'):
            # 正则表达式模式
            result = re.sub(pattern, replacement, result)
        else:
            # 简单字符串替换
            result = result.replace(pattern, replacement)
    
    return result

def process_file(filepath):
    """处理单个文件"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            new_line = quick_fix_line(line)
            new_lines.append(new_line)
            if new_line != line:
                modified = True
        
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f"✅ 已处理: {filepath}")
            return True
        else:
            print(f"⏩ 无需修改: {filepath}")
            return False
            
    except Exception as e:
        print(f"❌ 处理失败 {filepath}: {e}")
        return False

def main():
    """主函数"""
    print("开始快速ASCII字符修复...")
    
    # 查找所有.ly文件
    ly_files = glob.glob('./**/*.ly', recursive=True)
    
    if not ly_files:
        print("未找到.ly文件")
        return
    
    total_files = len(ly_files)
    modified_files = 0
    
    for filepath in ly_files:
        if process_file(filepath):
            modified_files += 1
    
    print(f"\n📊 处理完成:")
    print(f"  总文件数: {total_files}")
    print(f"  修改文件数: {modified_files}")
    print(f"  未修改文件数: {total_files - modified_files}")

if __name__ == "__main__":
    main()