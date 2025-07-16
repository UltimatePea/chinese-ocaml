#!/usr/bin/env python3
"""
绝对最终的ASCII清理脚本
"""

import re
import glob

def absolutely_final_clean(line):
    """绝对最终清理"""
    
    if line.strip().startswith('#') or line.strip().startswith('//') or line.strip().startswith('*'):
        return line
    
    new_line = line
    
    # 最后的几个特殊字符
    new_line = new_line.replace('pr整数', '打印整数')
    new_line = new_line.replace('迭代i', '迭代索引')
    new_line = new_line.replace('curry', '柯里')
    
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
                new_line = absolutely_final_clean(line)
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