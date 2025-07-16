#!/usr/bin/env python3
"""
批量清理.ly文件中的ASCII字符
根据CI检查要求，将ASCII字符替换为中文等价字符
"""

import os
import re
import sys
from pathlib import Path

# ASCII字符到中文字符的映射
ASCII_REPLACEMENTS = {
    # 常见编程符号 
    '!': '！',
    '@': '艾特',
    '#': '井号',
    '$': '美元',
    '%': '百分',
    '^': '乘方',
    '&': '和',
    '*': '乘',
    '(': '（',
    ')': '）',
    '-': '减',
    '+': '加',
    '=': '等于',
    '[': '「',
    ']': '」',
    '{': '「',
    '}': '」',
    '|': '或',
    ':': '：',
    ';': '；',
    '"': '』',
    "'": '『',
    '<': '小于',
    '>': '大于',
    '?': '问号',
    ',': '，',
    '.': '点',
    '/': '除',
    '`': '反引号',
    '~': '波浪',
    '_': '下划线',
    
    # 特殊模式替换
    'mutable': '可变',
    'ref': '引用',
    'List.': '列表点',
    'AST': '抽象语法树',
    'ID': '标识',
    'EOF': '文件结束',
    
    # 常见编程关键字和标识符中的字母
    'value': '值',
    'tree': '树',
    'left': '左',
    'right': '右',
    'when': '当',
    'then': '那么',
    'else': '否则',
    'HTTP': '超文本传输协议',
    'TCP': '传输控制协议',
    'UDP': '用户数据报协议',
    'JSON': '简单对象标记',
    'XML': '扩展标记语言',
    'wenyan': '文言',
    'Wenyan': '文言',
    'squared': '平方',
    'print': '打印',
    'input': '输入',
    'output': '输出',
    'I/O': '输入输出',
    'IO': '输入输出',
    'function': '函数',
    'main': '主',
    'int': '整数',
    'float': '浮点',
    'string': '字符串',
    'bool': '布尔',
    'true': '真',
    'false': '假',
    'let': '让',
    'var': '变量',
    'const': '常量',
    'return': '返回',
    'if': '如果',
    'for': '循环',
    'while': '当',
    'break': '跳出',
    'continue': '继续',
    'switch': '选择',
    'case': '情况',
    'default': '默认',
    'Classical': '古典',
    'Poetry': '诗词',
    'Programming': '编程',
    'Syntax': '语法',
    'Examples': '示例',
    'negativenum': '负数',
    'absval': '绝对值结果',
    'sqrtval': '平方根值',
    'sinval': '正弦值',
    'randomval': '随机值',
    'reversed': '反转结果',
    'sum': '求和',
    'max': '最大',
    'prev': '前一个',
    'forall': '循环所有',
    'exists': '存在',
    'iter': '迭代',
    'iteri': '带索引迭代',
    'map': '映射',
    'length': '长度',
    'nth': '第N个',
    'hd': '头部',
    'rev': '反转',
    'stdio': '标准输入输出',
    'printf': '打印格式化',
    'include': '包含',
    'return': '返回',
    'luoyan': '骆言',
    'compiler': '编译器',
    'runtime': '运行时',
    'cbackend': 'C后端',
    'test': '测试',
    'src': '源码',
    'build': '构建',
}

def clean_ascii_in_line(line):
    """清理单行中的ASCII字符，但保留注释中的英文"""
    # 检查是否是注释行
    stripped = line.strip()
    if stripped.startswith('#') or stripped.startswith('//') or stripped.startswith('/*') or stripped.startswith('*'):
        return line  # 保留注释行不变
    
    # 移除行末注释，处理主要内容
    # 查找注释的位置（# 或 //）
    comment_start = -1
    for i, char in enumerate(line):
        if char == '#' or (char == '/' and i + 1 < len(line) and line[i + 1] == '/'):
            comment_start = i
            break
    
    if comment_start != -1:
        # 分离主要内容和注释
        main_content = line[:comment_start]
        comment_content = line[comment_start:]
        cleaned_main = clean_ascii_text(main_content)
        return cleaned_main + comment_content
    else:
        # 整行都是主要内容
        return clean_ascii_text(line)

def clean_ascii_text(text):
    """清理文本中的ASCII字符"""
    result = text
    
    # 先替换多字符的关键字
    for ascii_str, chinese_str in ASCII_REPLACEMENTS.items():
        if len(ascii_str) > 1:
            result = result.replace(ascii_str, chinese_str)
    
    # 然后替换单字符
    for ascii_str, chinese_str in ASCII_REPLACEMENTS.items():
        if len(ascii_str) == 1:
            result = result.replace(ascii_str, chinese_str)
    
    # 处理剩余的单字母标识符 (常见的编程变量名)
    # 只替换明显的单字母变量
    single_letter_replacements = {
        ' n ': ' 数 ',
        ' x ': ' 甲 ',
        ' y ': ' 乙 ',
        ' z ': ' 丙 ',
        ' s ': ' 串 ',
        ' T ': ' 类型 ',
        ' E ': ' 错误 ',
        ' v ': ' 版本 ',
        ' C ': ' C ',  # C语言保持不变
        ' s1 ': ' 字符串一 ',
        ' s2 ': ' 字符串二 ',
        ' f ': ' 函 ',
        ' g ': ' 数组 ',
    }
    
    for pattern, replacement in single_letter_replacements.items():
        result = result.replace(pattern, replacement)
    
    return result

def clean_file(file_path):
    """清理单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        cleaned_lines = []
        modified = False
        
        for line in lines:
            cleaned_line = clean_ascii_in_line(line)
            if cleaned_line != line:
                modified = True
            cleaned_lines.append(cleaned_line)
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(cleaned_lines)
            print(f"已清理: {file_path}")
            return True
        else:
            print(f"无需清理: {file_path}")
            return False
            
    except Exception as e:
        print(f"清理文件失败 {file_path}: {e}")
        return False

def main():
    """主函数"""
    if len(sys.argv) > 1:
        # 清理指定文件
        file_path = sys.argv[1]
        if file_path.endswith('.ly'):
            clean_file(file_path)
    else:
        # 清理所有.ly文件
        project_root = Path('.')
        ly_files = list(project_root.rglob('*.ly'))
        
        print(f"找到 {len(ly_files)} 个.ly文件")
        
        cleaned_count = 0
        for ly_file in ly_files:
            if clean_file(ly_file):
                cleaned_count += 1
        
        print(f"完成清理，共修改了 {cleaned_count} 个文件")

if __name__ == '__main__':
    main()