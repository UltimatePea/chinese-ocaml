#!/bin/bash

# 查找未使用函数的脚本
# 用法: ./scripts/find_unused_functions.sh

echo "=== 骆言项目未使用函数检查 ==="
echo "日期: $(date)"
echo "========================================"

# 创建临时文件存储结果
TEMP_FILE="/tmp/unused_functions_$$.txt"
REPORT_FILE="doc/issues/unused_functions_report_$(date +%Y%m%d_%H%M%S).md"

# 检查每个源文件
for file in src/*.ml; do
  if [ -f "$file" ]; then
    echo "检查文件: $file"
    
    # 查找以 let _ 开头的函数
    grep -n "^let _" "$file" | while IFS= read -r line; do
      line_num=$(echo "$line" | cut -d: -f1)
      func_line=$(echo "$line" | cut -d: -f2-)
      
      # 提取函数名
      func_name=$(echo "$func_line" | sed 's/let _\([a-zA-Z0-9_]*\).*/\1/')
      
      if [ -n "$func_name" ]; then
        # 检查该函数是否在其他地方被使用
        if ! grep -r "_$func_name" src/ test/ --include="*.ml" --include="*.mli" --exclude="$file" >/dev/null 2>&1; then
          echo "    未使用: _$func_name (行 $line_num)"
          echo "$file:$line_num:_$func_name" >> "$TEMP_FILE"
        fi
      fi
    done
    echo ""
  fi
done

# 生成报告
echo "生成详细报告..."
cat > "$REPORT_FILE" << 'EOF'
# 未使用函数检查报告

**生成时间**: $(date)  
**检查范围**: src/*.ml 文件  
**检查类型**: 以 `let _` 开头的函数

## 检查结果

EOF

if [ -f "$TEMP_FILE" ] && [ -s "$TEMP_FILE" ]; then
  echo "### 发现的未使用函数" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  
  # 按文件分组显示
  current_file=""
  while IFS=':' read -r file_path line_num func_name; do
    if [ "$file_path" != "$current_file" ]; then
      echo "#### $file_path" >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
      current_file="$file_path"
    fi
    echo "- \`$func_name\` (行 $line_num)" >> "$REPORT_FILE"
  done < "$TEMP_FILE"
  
  echo "" >> "$REPORT_FILE"
  echo "### 建议的清理操作" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "1. **验证函数确实未使用**: 手动检查每个函数是否真的不再需要" >> "$REPORT_FILE"
  echo "2. **检查接口文件**: 确认接口文件(.mli)中是否有声明" >> "$REPORT_FILE"
  echo "3. **安全删除**: 对于确认未使用的函数，可以安全删除" >> "$REPORT_FILE"
  echo "4. **重新激活**: 对于有价值的函数，考虑在适当的地方使用" >> "$REPORT_FILE"
  
  # 统计信息
  total_unused=$(wc -l < "$TEMP_FILE")
  echo "" >> "$REPORT_FILE"
  echo "### 统计信息" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "- 总计发现 **$total_unused** 个未使用函数" >> "$REPORT_FILE"
  echo "- 建议优先处理影响较大的文件" >> "$REPORT_FILE"
  
  echo "发现 $total_unused 个未使用函数"
  echo "详细报告已保存至: $REPORT_FILE"
else
  echo "### 检查结果" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "✅ **没有发现未使用的函数**" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "所有以 \`let _\` 开头的函数都在项目中被使用。" >> "$REPORT_FILE"
  
  echo "✅ 没有发现未使用的函数"
  echo "报告已保存至: $REPORT_FILE"
fi

# 清理临时文件
rm -f "$TEMP_FILE"

echo "========================================"
echo "检查完成"