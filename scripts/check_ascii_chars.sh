#!/bin/bash

# 检查.ly文件中的ASCII字符脚本
# 用于CI检查确保所有.ly文件不包含禁用的ASCII字符

set -e

# 禁用的ASCII字符列表（来自Issue #201）
# 分别检查字母和符号
LETTERS_PATTERN='[A-Za-z]'
SYMBOLS_PATTERN='[!@#$%^&*()+\-=\[\]{}|:";'"'"'<>?,.\/`~_]'

echo "检查.ly文件中的禁用ASCII字符..."

# 渐进式迁移策略：临时允许现有文件包含ASCII字符
# 这些文件将在后续版本中逐步迁移到纯中文语法
# TODO: 随着迁移进展，逐步减少此列表直到为空
TEMPORARILY_ALLOWED_FILES=(
    "./AI友好语法示例.ly"
    "./AI友好语法工作示例.ly"
    "./简单AI友好示例.ly"
    "./标准库"
    "./test/test_files"
    "./性能测试"
    "./示例"
    "./自举"
    "./骆言编译器"
)

# 检查文件是否在临时允许列表中
is_temporarily_allowed() {
    local file="$1"
    for pattern in "${TEMPORARILY_ALLOWED_FILES[@]}"; do
        if [[ "$file" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

# 查找所有.ly文件
LY_FILES=$(find . -name "*.ly" -type f)

if [ -z "$LY_FILES" ]; then
    echo "警告: 未找到任何.ly文件"
    exit 0
fi

# 检查每个文件
VIOLATIONS_FOUND=0
ALLOWED_COUNT=0
CHECKED_COUNT=0

for file in $LY_FILES; do
    if is_temporarily_allowed "$file"; then
        echo "⏭️  临时跳过: $file (待后续迁移)"
        ALLOWED_COUNT=$((ALLOWED_COUNT + 1))
        continue
    fi
    
    CHECKED_COUNT=$((CHECKED_COUNT + 1))
    
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

echo ""
echo "📊 检查统计:"
echo "  - 检查的文件: $CHECKED_COUNT"
echo "  - 临时跳过的文件: $ALLOWED_COUNT"
echo "  - 总文件数: $(echo "$LY_FILES" | wc -l)"

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
    echo ""
    echo "📝 注意: 临时允许的文件将在后续版本中逐步迁移"
    exit 1
else
    if [ $CHECKED_COUNT -eq 0 ]; then
        echo "✅ 所有.ly文件都在临时允许列表中，跳过ASCII字符检查"
        echo "⚠️  注意: 这些文件需要在未来版本中迁移到纯中文语法"
    else
        echo "✅ 已检查的.ly文件通过ASCII字符检查"
        if [ $ALLOWED_COUNT -gt 0 ]; then
            echo "⚠️  注意: $ALLOWED_COUNT 个文件在临时允许列表中，需要后续迁移"
        fi
    fi
fi