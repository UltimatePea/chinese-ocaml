#\!/bin/bash
echo "=== 骆言项目未使用函数检查 ==="
echo "日期: $(date)"
echo "========================================"

for file in src/*.ml; do
  if [ -f "$file" ]; then
    echo "检查文件: $file"
    grep -n "^let _" "$file"  < /dev/null |  while IFS= read -r line; do
      line_num=$(echo "$line" | cut -d: -f1)
      func_name=$(echo "$line" | sed 's/.*let _\([a-zA-Z0-9_]*\).*/\1/')
      if [ -n "$func_name" ]; then
        if \! grep -r "_$func_name" src/ test/ --include="*.ml" --include="*.mli" --exclude="$(basename "$file")" >/dev/null 2>&1; then
          echo "    未使用: _$func_name (行 $line_num)"
        fi
      fi
    done
  fi
done
echo "========================================"
