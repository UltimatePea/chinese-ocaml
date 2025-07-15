#!/usr/bin/env python3

import re
import os

def fix_file(filename):
    """修复 QuotedQuotedIdentifierToken 错误"""
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 替换双重引用的问题
    content = re.sub(r'QuotedQuotedIdentifierToken', r'QuotedIdentifierToken', content)
    
    # 写回文件
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"修复完成: {filename}")

# 需要修复的文件列表
files_to_fix = [
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

for filename in files_to_fix:
    if os.path.exists(filename):
        fix_file(filename)
    else:
        print(f"文件不存在: {filename}")

print("修复完成")