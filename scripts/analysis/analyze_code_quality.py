#!/usr/bin/env python3
"""
分析骆言项目代码质量，重点关注诗词编程特性
"""

import os
import re
import subprocess
from pathlib import Path
from collections import defaultdict, Counter

class CodeQualityAnalyzer:
    def __init__(self, root_dir):
        self.root_dir = Path(root_dir)
        self.long_functions = []
        self.repeated_patterns = defaultdict(list)
        self.module_issues = []
        self.poetry_issues = []
        self.documentation_gaps = []
        
    def analyze_function_length(self, file_path):
        """分析函数长度，找出超过50行的函数"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # OCaml函数定义模式
            function_patterns = [
                r'let\s+(\w+).*?=',  # let函数
                r'let\s+rec\s+(\w+).*?=',  # let rec函数
            ]
            
            lines = content.split('\n')
            current_function = None
            function_start = 0
            indent_level = 0
            in_function = False
            
            for i, line in enumerate(lines):
                stripped = line.strip()
                
                # 检测函数开始
                for pattern in function_patterns:
                    match = re.search(pattern, stripped)
                    if match:
                        if current_function and in_function:
                            # 结束上一个函数
                            func_length = i - function_start
                            if func_length > 50:
                                self.long_functions.append({
                                    'file': file_path,
                                    'function': current_function,
                                    'start_line': function_start + 1,
                                    'end_line': i,
                                    'length': func_length
                                })
                        
                        current_function = match.group(1)
                        function_start = i
                        in_function = True
                        indent_level = len(line) - len(line.lstrip())
                        break
                
                # 检测函数结束 (简化版本，基于缩进)
                if in_function and stripped and not stripped.startswith('(*'):
                    current_indent = len(line) - len(line.lstrip())
                    if current_indent <= indent_level and i > function_start + 5:
                        if any(keyword in stripped for keyword in ['let', 'type', 'module', 'exception']):
                            func_length = i - function_start
                            if func_length > 50:
                                self.long_functions.append({
                                    'file': file_path,
                                    'function': current_function,
                                    'start_line': function_start + 1,
                                    'end_line': i,
                                    'length': func_length
                                })
                            in_function = False
                            current_function = None
            
            # 处理文件末尾的函数
            if current_function and in_function:
                func_length = len(lines) - function_start
                if func_length > 50:
                    self.long_functions.append({
                        'file': file_path,
                        'function': current_function,
                        'start_line': function_start + 1,
                        'end_line': len(lines),
                        'length': func_length
                    })
                    
        except Exception as e:
            print(f"分析文件时出错 {file_path}: {e}")
    
    def analyze_repeated_patterns(self, file_path):
        """分析重复的代码模式"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 查找重复的模式匹配
            pattern_matches = re.findall(r'match\s+\w+\s+with\s*\|.*?(?=\n\s*(?:let|type|module|$))', 
                                       content, re.DOTALL)
            
            for pattern in pattern_matches:
                normalized = re.sub(r'\s+', ' ', pattern.strip())
                if len(normalized) > 100:  # 只关注较长的模式
                    self.repeated_patterns[normalized].append(file_path)
                    
        except Exception as e:
            print(f"分析重复模式时出错 {file_path}: {e}")
    
    def analyze_module_organization(self, file_path):
        """分析模块组织和命名"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            filename = os.path.basename(file_path)
            
            # 检查模块命名规范
            if filename.startswith('test_') or filename.startswith('debug_'):
                return  # 跳过测试和调试文件
                
            # 检查是否有过多的公开函数（没有.mli文件的情况）
            mli_path = str(file_path).replace('.ml', '.mli')
            if not os.path.exists(mli_path):
                let_count = len(re.findall(r'^let\s+(?!.*\bin\b)', content, re.MULTILINE))
                if let_count > 20:
                    self.module_issues.append({
                        'file': file_path,
                        'issue': '缺少接口文件且函数过多',
                        'detail': f'包含{let_count}个let绑定但没有.mli文件'
                    })
            
            # 检查模块内部组织
            lines = content.split('\n')
            type_defs = []
            functions = []
            
            for i, line in enumerate(lines):
                if re.match(r'^\s*type\s+', line):
                    type_defs.append(i)
                elif re.match(r'^\s*let\s+', line):
                    functions.append(i)
            
            # 检查类型定义是否在函数之前
            if type_defs and functions:
                if any(f < max(type_defs) for f in functions):
                    self.module_issues.append({
                        'file': file_path,
                        'issue': '类型定义和函数定义混合',
                        'detail': '建议将类型定义放在文件开头'
                    })
                    
        except Exception as e:
            print(f"分析模块组织时出错 {file_path}: {e}")
    
    def analyze_poetry_module(self, file_path):
        """专门分析诗词模块的代码质量"""
        if 'poetry' not in str(file_path):
            return
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            filename = os.path.basename(file_path)
            
            # 检查诗词模块特定问题
            
            # 1. 检查是否有中文注释
            chinese_comments = re.findall(r'\(\*.*?[\u4e00-\u9fff].*?\*\)', content, re.DOTALL)
            if not chinese_comments and '词性' in filename or '韵律' in filename or 'tone' in filename or 'rhyme' in filename:
                self.poetry_issues.append({
                    'file': file_path,
                    'issue': '缺少中文注释',
                    'detail': '诗词相关模块应该有详细的中文注释说明'
                })
            
            # 2. 检查硬编码数据
            if 'data' in filename or 'database' in filename:
                lines = content.split('\n')
                data_lines = [l for l in lines if '"' in l and '=' in l]
                if len(data_lines) > 100:
                    self.poetry_issues.append({
                        'file': file_path,
                        'issue': '大量硬编码数据',
                        'detail': f'发现{len(data_lines)}行硬编码数据，建议考虑外部文件存储'
                    })
            
            # 3. 检查函数复杂度
            complex_functions = re.findall(r'let\s+(\w+).*?(?=let|\Z)', content, re.DOTALL)
            for func in complex_functions:
                if func.count('match') > 3:
                    self.poetry_issues.append({
                        'file': file_path,
                        'issue': '函数复杂度过高',
                        'detail': f'函数包含多个match表达式，建议拆分'
                    })
            
        except Exception as e:
            print(f"分析诗词模块时出错 {file_path}: {e}")
    
    def analyze_documentation_gaps(self, file_path):
        """分析文档缺失"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 检查是否有模块级注释
            if not re.search(r'^\(\*.*?\*\)', content, re.DOTALL | re.MULTILINE):
                if 'poetry' in str(file_path) or 'Parser_poetry' in str(file_path):
                    self.documentation_gaps.append({
                        'file': file_path,
                        'issue': '缺少模块级文档',
                        'detail': '诗词编程相关模块应该有详细的模块级说明'
                    })
            
            # 检查复杂函数是否有注释
            functions = re.findall(r'(let\s+(?:rec\s+)?(\w+).*?)(?=\nlet|\ntype|\nmodule|\Z)', 
                                 content, re.DOTALL)
            
            for func_content, func_name in functions:
                if len(func_content.split('\n')) > 20:  # 长函数
                    if not re.search(r'\(\*.*?\*\)', func_content, re.DOTALL):
                        if 'poetry' in str(file_path) or 'rhyme' in func_name or 'tone' in func_name:
                            self.documentation_gaps.append({
                                'file': file_path,
                                'issue': f'复杂函数{func_name}缺少文档',
                                'detail': '诗词分析函数应该有详细的中文说明'
                            })
                            
        except Exception as e:
            print(f"分析文档缺失时出错 {file_path}: {e}")
    
    def analyze_chinese_language_features(self, file_path):
        """分析中文语言特性使用情况"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 检查是否使用了英文标识符在中文语境中
            english_identifiers = re.findall(r'let\s+([a-zA-Z][a-zA-Z0-9_]*)\s*=', content)
            chinese_context_files = ['poetry', 'rhyme', 'tone', 'artistic']
            
            if any(keyword in str(file_path) for keyword in chinese_context_files):
                if len(english_identifiers) > 5:
                    self.poetry_issues.append({
                        'file': file_path,
                        'issue': '中文语境中使用过多英文标识符',
                        'detail': f'在诗词相关模块中发现{len(english_identifiers)}个英文函数名'
                    })
                    
        except Exception as e:
            print(f"分析中文语言特性时出错 {file_path}: {e}")
    
    def run_analysis(self):
        """运行完整分析"""
        print("开始代码质量分析...")
        
        # 分析所有.ml文件
        for ml_file in self.root_dir.rglob("*.ml"):
            if 'test' in str(ml_file) or '_build' in str(ml_file) or '临时' in str(ml_file):
                continue
                
            print(f"分析文件: {ml_file}")
            
            self.analyze_function_length(ml_file)
            self.analyze_repeated_patterns(ml_file)
            self.analyze_module_organization(ml_file)
            self.analyze_poetry_module(ml_file)
            self.analyze_documentation_gaps(ml_file)
            self.analyze_chinese_language_features(ml_file)
    
    def generate_report(self):
        """生成分析报告"""
        report = []
        report.append("# 骆言项目代码质量分析报告")
        report.append(f"分析时间: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        # 1. 超长函数分析
        report.append("## 1. 超长函数分析（超过50行）")
        if self.long_functions:
            self.long_functions.sort(key=lambda x: x['length'], reverse=True)
            for func in self.long_functions[:10]:  # 显示前10个最长的函数
                report.append(f"- **{func['function']}** ({func['file']}:{func['start_line']}-{func['end_line']})")
                report.append(f"  - 长度: {func['length']}行")
                report.append(f"  - 建议: 考虑拆分为多个小函数")
                report.append("")
        else:
            report.append("✅ 未发现超过50行的函数")
        report.append("")
        
        # 2. 模块组织问题
        report.append("## 2. 模块组织问题")
        if self.module_issues:
            for issue in self.module_issues:
                report.append(f"- **{issue['issue']}** ({issue['file']})")
                report.append(f"  - 详情: {issue['detail']}")
                report.append("")
        else:
            report.append("✅ 模块组织良好")
        report.append("")
        
        # 3. 重复代码模式
        report.append("## 3. 重复代码模式")
        repeated = {k: v for k, v in self.repeated_patterns.items() if len(v) > 1}
        if repeated:
            for pattern, files in list(repeated.items())[:5]:  # 显示前5个
                report.append(f"- 重复模式出现在 {len(files)} 个文件中:")
                for file in files:
                    report.append(f"  - {file}")
                report.append("")
        else:
            report.append("✅ 未发现明显的重复代码模式")
        report.append("")
        
        # 4. 诗词模块特定问题
        report.append("## 4. 诗词编程模块分析")
        if self.poetry_issues:
            for issue in self.poetry_issues:
                report.append(f"- **{issue['issue']}** ({issue['file']})")
                report.append(f"  - 详情: {issue['detail']}")
                report.append("")
        else:
            report.append("✅ 诗词模块质量良好")
        report.append("")
        
        # 5. 文档缺失
        report.append("## 5. 文档缺失分析")
        if self.documentation_gaps:
            for gap in self.documentation_gaps:
                report.append(f"- **{gap['issue']}** ({gap['file']})")
                report.append(f"  - 详情: {gap['detail']}")
                report.append("")
        else:
            report.append("✅ 文档覆盖良好")
        report.append("")
        
        # 6. 改进建议
        report.append("## 6. 总体改进建议")
        report.append("")
        report.append("### 优先级1 - 立即修复")
        if self.long_functions:
            report.append("- 重构超长函数，提高代码可读性")
        if any('缺少中文注释' in issue['issue'] for issue in self.poetry_issues):
            report.append("- 为诗词相关模块添加详细的中文注释")
            
        report.append("")
        report.append("### 优先级2 - 近期改进")
        if self.module_issues:
            report.append("- 完善模块接口文件(.mli)")
        if self.documentation_gaps:
            report.append("- 补充缺失的函数和模块文档")
            
        report.append("")
        report.append("### 优先级3 - 长期优化")
        report.append("- 考虑提取诗词数据到外部配置文件")
        report.append("- 增强诗词编程特性的艺术表现力")
        report.append("- 实现更智能的中文语言处理")
        
        return '\n'.join(report)

def main():
    analyzer = CodeQualityAnalyzer('/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src')
    analyzer.run_analysis()
    report = analyzer.generate_report()
    
    # 保存报告
    with open('/home/zc/chinese-ocaml-worktrees/chinese-ocaml/code_quality_analysis_report.md', 'w', encoding='utf-8') as f:
        f.write(report)
    
    print("\n" + "="*60)
    print("分析完成！报告已保存到 code_quality_analysis_report.md")
    print("="*60)
    print(report)

if __name__ == "__main__":
    main()