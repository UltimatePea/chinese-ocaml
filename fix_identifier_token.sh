#!/bin/bash

# 修复所有 IdentifierToken 引用的脚本

# 获取包含 IdentifierToken 的所有文件
files=$(grep -r "IdentifierToken" src/ test/ --include="*.ml" --include="*.mli" | cut -d: -f1 | sort -u)

echo "找到以下包含 IdentifierToken 的文件:"
echo "$files"

# 针对每个文件，我们需要手动分析并修复
for file in $files; do
    echo "处理文件: $file"
    # 先备份文件
    cp "$file" "$file.bak"
done

echo "所有文件已备份，需要手动修复每个文件中的 IdentifierToken 引用"