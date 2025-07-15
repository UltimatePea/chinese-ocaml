#!/usr/bin/env python3
"""
按照问题#64方案重构.ly文件的脚本

规则：
1. 取消关键字间空格
2. 把所有标识符名称用「」括起来

示例转换：
异步 夫 并发任务1 者 受 () 焉 算法 乃  ->  异步夫「并发任务1」者受()焉算法乃
设 结果 为 异步计算 5  ->  设「结果」为「异步计算 5」
"""

import os
import re
import glob

def refactor_line(line):
    """重构单行代码"""
    original_line = line

    # 跳过注释行和空行
    if line.strip().startswith('「：') or line.strip() == '' or line.strip().startswith('#'):
        return line

    # 1. 处理函数定义：夫 name 者 受 -> 夫「name」者受
    line = re.sub(r'夫\s+([^\s者]+)\s+者\s+受', r'夫「\1」者受', line)

    # 2. 处理异步函数：异步 夫 -> 异步夫
    line = re.sub(r'异步\s+夫', '异步夫', line)

    # 3. 处理递归函数：递归 夫 -> 递归夫
    line = re.sub(r'递归\s+夫', '递归夫', line)

    # 4. 处理变量赋值：设 name 为 -> 设「name」为
    line = re.sub(r'设\s+([^\s为]+)\s+为', r'设「\1」为', line)

    # 5. 处理let绑定：让 name = -> 让「name」=
    line = re.sub(r'让\s+([^\s=]+)\s*=', r'让「\1」=', line)

    # 6. 处理模式匹配：观 expr 之 性 -> 观「expr」之性
    line = re.sub(r'观\s+([^\s之]+)\s+之\s+性', r'观「\1」之性', line)

    # 7. 移除其他关键字间的空格
    line = re.sub(r'焉\s+算法\s+乃', '焉算法乃', line)
    line = re.sub(r'观毕\s+是谓', '观毕是谓', line)
    line = re.sub(r'余者\s+则', '余者则', line)
    line = re.sub(r'余者\s+答', '余者答', line)

    # 8. 处理函数调用中的空格和参数
    # 移除函数调用前的空格，但保留参数
    line = re.sub(r'\s*\(\s*', '(', line)
    line = re.sub(r'\s*\)\s*', ')', line)

    # 9. 处理赋值操作符周围的空格
    line = re.sub(r'\s*为\s*', '为', line)
    line = re.sub(r'\s*=\s*', '=', line)

    return line

def refactor_file(file_path):
    """重构单个文件"""
    print(f"正在处理文件: {file_path}")

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        original_content = ''.join(lines)
        refactored_lines = []

        for line in lines:
            refactored_line = refactor_line(line)
            refactored_lines.append(refactored_line)

        refactored_content = ''.join(refactored_lines)

        # 如果内容有变化，写回文件
        if refactored_content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(refactored_content)
            print(f"已更新: {file_path}")
            return True
        else:
            print(f"无需更新: {file_path}")
            return False

    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return False

def main():
    """主函数"""
    # 获取所有.ly文件
    ly_files = glob.glob("/home/zc/chinese-ocaml/**/*.ly", recursive=True)

    updated_count = 0
    total_count = len(ly_files)

    print(f"找到 {total_count} 个 .ly 文件")

    for file_path in ly_files:
        if refactor_file(file_path):
            updated_count += 1

    print(f"\n重构完成!")
    print(f"总文件数: {total_count}")
    print(f"已更新文件数: {updated_count}")
    print(f"未更新文件数: {total_count - updated_count}")

if __name__ == "__main__":
    main()