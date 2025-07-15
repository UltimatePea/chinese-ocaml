#!/usr/bin/env python3
"""
Script to fix unquoted Chinese identifiers in test files.
Converts unquoted Chinese identifiers to quoted format 「identifier」.
"""

import re
import os
import sys

def is_chinese_char(char):
    """Check if a character is a Chinese character."""
    return '\u4e00' <= char <= '\u9fff'

def is_chinese_identifier(text):
    """Check if text is a Chinese identifier (contains Chinese characters)."""
    return any(is_chinese_char(char) for char in text)

def fix_unquoted_identifiers(content):
    """Fix unquoted Chinese identifiers in the content."""
    # Pattern to match Chinese identifiers that are not already quoted
    # Look for Chinese characters that are not surrounded by 「」
    
    # First, let's identify common patterns where Chinese identifiers appear
    patterns = [
        # Variable declarations: 让 identifier 为/作为
        (r'让\s+([^\s「」]+)\s+为', r'让 「\1」 为'),
        (r'让\s+([^\s「」]+)\s+作为', r'让 「\1」 作为'),
        
        # Function calls: 打印 identifier
        (r'打印\s+([^\s「」\n]+)', r'打印 「\1」'),
        
        # Variable references in expressions (more complex)
        # We'll handle these case by case
    ]
    
    modified_content = content
    
    for pattern, replacement in patterns:
        # Only replace if the identifier contains Chinese characters
        def replace_if_chinese(match):
            identifier = match.group(1)
            if is_chinese_identifier(identifier):
                return match.group(0).replace(identifier, f'「{identifier}」')
            return match.group(0)
        
        modified_content = re.sub(pattern, replace_if_chinese, modified_content)
    
    return modified_content

def fix_file(file_path):
    """Fix unquoted identifiers in a single file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Skip if file is empty or doesn't contain Chinese
        if not content or not any(is_chinese_char(char) for char in content):
            return False
        
        fixed_content = fix_unquoted_identifiers(content)
        
        if fixed_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            return True
            
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False
    
    return False

def main():
    """Main function to fix all test files."""
    test_dirs = [
        '/home/zc/chinese-ocaml-worktrees/chinese-ocaml/test',
        '/home/zc/chinese-ocaml-worktrees/chinese-ocaml/test/test_files'
    ]
    
    files_fixed = 0
    
    for test_dir in test_dirs:
        if not os.path.exists(test_dir):
            continue
            
        for root, dirs, files in os.walk(test_dir):
            for file in files:
                if file.endswith('.ml') or file.endswith('.ly'):
                    file_path = os.path.join(root, file)
                    if fix_file(file_path):
                        print(f"Fixed: {file_path}")
                        files_fixed += 1
    
    print(f"\nFixed {files_fixed} files")

if __name__ == "__main__":
    main()