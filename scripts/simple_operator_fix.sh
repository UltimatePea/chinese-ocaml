#!/bin/bash

# 简单的ASCII运算符修复脚本
echo "修复测试文件中的ASCII运算符..."

# 只处理test/test_files目录下的文件
for file in test/test_files/*.ly; do
    if [ -f "$file" ]; then
        echo "处理文件: $file"
        
        # 创建备份
        cp "$file" "$file.backup"
        
        # 替换ASCII运算符为中文运算符
        sed -i 's/\([「」]\)\+\([「」]\)/\1加\2/g' "$file"
        sed -i 's/\([「」]\)-\([「」]\)/\1减\2/g' "$file"
        sed -i 's/\([「」]\)\*\([「」]\)/\1乘\2/g' "$file"
        sed -i 's/\([「」]\)\/\([「」]\)/\1除\2/g' "$file"
        sed -i 's/\([「」]\)%\([「」]\)/\1取余\2/g' "$file"
        
        # 检查是否有变化
        if ! diff -q "$file" "$file.backup" > /dev/null; then
            echo "  ✅ 文件已修改"
        else
            echo "  ℹ️  文件无变化"
        fi
        
        # 删除备份
        rm "$file.backup"
    fi
done

echo "修复完成"