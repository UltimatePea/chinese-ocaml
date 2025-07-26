#!/usr/bin/env python3
"""
测试复杂度计算的具体问题
"""

import sys
sys.path.append('/home/zc/chinese-ocaml-worktrees/chinese-ocaml/scripts/analysis')

from ast_based_analysis import ASTBasedAnalyzer

def test_complexity_calculation():
    analyzer = ASTBasedAnalyzer("/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src")
    
    # 问题测试用例
    test_cases = [
        ("let multi_match x = match x with | 1 -> \"一\" | 2 -> \"二\" | _ -> \"其他\"", 4),
        ("let complex x = if x > 0 then match x with | 1 -> \"一\" | _ -> \"其他\" else \"负数\"", 4),
    ]
    
    for i, (test_code, expected) in enumerate(test_cases, 1):
        print(f"测试用例 {i}:")
        print(f"代码: {test_code}")
        print(f"期望复杂度: {expected}")
        
        lines = test_code.split('\n')
        actual = analyzer.calculate_cyclomatic_complexity(lines)
        print(f"实际复杂度: {actual}")
        
        # 调试复杂度计算过程
        print("分析过程:")
        complexity = 1
        in_match_block = False
        
        for line in lines:
            stripped = line.strip()
            print(f"  行: '{stripped}'")
            
            # 条件分支
            if re.search(r'\bif\b', stripped) and not re.search(r'#if', stripped):
                complexity += 1
                print(f"    -> if语句 +1, 当前复杂度: {complexity}")
            
            # 模式匹配
            if re.search(r'\bmatch\b.*\bwith\b', stripped):
                in_match_block = True
                print(f"    -> match开始")
            elif in_match_block and stripped.startswith('|') and not stripped.startswith('||'):
                complexity += 1
                print(f"    -> match分支 +1, 当前复杂度: {complexity}")
            elif in_match_block and not stripped.startswith('|') and stripped and not stripped.startswith('(*'):
                if not re.search(r'\b(match|if|let|for|while|try)\b', stripped):
                    in_match_block = False
                    print(f"    -> match结束")
        
        print(f"最终复杂度: {complexity}")
        print(f"是否正确: {'✅' if abs(actual - expected) <= 1 else '❌'}")
        print()

if __name__ == "__main__":
    import re
    test_complexity_calculation()