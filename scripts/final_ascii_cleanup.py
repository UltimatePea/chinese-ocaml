#!/usr/bin/env python3
"""
最终ASCII字符清理脚本 - 处理剩余的复杂模式
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

def final_cleanup_line(line):
    """最终清理行中的ASCII字符"""
    if is_comment_line(line):
        return line  # 保持注释行不变
    
    # 更全面的替换模式
    replacements = [
        # OCaml关键字
        (r'\bthen\b', '则'),
        (r'\belse\b', '余者'),
        (r'\bmod\b', '除余'),
        (r'\bhead\b', '首'),
        (r'\btail\b', '尾'),
        (r'\bacc\b', '累'),
        (r'\blst\b', '列'),
        (r'\bpred\b', '条件'),
        (r'\bflag\b', '标志'),
        (r'\bavg\b', '平均'),
        (r'\bproduct\b', '积'),
        (r'\bms\b', '毫秒'),
        
        # 复杂变量名
        ('add_one_then_double', '加一后双倍'),
        ('test_zero_params', '测试零参数'),
        ('zero_params', '零参数'),
        ('bad_addition', '错误加法'),
        ('undefined_result', '未定义结果'),
        ('bad_math', '错误数学'),
        ('typo_var', '拼写错误变量'),
        ('corrected', '修正的'),
        ('unkown_variable', '未知变量'),
        ('numbr', '数字错误'),
        ('unknown_var', '未知变量'),
        ('sum_result', '求和结果'),
        ('max_result', '最大结果'),
        ('undefined_结果', '未定义结果'),
        
        # 文件名和路径
        ('demo_output.txt', '演示输出。文本'),
        ('test_output.c', '测试输出。丙'),
        
        # 模式匹配中的标识符
        ('首名为「head;」', '首名为「首」'),
        ('尾名为「tail」', '尾名为「尾」'),
        ('首名为「head 其一 」', '首名为「首」'),
        
        # 函数名清理
        ('add_one', '加一'),
        ('add_function', '加法函数'),
        ('double', '双倍'),
        ('compose', '复合'),
        ('identity', '恒等'),
        ('int_identity', '整数恒等'),
        ('string_identity', '字符串恒等'),
        ('num_result', '数字结果'),
        ('str_result', '字符串结果'),
        ('list_result', '列表结果'),
        
        # 常见英文单词
        (r'\bnumber\b', '数字'),
        (r'\bnumbers\b', '数字们'),
        (r'\btext\b', '文本'),
        (r'\bresult\b', '结果'),
        (r'\bcalculation\b', '计算'),
        
        # 类型相关
        (r'\bAST\b', '抽象语法树'),
        (r'\bC\b', '丙'),
        (r'\bID\b', '标识'),
        
        # 操作符和符号
        (r'(\w+)_(\w+)', r'\1\2'),  # 移除下划线
        
        # 复杂标识符
        ('check_non_comment_ascii', '检查非注释ASCII'),
        ('simple_fibonacci_bench', '简单斐波那契基准'),
        ('fibonacci_bench', '斐波那契基准'),
        ('arithmetic_bench', '算术基准'),
        ('function_call_bench', '函数调用基准'),
        
        # 文件名中的ASCII
        (r'\.txt', '。文本'),
        (r'\.c', '。丙'),
        (r'\.ly', '。骆'),
    ]
    
    result = line
    for pattern, replacement in replacements:
        if pattern.startswith(r'\b') and pattern.endswith(r'\b'):
            # 单词边界正则表达式
            result = re.sub(pattern, replacement, result)
        elif '(' in pattern and ')' in pattern:
            # 正则表达式模式
            result = re.sub(pattern, replacement, result)
        else:
            # 简单字符串替换
            result = result.replace(pattern, replacement)
    
    # 特殊处理：移除剩余的下划线变量名
    result = re.sub(r'\b([a-zA-Z]+)_([a-zA-Z]+)\b', r'\1\2', result)
    
    # 处理剩余的单个ASCII字母（作为独立单词）
    ascii_to_chinese = {
        'a': '甲', 'b': '乙', 'c': '丙', 'd': '丁', 'e': '戊',
        'f': '函', 'g': '辅', 'h': '子', 'i': '索引', 'j': '次',
        'k': '键', 'l': '列', 'm': '映', 'n': '数', 'o': '对象',
        'p': '参', 'q': '序', 'r': '行', 's': '串', 't': '项',
        'u': '用', 'v': '值', 'w': '宽', 'x': '甲', 'y': '乙', 'z': '终'
    }
    
    for ascii_char, chinese_char in ascii_to_chinese.items():
        # 只替换独立的单个字母
        pattern = r'\b' + ascii_char + r'\b'
        result = re.sub(pattern, chinese_char, result)
    
    return result

def process_file(filepath):
    """处理单个文件"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            new_line = final_cleanup_line(line)
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
    print("开始最终ASCII字符清理...")
    
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