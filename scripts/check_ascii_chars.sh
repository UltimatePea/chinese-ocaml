#!/bin/bash

# 检查.ly文件中的ASCII字符脚本
# 用于CI检查确保所有.ly文件不包含禁用的ASCII字符
# 根据维护者指示：一步到位清理，但允许注释中的英文

set -e

# 禁用的ASCII字符列表（来自Issue #201）
# 分别检查字母和符号
LETTERS_PATTERN='[A-Za-z]'
SYMBOLS_PATTERN='[!@#$%^&*()+\-=\[\]{}|:";'"'"'<>?,.\/`~_]'

echo "检查.ly文件中的禁用ASCII字符..."
echo "📝 注意: 允许注释中使用英文字符"

# 检查非注释行中的ASCII字符
check_non_comment_ascii() {
    local file="$1"
    local pattern="$2"
    local type="$3"
    
    # 使用sed移除注释行（以#开头的行和//开头的行以及(*...*)注释）
    # 然后检查剩余内容是否包含ASCII字符
    local content=$(sed 's/\/\/.*$//' "$file" | sed 's/#.*$//' | sed 's/(\*.*\*)//' | grep -v '^[[:space:]]*$')
    
    if echo "$content" | grep -q "$pattern" 2>/dev/null; then
        echo "❌ 发现禁用的ASCII$type: $file"
        # 显示具体的违规行（排除注释）
        local line_num=1
        while IFS= read -r line; do
            # 跳过注释行
            if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ ! "$line" =~ ^[[:space:]]*// ]] && [[ ! "$line" =~ ^\* ]]; then
                local clean_line=$(echo "$line" | sed 's/\/\/.*$//' | sed 's/#.*$//' | sed 's/(\*.*\*)//')
                if echo "$clean_line" | grep -q "$pattern" 2>/dev/null; then
                    echo "  第$line_num行: $line"
                fi
            fi
            ((line_num++))
        done < "$file" | head -5
        echo ""
        return 0
    fi
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
CHECKED_COUNT=0

for file in $LY_FILES; do
    CHECKED_COUNT=$((CHECKED_COUNT + 1))
    
    # 检查非注释行中的ASCII字母
    if check_non_comment_ascii "$file" "$LETTERS_PATTERN" "字母"; then
        VIOLATIONS_FOUND=1
    fi
    
    # 检查非注释行中的ASCII符号
    if check_non_comment_ascii "$file" "$SYMBOLS_PATTERN" "符号"; then
        VIOLATIONS_FOUND=1
    fi
done

echo ""
echo "📊 检查统计:"
echo "  - 检查的文件: $CHECKED_COUNT"
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
    echo "  - 注释中的英文字符"
    echo ""
    exit 1
else
    echo "✅ 所有.ly文件都通过ASCII字符检查（注释中的英文已被忽略）"
fi