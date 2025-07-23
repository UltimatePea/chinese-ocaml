#!/usr/bin/env python3
"""
批量为所有测试模块添加bisect_ppx覆盖率配置
"""

import re

def process_dune_file():
    with open('test/dune', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 找到所有test块
    # 使用更精确的正则表达式来匹配test块
    
    lines = content.split('\n')
    result_lines = []
    i = 0
    modified_count = 0
    
    while i < len(lines):
        line = lines[i]
        
        # 检查是否是test块的开始
        if line.strip().startswith('(test'):
            # 收集整个test块
            test_block = []
            test_block.append(line)
            paren_count = line.count('(') - line.count(')')
            i += 1
            
            while i < len(lines) and paren_count > 0:
                test_block.append(lines[i])
                paren_count += lines[i].count('(') - lines[i].count(')')
                i += 1
            
            # 检查是否需要添加bisect_ppx
            block_content = '\n'.join(test_block)
            
            if 'bisect_ppx' not in block_content and 'preprocess' not in block_content:
                # 需要添加bisect_ppx
                # 在最后一行之前插入preprocess配置
                if len(test_block) > 0 and test_block[-1].strip() == ')':
                    test_block.insert(-1, ' (preprocess')
                    test_block.insert(-1, '  (pps bisect_ppx))')
                    modified_count += 1
                    print(f"为测试模块添加了bisect_ppx配置")
            
            result_lines.extend(test_block)
        else:
            result_lines.append(line)
            i += 1
    
    # 写回文件
    with open('test/dune', 'w', encoding='utf-8') as f:
        f.write('\n'.join(result_lines))
    
    return modified_count

if __name__ == "__main__":
    count = process_dune_file()
    print(f"总共修改了 {count} 个测试模块")