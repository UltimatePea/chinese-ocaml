#!/bin/bash
# Papa Poetry模块现代化监控仪表板
# File: scripts/papa_poetry_modernization_monitor.sh
# Author: Whisky, PR Worker

echo "🎭 Papa Poetry现代化监控仪表板"
echo "监控时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"

# Poetry模块统计
root_modules=$(find src/poetry -maxdepth 1 -name "*.ml" | wc -l)
total_modules=$(find src/poetry -name "*.ml" | wc -l)
interface_files=$(find src/poetry -name "*.mli" | wc -l)
interface_ratio=$(echo "scale=1; $interface_files * 100 / $total_modules" | bc 2>/dev/null || echo "N/A")

echo "📊 Poetry模块现状:"
echo "  根级模块: $root_modules 个"
echo "  总模块数: $total_modules 个"
echo "  接口完整性: ${interface_ratio}%"

# 编译性能监控
echo ""
echo "⚡ 编译性能监控:"
compile_start=$(date +%s.%N)
if dune build src/poetry/ 2>/dev/null; then
    compile_end=$(date +%s.%N)
    compile_time=$(echo "$compile_end - $compile_start" | bc -l 2>/dev/null || echo "N/A")
    printf "  编译时间: %.3fs\n" "$compile_time" 2>/dev/null || echo "  编译时间: $compile_time"
    echo "  ✅ Poetry模块编译成功"
else
    echo "  ❌ Poetry模块编译失败"
fi

# 代码质量检查
echo ""
echo "🔍 代码质量检查:"
rhyme_modules=$(find src/poetry -name "*rhyme*" | wc -l)
artistic_modules=$(find src/poetry -name "*artistic*" | wc -l)
data_modules=$(find src/poetry -name "*data*" | wc -l)
cache_modules=$(find src/poetry -name "*cache*" | wc -l)

echo "  韵律相关模块: $rhyme_modules 个"
echo "  艺术评估模块: $artistic_modules 个"
echo "  数据处理模块: $data_modules 个"
echo "  缓存管理模块: $cache_modules 个"

# 技术债务评估
echo ""
echo "💸 技术债务评估:"
large_files=$(find src/poetry -name "*.ml" -exec wc -l {} + 2>/dev/null | awk '$1 > 300 {count++} END {print count+0}')
echo "  超大文件(>300行): $large_files 个"

# 优化建议
echo ""
echo "🎯 优化建议:"
if [ $rhyme_modules -gt 25 ]; then
    echo "  - 整合韵律模块 (当前: $rhyme_modules, 目标: <20)"
fi
if [ $artistic_modules -gt 15 ]; then
    echo "  - 整合艺术评估模块 (当前: $artistic_modules, 目标: <12)"
fi
if [ $data_modules -gt 35 ]; then
    echo "  - 整合数据处理模块 (当前: $data_modules, 目标: <30)"
fi
if [ $cache_modules -gt 10 ]; then
    echo "  - 统一缓存管理 (当前: $cache_modules, 目标: <5)"
fi

echo ""
echo "📅 下次监控: $(date -d '+4 hours' '+%H:%M' 2>/dev/null || date '+%H:%M')"
echo "========================================"