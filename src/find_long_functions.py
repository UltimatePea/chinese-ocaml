#\!/usr/bin/env python3
import re
import os

def find_long_functions(filepath, min_lines=50):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        functions = []
        current_function = None
        
        for i, line in enumerate(lines):
            line = line.rstrip()
            
            # 检查是否是函数定义 (let rec 或 and)
            let_match = re.match(r'^let\s+(rec\s+)?(\w+).*=', line)
            and_match = re.match(r'^and\s+(\w+).*=', line)
            
            if let_match or and_match:
                # 如果之前有函数，结束它
                if current_function and current_function['end_line'] == -1:
                    current_function['end_line'] = i - 1
                
                # 开始新函数
                if let_match:
                    function_name = let_match.group(2)
                else:
                    function_name = and_match.group(1)
                    
                current_function = {
                    'name': function_name,
                    'start_line': i + 1,
                    'end_line': -1,
                    'file': filepath
                }
                functions.append(current_function)
            
            # 检查是否是下一个顶级定义
            elif line and not line.startswith(' ') and not line.startswith('\t'):
                if re.match(r'^(let|type|module|exception|open)', line):
                    if current_function and current_function['end_line'] == -1:
                        current_function['end_line'] = i - 1
                        current_function = None
        
        # 处理最后一个函数
        if current_function and current_function['end_line'] == -1:
            current_function['end_line'] = len(lines)
        
        # 筛选长函数
        long_functions = []
        for func in functions:
            if func['end_line'] != -1:
                length = func['end_line'] - func['start_line'] + 1
                if length >= min_lines:
                    long_functions.append({
                        'name': func['name'],
                        'start_line': func['start_line'],
                        'end_line': func['end_line'],
                        'length': length,
                        'file': func['file']
                    })
        
        return long_functions
    except Exception as e:
        return []

# 搜索所有ML文件
ml_files = []
for root, dirs, files in os.walk('.'):
    for file in files:
        if file.endswith('.ml'):
            ml_files.append(os.path.join(root, file))

all_long_functions = []
for filepath in ml_files:
    long_functions = find_long_functions(filepath)
    all_long_functions.extend(long_functions)

# 按长度排序
all_long_functions.sort(key=lambda x: x['length'], reverse=True)

print('超过50行的函数：')
for func in all_long_functions:
    print(f'{func["file"]}:{func["start_line"]}-{func["end_line"]} {func["name"]}() - {func["length"]}行')
