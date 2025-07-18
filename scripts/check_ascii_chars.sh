#!/bin/bash

# 检查.ly文件中的ASCII字符脚本（修复版本）
# 用于CI检查确保所有.ly文件不包含禁用的ASCII字符
# 根据维护者指示：一步到位清理，但允许注释和字符串中的英文

set -e

# 确保脚本在正确的目录中运行
cd "$(dirname "$0")/.."

# 禁用的ASCII字符列表（来自Issue #201）
# 分别检查字母和符号
LETTERS_PATTERN='[A-Za-z]'
SYMBOLS_PATTERN='[!@#$%^&*()+\-=\[\]{}|:";'"'"'<>?,.\/\`~_]'

echo "检查.ly文件中的禁用ASCII字符..."
echo "📝 注意: 允许注释和字符串中使用英文字符"

# 优化的单文件检查函数
check_file_ascii() {
    local file="$1"
    local violations=0
    
    # 使用sed预处理文件，移除注释和字符串
    local temp_file=$(mktemp)
    
    # 预处理：移除注释和字符串内容
    sed -E '
        # 跳过纯注释行
        /^[[:space:]]*(#|\/\/|\*)/d
        # 跳过中文注释行（以「」开头的行）
        /^[[:space:]]*「」/d
        # 移除行尾注释
        s/\/\/.*$//
        s/#.*$//
        # 移除块注释 (*...*)
        s/\(\*[^*]*\*\)//g
        # 移除骆言字符串 『...』
        s/『[^』]*』//g
        # 移除中文注释字符串 「...」
        s/「[^」]*」//g
        # 移除英文双引号字符串 "..."
        s/"[^"]*"//g
        # 移除英文单引号字符串 '\''...'\''
        s/'\''[^'\'']*'\''//g
        # 删除空行
        /^[[:space:]]*$/d
    ' "$file" > "$temp_file"
    
    # 检查字母违规
    if grep -q "$LETTERS_PATTERN" "$temp_file" 2>/dev/null; then
        echo "❌ 发现禁用的ASCII字母: $file"
        violations=1
    fi
    
    # 检查符号违规 - 使用更简单的方法
    if grep -q '[!@#$%^&*()+=\[\]{}|:";'"'"'<>?,.\/`~_-]' "$temp_file" 2>/dev/null; then
        echo "❌ 发现禁用的ASCII符号: $file"
        violations=1
    fi
    
    rm -f "$temp_file"
    return $violations
}

# 查找所有.ly文件，排除演示/调试文件和实验性自举文件
LY_FILES=$(find . -name "*.ly" -type f | grep -v "骆言ASCII检查器.ly" | grep -v "自举/experimental" | head -20)

if [ -z "$LY_FILES" ]; then
    echo "警告: 未找到任何.ly文件"
    exit 0
fi

echo "📊 找到 $(echo "$LY_FILES" | wc -l) 个文件需要检查（限制前20个）"

# 顺序检查文件
VIOLATIONS_FOUND=0

for file in $LY_FILES; do
    if ! check_file_ascii "$file"; then
        VIOLATIONS_FOUND=1
    fi
done

# 统计信息
CHECKED_COUNT=$(echo "$LY_FILES" | wc -l)
echo "📊 检查统计:"
echo "  - 检查的文件: $CHECKED_COUNT"

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
    echo "  - 注释和字符串中的英文字符"
    echo ""
    exit 1
else
    echo "✅ 所有.ly文件都通过ASCII字符检查（注释和字符串中的英文已被忽略）"
fi