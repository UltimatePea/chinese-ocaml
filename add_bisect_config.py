#!/usr/bin/env python3
"""
脚本功能：为test/dune文件中缺少bisect_ppx配置的测试添加配置
Fix #998: 测试覆盖率优化提升计划
"""

import re
import sys

def add_bisect_ppx_to_tests(file_path):
    """为所有测试添加bisect_ppx配置"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 查找所有test块，但排除已经有bisect_ppx配置的
    test_pattern = r'(\(test\n[^)]*?\n\s+\(libraries[^)]*?\))\n(\s*\(preprocess)?'
    
    def replace_test(match):
        test_block = match.group(1)
        preprocess_part = match.group(2)
        
        # 如果已经有preprocess配置，不修改
        if preprocess_part:
            return match.group(0)
        
        # 添加bisect_ppx配置
        return test_block + '\n (preprocess\n  (pps bisect_ppx))'
    
    # 更简单的方法：查找test块并添加配置
    lines = content.split('\n')
    result_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        result_lines.append(line)
        
        # 检查是否是test块开始
        if line.strip().startswith('(test'):
            # 查找这个test块的结束位置和libraries配置
            j = i + 1
            libraries_found = False
            preprocess_found = False
            
            while j < len(lines) and not (lines[j].strip().startswith('(') and not lines[j].strip().startswith('(')):
                result_lines.append(lines[j])
                
                if 'libraries' in lines[j]:
                    libraries_found = True
                if 'preprocess' in lines[j] and 'bisect_ppx' in lines[j]:
                    preprocess_found = True
                
                # 如果找到了libraries行且没有preprocess配置
                if libraries_found and ')' in lines[j] and not preprocess_found:
                    # 检查接下来几行是否有preprocess
                    next_has_preprocess = False
                    for k in range(j+1, min(j+5, len(lines))):
                        if k < len(lines) and 'preprocess' in lines[k]:
                            next_has_preprocess = True
                            break
                    
                    if not next_has_preprocess:
                        # 添加bisect_ppx配置
                        result_lines.append(' (preprocess')
                        result_lines.append('  (pps bisect_ppx))')
                    break
                
                j += 1
            
            i = j
        else:
            i += 1
    
    return '\n'.join(result_lines)

def main():
    file_path = '/home/zc/chinese-ocaml-worktrees/chinese-ocaml/test/dune'
    
    try:
        updated_content = add_bisect_ppx_to_tests(file_path)
        
        # 写回文件
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        
        print("✅ 成功为test/dune文件中的测试添加bisect_ppx配置")
        
    except Exception as e:
        print(f"❌ 处理文件出错: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()