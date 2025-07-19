#!/usr/bin/env python3
"""
诗词数据提取脚本
将硬编码在OCaml文件中的诗词数据提取为JSON格式

@author 骆言诗词编程团队
@version 1.0
@since 2025-07-19
"""

import re
import json
import os
from pathlib import Path

def extract_list_data(file_content, list_name):
    """从OCaml源代码中提取列表数据"""
    # 匹配形如 let list_name = [ ... ] 的模式
    pattern = rf'{list_name}\s*=\s*\[(.*?)\]'
    match = re.search(pattern, file_content, re.DOTALL)
    
    if not match:
        return []
    
    list_content = match.group(1)
    
    # 提取 ("word", Class) 格式的条目
    word_pattern = r'\("([^"]+)",\s*(\w+)\)'
    words = []
    
    for match in re.finditer(word_pattern, list_content):
        word = match.group(1)
        word_class = match.group(2)
        words.append({"word": word, "class": word_class})
    
    return words

def extract_all_data():
    """提取所有诗词数据"""
    
    # 源文件路径
    src_file = Path('../src/poetry/data/expanded_word_class_data.ml')
    
    if not src_file.exists():
        print(f"源文件不存在: {src_file}")
        return
    
    # 读取源文件
    with open(src_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 要提取的数据列表
    data_lists = {
        'person_relation_nouns': '人物称谓',
        'social_status_nouns': '社会地位',
        'building_place_nouns': '建筑场所',
        'geography_politics_nouns': '地理政治',
        'tools_objects_nouns': '器物用具'
    }
    
    # 创建输出目录
    output_dir = Path('../data/poetry')
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # 提取每个列表的数据
    all_data = {}
    
    for list_name, description in data_lists.items():
        print(f"正在提取 {list_name} ({description})...")
        words = extract_list_data(content, list_name)
        print(f"  提取到 {len(words)} 个词条")
        
        all_data[list_name] = {
            'description': description,
            'words': words
        }
        
        # 保存单独的JSON文件
        output_file = output_dir / f'{list_name}.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(words, f, ensure_ascii=False, indent=2)
        print(f"  已保存到 {output_file}")
    
    # 保存合并的完整数据文件
    complete_file = output_dir / 'complete_word_class_data.json'
    with open(complete_file, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)
    print(f"\n完整数据已保存到 {complete_file}")
    
    # 统计信息
    total_words = sum(len(data['words']) for data in all_data.values())
    print(f"\n总计提取 {total_words} 个词条")
    
    return all_data

if __name__ == '__main__':
    print("开始提取诗词数据...")
    extract_all_data()
    print("数据提取完成！")