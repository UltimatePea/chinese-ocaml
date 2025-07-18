#!/bin/bash

# 技术债务Phase 8-1: 文件命名标准化脚本
# 将大写命名的文件改为OCaml标准小写命名

echo "开始文件命名标准化..."

# 创建重命名映射
declare -A RENAME_MAP=(
    # Lexer 模块
    ["src/Lexer_chars"]="src/lexer_chars"
    ["src/Lexer_keywords"]="src/lexer_keywords" 
    ["src/Lexer_parsers"]="src/lexer_parsers"
    
    # Parser 模块
    ["src/Parser_ancient"]="src/parser_ancient"
    ["src/Parser_expressions"]="src/parser_expressions"
    ["src/Parser_expressions_advanced"]="src/parser_expressions_advanced"
    ["src/Parser_expressions_arithmetic"]="src/parser_expressions_arithmetic"
    ["src/Parser_expressions_assignment"]="src/parser_expressions_assignment"
    ["src/Parser_expressions_binary"]="src/parser_expressions_binary"
    ["src/Parser_expressions_logical"]="src/parser_expressions_logical"
    ["src/Parser_expressions_main"]="src/parser_expressions_main"
    ["src/Parser_expressions_natural_language"]="src/parser_expressions_natural_language"
    ["src/Parser_expressions_primary"]="src/parser_expressions_primary"
    ["src/Parser_expressions_utils"]="src/parser_expressions_utils"
    ["src/Parser_patterns"]="src/parser_patterns"
    ["src/Parser_poetry"]="src/parser_poetry"
    ["src/Parser_statements"]="src/parser_statements"
    ["src/Parser_types"]="src/parser_types"
    ["src/Parser_utils"]="src/parser_utils"
)

# 第一步：重命名文件
echo "第一步：重命名文件..."
for old_name in "${!RENAME_MAP[@]}"; do
    new_name="${RENAME_MAP[$old_name]}"
    
    # 重命名 .ml 文件
    if [ -f "${old_name}.ml" ]; then
        echo "重命名: ${old_name}.ml -> ${new_name}.ml"
        git mv "${old_name}.ml" "${new_name}.ml"
    fi
    
    # 重命名 .mli 文件
    if [ -f "${old_name}.mli" ]; then
        echo "重命名: ${old_name}.mli -> ${new_name}.mli" 
        git mv "${old_name}.mli" "${new_name}.mli"
    fi
done

echo "文件重命名完成！"
echo "下一步需要更新模块引用和import语句..."