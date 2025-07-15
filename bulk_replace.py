#!/usr/bin/env python3

import re
import os

def process_file(filename):
    """处理单个文件中的 IdentifierToken 引用"""
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 备份原文件
    with open(filename + '.backup', 'w', encoding='utf-8') as f:
        f.write(content)
    
    # 替换模式匹配中的 IdentifierToken
    content = re.sub(r'\| IdentifierToken ([a-zA-Z_][a-zA-Z0-9_]*) ->', r'| QuotedIdentifierToken \1 ->', content)
    
    # 替换构造函数调用
    content = re.sub(r'IdentifierToken\s*\(([^)]+)\)', r'QuotedIdentifierToken (\1)', content)
    
    # 替换 Lexer.IdentifierToken
    content = re.sub(r'Lexer\.IdentifierToken', r'Lexer.QuotedIdentifierToken', content)
    
    # 替换其他模式
    content = re.sub(r'IdentifierToken\s+([a-zA-Z_][a-zA-Z0-9_]*)', r'QuotedIdentifierToken \1', content)
    
    # 替换带引号的字符串
    content = re.sub(r'IdentifierToken\s*"([^"]+)"', r'QuotedIdentifierToken "\1"', content)
    
    # 写回文件
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"处理完成: {filename}")

# 需要处理的文件列表
files_to_process = [
    "src/Parser_statements.ml",
    "src/Parser_types.ml", 
    "src/Parser_expressions.ml",
    "src/parser.ml",
    "test/ascii_rejection.ml",
    "test/chinese_comments.ml",
    "test/chinese_expressions.ml",
    "test/step_by_step.ml",
    "test/test_issue_105_symbols.ml",
    "test/unit/test_parser.ml",
    "test/yyocamlc.ml"
]

for filename in files_to_process:
    if os.path.exists(filename):
        process_file(filename)
    else:
        print(f"文件不存在: {filename}")

print("批量替换完成")