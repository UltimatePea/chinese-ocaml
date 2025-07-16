#!/bin/bash

# Quick ASCII fix script for remaining common patterns
# Focus on the most common violations

echo "开始快速ASCII字符修复..."

# Common replacements across multiple files
find . -name "*.ly" -type f -exec sed -i 's/\bC代码\b/丙代码/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bAST\b/抽象语法树/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bmutable\b/可变/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bList\./列表点/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bList /列表 /g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bnot\b/不是/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bif\b/若/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bthen\b/则/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bwhen\b/当/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bor\b/或/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\band\b/和/g' {} \;

# Variable name replacements
find . -name "*.ly" -type f -exec sed -i 's/\bs1\b/字符串一/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bs2\b/字符串二/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bvalue\b/值/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\btree\b/树/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bleft\b/左/g' {} \;
find . -name "*.ly" -type f -exec sed -i 's/\bright\b/右/g' {} \;

echo "快速修复完成"