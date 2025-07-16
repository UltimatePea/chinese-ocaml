#!/usr/bin/env python3
"""
骆言项目ASCII字符中文化脚本
根据维护者指示进行一步到位清理，允许注释中保留英文
"""

import os
import re
import glob

# ASCII字符到中文的映射表
CHAR_MAPPING = {
    # 常见操作符
    '+': '加',
    '-': '减', 
    '*': '乘',
    '/': '除',
    '=': '等于',
    '<': '小于',
    '>': '大于',
    '<=': '小于等于',
    '>=': '大于等于',
    '==': '等等于',
    '!=': '不等于',
    '%': '除余',
    '&': '与',
    '|': '或',
    
    # 常见变量名和关键字
    'x': '甲',
    'y': '乙', 
    'n': '数',
    'i': '索引',
    'f': '函',
    'g': '辅',
    'a': '甲',
    'b': '乙',
    'c': '丙',
    'd': '丁',
    's': '串',
    'lst': '列',
    'list': '列表',
    'acc': '累',
    'head': '首',
    'tail': '尾',
    'result': '结果',
    'identity': '恒等',
    'compose': '复合',
    'number': '数字',
    'text': '文本',
    'flag': '标志',
    'calculation': '计算',
    'add_function': '加法函数',
    'numbers': '数字们',
    'avg': '平均',
    'product': '积',
    'sum_result': '求和结果',
    'max_result': '最大结果',
    'int_identity': '整数恒等',
    'string_identity': '字符串恒等',
    'num_result': '数字结果',
    'str_result': '字符串结果',
    'list_result': '列表结果',
    'bad_addition': '错误加法',
    'undefined_result': '未定义结果',
    'unknown_var': '未知变量',
    'bad_math': '错误数学',
    'typo_var': '拼写错误变量',
    'corrected': '修正的',
    'unkown_variable': '未知变量',
    'numbr': '数字',
    'test_zero_params': '测试零参数',
    'zero_params': '零参数',
    
    # 文件扩展名等
    'txt': '文本',
    'demo': '演示',
    'output': '输出',
    'demo_output.txt': '演示输出。文本',
    
    # 英文单词
    'of': '之',
    'int': '整数',
    'string': '字符串',
    'bool': '布尔',
    'float': '浮点',
    'true': '真',
    'false': '假',
    'if': '若',
    'then': '则',
    'else': '余者',
    'let': '设',
    'in': '在',
    'fun': '夫',
    'function': '函数',
    'match': '观',
    'with': '之性',
    'end': '观毕',
    'rec': '递归',
    'and': '且',
    'or': '或',
    'not': '非',
    'mod': '除余',
    'type': '类型',
    'mutable': '可变',
    'ref': '引用',
    'begin': '开始',
    'while': '当',
    'for': '遍历',
    'do': '做',
    'done': '做毕',
    'to': '至',
    'downto': '降至',
    'lazy': '惰性',
    'assert': '断言',
    'try': '试',
    'raise': '抛',
    'exception': '异常',
    'when': '当',
    'as': '作为',
    'class': '类',
    'object': '对象',
    'method': '方法',
    'virtual': '虚拟',
    'private': '私有',
    'public': '公开',
    'include': '包含',
    'module': '模块',
    'struct': '结构',
    'sig': '签名',
    'val': '值',
    'external': '外部',
    'open': '打开',
    'constraint': '约束',
    'inherit': '继承',
    'initializer': '初始化器'
}

def is_comment_line(line):
    """检查是否为注释行"""
    stripped = line.strip()
    return (stripped.startswith('#') or 
            stripped.startswith('//') or 
            stripped.startswith('(*') or
            stripped.startswith('*') or
            '/*' in stripped)

def clean_line(line):
    """清理一行中的ASCII字符，保持注释不变"""
    if is_comment_line(line):
        return line  # 保持注释行不变
    
    # 移除行内注释之后的部分，但保留注释
    comment_patterns = [
        (r'//.*$', '//'),
        (r'#.*$', '#'),
        (r'\(\*.*?\*\)', '(**)'),
        (r'/\*.*?\*/', '/**/')
    ]
    
    preserved_comments = []
    cleaned_line = line
    
    for pattern, marker in comment_patterns:
        matches = re.finditer(pattern, cleaned_line)
        for match in matches:
            preserved_comments.append(match.group())
            cleaned_line = cleaned_line.replace(match.group(), f'__COMMENT_{len(preserved_comments)-1}__')
    
    # 处理ASCII字符
    # 首先处理操作符和特殊字符
    for ascii_char, chinese_char in CHAR_MAPPING.items():
        if len(ascii_char) > 1:  # 多字符操作符
            cleaned_line = cleaned_line.replace(ascii_char, chinese_char)
    
    # 处理单个ASCII字母 - 只替换独立的单词
    for ascii_char, chinese_char in CHAR_MAPPING.items():
        if len(ascii_char) == 1 and ascii_char.isalpha():
            # 只替换独立的字母，不破坏较长的标识符
            pattern = r'\b' + re.escape(ascii_char) + r'\b'
            cleaned_line = re.sub(pattern, chinese_char, cleaned_line)
    
    # 恢复注释
    for i, comment in enumerate(preserved_comments):
        cleaned_line = cleaned_line.replace(f'__COMMENT_{i}__', comment)
    
    return cleaned_line

def process_file(filepath):
    """处理单个文件"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            new_line = clean_line(line)
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
    print("开始ASCII字符中文化处理...")
    
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