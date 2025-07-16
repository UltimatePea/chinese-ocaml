#!/usr/bin/env python3
"""
最终的ASCII清理脚本
"""

import re
import glob

def ultra_clean_line(line):
    """超级清理行中的ASCII字符"""
    
    if line.strip().startswith('#') or line.strip().startswith('//') or line.strip().startswith('*'):
        return line
    
    new_line = line
    
    # 最后的ASCII字符替换
    replacements = [
        ('c代码', '丙代码'),
        ('C配置', '丙配置'),
        ('C函数', '丙函数'),
        ('C变量', '丙变量'),
        ('C程序', '丙程序'),
        ('C类型', '丙类型'),
        ('C文件', '丙文件'),
        ('C后端', '丙后端'),
        ('ast', '抽象语法树'),
        ('AST', '抽象语法树'),
        ('char', '字符'),
        ('id', '标识'),
        ('n个', '个'),
        ('s1', '字符串一'),
        ('s2', '字符串二'),
        ('n1', '数一'),
        ('n2', '数二'),
        ('T等于', '类型参数等于'),
        ('E等于', '错误类型等于'),
        ('all2', '全部二'),
        ('A', '大写字母A'),
        ('Z', '大写字母Z'),
        ('i（', '索引（'),
        ('not', '非'),
        ('of', '之'),
        ('n个', '个'),
        ('C', '丙'),  # Last resort for single C
    ]
    
    for old, new in replacements:
        new_line = new_line.replace(old, new)
    
    return new_line

def main():
    """主函数"""
    ly_files = glob.glob('./**/*.ly', recursive=True)
    
    modified_count = 0
    for file_path in ly_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            new_lines = []
            modified = False
            
            for line in lines:
                new_line = ultra_clean_line(line)
                if new_line != line:
                    modified = True
                new_lines.append(new_line)
            
            if modified:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)
                print(f"已清理: {file_path}")
                modified_count += 1
            else:
                print(f"无需清理: {file_path}")
                
        except Exception as e:
            print(f"处理文件失败 {file_path}: {e}")
    
    print(f"\n完成，共修改了 {modified_count} 个文件")

if __name__ == '__main__':
    main()