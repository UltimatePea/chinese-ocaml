#!/usr/bin/env python3
"""
古雅体列表迁移脚本
将现代列表语法 [1,2,3] 转换为古雅体语法 列开始 1 其一 2 其二 3 其三 列结束
"""

import re
import glob
import sys

def convert_list_to_ancient(match):
    """将现代列表语法转换为古雅体语法"""
    # 支持方括号和中文方括号
    content = match.group(1) if match.group(1) is not None else match.group(2)
    if content is None:
        content = ""
    content = content.strip()

    # 处理空列表
    if not content:
        return "空空如也"

    # 分割元素（支持逗号、分号、中文逗号分隔）
    elements = re.split(r'[,;，、]', content)
    elements = [elem.strip() for elem in elements if elem.strip()]

    if not elements:
        return "空空如也"

    # 构建古雅体列表
    result = "列开始"

    for i, element in enumerate(elements):
        result += f" {element}"
        # 添加序数标记
        if i == 0:
            result += " 其一"
        elif i == 1:
            result += " 其二"
        elif i == 2:
            result += " 其三"
        else:
            # 对于更多元素，根据parser实现，都使用其一
            result += " 其一"

    result += " 列结束"
    # 为了兼容文言语法，在古雅体列表表达式周围添加括号
    return f"({result})"

def convert_pattern_to_ancient(match):
    """将现代模式匹配转换为古雅体"""
    content = match.group(1).strip()

    # 处理空列表模式
    if not content:
        return "空空如也"

    # 处理 [x, ...rest] 模式
    spread_match = re.match(r'([^,]+),?\s*\.\.\.(.+)', content)
    if spread_match:
        head = spread_match.group(1).strip()
        tail = spread_match.group(2).strip()
        return f"有首有尾 首名为{head} 尾名为{tail}"

    # 其他模式使用常规转换
    return convert_list_to_ancient(match)

def migrate_file_content(content):
    """迁移文件内容中的列表语法"""
    original_content = content

    # 1. 首先处理模式匹配中的 [head, ...tail] 特殊情况
    def convert_head_tail_pattern(match):
        inner_content = match.group(1).strip()
        # 检查是否包含 ... (spread pattern)
        if '...' in inner_content:
            parts = inner_content.split('...')
            if len(parts) == 2:
                head_part = parts[0].strip().rstrip(',').strip()
                tail_part = parts[1].strip()
                # 确保使用「」包围变量名
                if not head_part.startswith('「') and not head_part.startswith('『'):
                    head_part = f'「{head_part}」'
                if not tail_part.startswith('「') and not tail_part.startswith('『'):
                    tail_part = f'「{tail_part}」'
                return f"有首有尾 首名为{head_part} 尾名为{tail_part}"
        # 否则使用常规转换
        return convert_list_to_ancient(match)

    # 先处理可能的head-tail模式
    content = re.sub(r'\[([^\[\]]*\.\.\.+[^\[\]]*)\]', convert_head_tail_pattern, content)

    # 2. 转换普通方括号列表 [...]
    content = re.sub(r'\[([^\[\]]*)\]', convert_list_to_ancient, content)

    # 3. 转换中文方括号列表 【...】
    content = re.sub(r'【([^【】]*)】', convert_list_to_ancient, content)

    return content, content != original_content

def migrate_file(file_path):
    """迁移单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        migrated_content, changed = migrate_file_content(content)

        if changed:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(migrated_content)
            print(f"✅ 已迁移: {file_path}")
            return True
        else:
            print(f"📋 无需迁移: {file_path}")
            return False

    except Exception as e:
        print(f"❌ 迁移文件 {file_path} 时出错: {e}")
        return False

def main():
    """主函数"""
    if len(sys.argv) > 1 and sys.argv[1] == '--test':
        # 测试模式
        test_cases = [
            ("[1, 2, 3]", "列开始 1 其一 2 其二 3 其三 列结束"),
            ("[]", "空空如也"),
            ("[1]", "列开始 1 其一 列结束"),
            ("[a, b, c, d]", "列开始 a 其一 b 其二 c 其三 d 其一 列结束"),
            ("【1，2，3】", "列开始 1 其一 2 其二 3 其三 列结束"),
        ]

        print("🧪 测试古雅体列表转换...")
        for input_text, expected in test_cases:
            # 模拟正则匹配
            match = re.search(r'\[([^\[\]]*)\]|【([^【】]*)】', input_text)
            if match:
                result = convert_list_to_ancient(match)
                status = "✅" if result == expected else "❌"
                print(f"{status} '{input_text}' -> '{result}'")
                if result != expected:
                    print(f"   期望: '{expected}'")
        return

    # 获取所有.ly文件
    ly_files = glob.glob("/home/zc/chinese-ocaml/**/*.ly", recursive=True)

    migrated_count = 0
    total_count = len(ly_files)

    print(f"🔄 开始迁移 {total_count} 个 .ly 文件到古雅体列表语法...")

    for file_path in ly_files:
        if migrate_file(file_path):
            migrated_count += 1

    print(f"\n📊 迁移完成!")
    print(f"总文件数: {total_count}")
    print(f"已迁移文件数: {migrated_count}")
    print(f"未更改文件数: {total_count - migrated_count}")

if __name__ == "__main__":
    main()