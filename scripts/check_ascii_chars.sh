#!/bin/bash

# 检查.ly文件中的ASCII字符脚本
# 用于CI检查确保所有.ly文件不包含禁用的ASCII字符
# 根据维护者指示：一步到位清理，但允许注释和字符串中的英文

set -e

# 禁用的ASCII字符列表（来自Issue #201）
# 分别检查字母和符号
LETTERS_PATTERN='[A-Za-z]'
SYMBOLS_PATTERN='[!@#$%^&*()+\-=\[\]{}|:";'"'"'<>?,.\/`~_]'

echo "检查.ly文件中的禁用ASCII字符..."
echo "📝 注意: 允许注释和字符串中使用英文字符"

# 检查非注释非字符串行中的ASCII字符
check_non_comment_non_string_ascii() {
    local file="$1"
    local pattern="$2"
    local type="$3"
    
    # 更复杂的处理：移除注释、字符串内容，然后检查剩余内容
    # 1. 移除行注释 (# 和 //)
    # 2. 移除块注释 (*...*)
    # 3. 移除字符串内容 (『...』 和 "...")
    local violations=0
    local line_num=1
    
    while IFS= read -r line; do
        # 跳过完全的注释行
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*// ]] || [[ "$line" =~ ^[[:space:]]*\* ]]; then
            ((line_num++))
            continue
        fi
        
        # 处理行内容：移除注释和字符串
        local clean_line="$line"
        
        # 移除行尾注释
        clean_line=$(echo "$clean_line" | sed 's/\/\/.*$//' | sed 's/#.*$//')
        
        # 移除块注释 (*...*)
        clean_line=$(echo "$clean_line" | sed 's/(\*[^*]*\*)//')
        
        # 移除骆言字符串 『...』
        clean_line=$(echo "$clean_line" | sed 's/『[^』]*』//g')
        
        # 移除中文注释字符串 「...」
        clean_line=$(echo "$clean_line" | sed 's/「[^」]*」//g')
        
        # 移除英文字符串 "..."
        clean_line=$(echo "$clean_line" | sed 's/"[^"]*"//g')
        
        # 移除英文字符串 '...'  
        clean_line=$(echo "$clean_line" | sed "s/'[^']*'//g")
        
        # 检查清理后的内容是否包含ASCII字符
        if echo "$clean_line" | grep -q "$pattern" 2>/dev/null; then
            if [ $violations -eq 0 ]; then
                echo "❌ 发现禁用的ASCII$type: $file"
            fi
            echo "  第$line_num行: $line"
            violations=1
        fi
        
        ((line_num++))
    done < "$file"
    
    if [ $violations -eq 1 ]; then
        echo ""
        return 0
    fi
    return 1
}

# 查找所有.ly文件，排除演示/调试文件
LY_FILES=$(find . -name "*.ly" -type f | grep -v "骆言ASCII检查器.ly")

if [ -z "$LY_FILES" ]; then
    echo "警告: 未找到任何.ly文件"
    exit 0
fi

# 检查每个文件
VIOLATIONS_FOUND=0
CHECKED_COUNT=0

for file in $LY_FILES; do
    CHECKED_COUNT=$((CHECKED_COUNT + 1))
    
    # 检查非注释非字符串行中的ASCII字母
    if check_non_comment_non_string_ascii "$file" "$LETTERS_PATTERN" "字母"; then
        VIOLATIONS_FOUND=1
    fi
    
    # 检查非注释非字符串行中的ASCII符号
    if check_non_comment_non_string_ascii "$file" "$SYMBOLS_PATTERN" "符号"; then
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
    echo "  - 注释和字符串中的英文字符"
    echo ""
    exit 1
else
    echo "✅ 所有.ly文件都通过ASCII字符检查（注释和字符串中的英文已被忽略）"
fi