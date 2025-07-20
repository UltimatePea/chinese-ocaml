#!/bin/bash
# 构建性能监控脚本 - 骆言项目
# 用于监控构建时间和资源使用

set -e

echo "⏱️ 骆言项目构建性能监控"
echo "开始时间: $(date)"
echo "==============================="

# 显示系统信息
echo "💻 系统信息:"
echo "CPU核心数: $(nproc)"
echo "内存使用: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "磁盘空间: $(df -h . | tail -1 | awk '{print $3 "/" $2 " (" $5 " 已用)"}')"
echo ""

# 清理构建
echo "🧹 清理前一次构建..."
dune clean

# 监控构建时间
echo "📦 开始构建..."
echo "构建开始: $(date)"
start_time=$(date +%s)

# 执行构建
time dune build --verbose

end_time=$(date +%s)
build_duration=$((end_time - start_time))

echo ""
echo "==============================="
echo "✅ 构建完成: $(date)"
echo "总耗时: ${build_duration}秒"

# 显示构建产物大小
echo ""
echo "📊 构建产物统计:"
if [ -d "_build" ]; then
    echo "构建目录大小: $(du -sh _build/ | cut -f1)"
    echo "文件数量: $(find _build/ -type f | wc -l)"
fi

# 性能评估
echo ""
echo "⚡ 性能评估:"
if [ $build_duration -lt 30 ]; then
    echo "🟢 构建速度: 优秀 (${build_duration}s < 30s)"
elif [ $build_duration -lt 60 ]; then
    echo "🟡 构建速度: 良好 (${build_duration}s < 60s)"
else
    echo "🔴 构建速度: 需要优化 (${build_duration}s >= 60s)"
fi

echo "==============================="