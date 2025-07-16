#!/bin/bash

# 检查.ly文件中的ASCII字符脚本
# 用于CI检查确保所有.ly文件不包含禁用的ASCII字符

set -e

# 禁用的ASCII字符列表（来自Issue #201）
# 分别检查字母和符号
LETTERS_PATTERN='[A-Za-z]'
SYMBOLS_PATTERN='[!@#$%^&*()+\-=\[\]{}|:";'"'"'<>?,.\/`~_]'

echo "检查.ly文件中的禁用ASCII字符..."

# 查找所有.ly文件
LY_FILES=$(find . -name "*.ly" -type f)

if [ -z "$LY_FILES" ]; then
    echo "警告: 未找到任何.ly文件"
    exit 0
fi

# 检查每个文件
VIOLATIONS_FOUND=0

for file in $LY_FILES; do
    # 检查ASCII字母
    if grep -q "$LETTERS_PATTERN" "$file" 2>/dev/null; then
        echo "❌ 发现禁用的ASCII字母: $file"
        # 显示具体的违规行
        grep -n "$LETTERS_PATTERN" "$file" | head -5
        echo ""
        VIOLATIONS_FOUND=1
    fi
    
    # 检查ASCII符号
    if grep -q "$SYMBOLS_PATTERN" "$file" 2>/dev/null; then
        echo "❌ 发现禁用的ASCII符号: $file"
        # 显示具体的违规行
        grep -n "$SYMBOLS_PATTERN" "$file" | head -5
        echo ""
        VIOLATIONS_FOUND=1
    fi
done

if [ $VIOLATIONS_FOUND -eq 1 ]; then
    echo ""
    echo "❌ CI检查失败: 发现禁用的ASCII字符"
    echo "请移除.ly文件中的ASCII字符，禁用字符包括: A-Z a-z ! @ # $ % ^ & * ( ) + - = [ ] { } | : \" ; ' < > ? , . / \` ~ _"
    echo ""
    echo "允许的字符:"
    echo "  - 中文汉字"
    echo "  - 中文标点符号：「」『』：，。（）"
    echo "  - 阿拉伯数字：0-9 (仅半角)"
    echo "  - 空格和换行符"
    exit 1
else
    echo "✅ 所有.ly文件检查通过，未发现禁用的ASCII字符"
fi