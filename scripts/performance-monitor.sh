#!/bin/bash
# 骆言项目性能监控脚本
# 用于持续监控编译器性能和运行时性能

set -e

echo "🔧 骆言项目性能监控系统"
echo "启动时间: $(date)"
echo "=================================="

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PERF_DIR="$PROJECT_ROOT/performance_data"
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")

# 创建性能数据目录
mkdir -p "$PERF_DIR"

# 性能监控函数
monitor_compilation_performance() {
    echo "📊 编译性能监控..."
    
    # 清理构建
    dune clean
    
    # 监控构建时间
    local start_time=$(date +%s.%N)
    dune build > /dev/null 2>&1
    local end_time=$(date +%s.%N)
    local build_time=$(echo "$end_time - $start_time" | bc -l)
    
    # 记录构建产物大小
    local build_size=$(du -sh _build/ | cut -f1)
    
    # 记录到性能日志
    echo "$TIMESTAMP,build_time,$build_time" >> "$PERF_DIR/compilation_metrics.csv"
    echo "$TIMESTAMP,build_size,$build_size" >> "$PERF_DIR/compilation_metrics.csv"
    
    echo "✅ 编译时间: ${build_time}s"
    echo "📦 构建大小: $build_size"
}

# 运行时性能监控
monitor_runtime_performance() {
    echo "🚀 运行时性能监控..."
    
    # 测试简单程序执行时间
    local simple_test_file="$PROJECT_ROOT/test_files/simple_test.ly"
    
    if [ -f "$simple_test_file" ]; then
        local start_time=$(date +%s.%N)
        timeout 10s dune exec yyocamlc -- "$simple_test_file" > /dev/null 2>&1 || true
        local end_time=$(date +%s.%N)
        local exec_time=$(echo "$end_time - $start_time" | bc -l)
        
        echo "$TIMESTAMP,simple_exec_time,$exec_time" >> "$PERF_DIR/runtime_metrics.csv"
        echo "✅ 简单程序执行时间: ${exec_time}s"
    else
        echo "⚠️ 简单测试文件不存在，跳过运行时测试"
    fi
}

# 内存使用监控
monitor_memory_usage() {
    echo "💾 内存使用监控..."
    
    # 运行构建并监控内存使用
    dune clean
    local max_memory=0
    
    # 在后台启动内存监控
    (
        while true; do
            local current_memory=$(ps aux | grep -E 'dune|ocaml' | grep -v grep | awk '{sum += $6} END {print sum}')
            if [ ! -z "$current_memory" ] && [ "$current_memory" -gt "$max_memory" ]; then
                max_memory=$current_memory
            fi
            sleep 0.1
        done
    ) &
    local monitor_pid=$!
    
    # 执行构建
    dune build > /dev/null 2>&1
    
    # 停止内存监控
    kill $monitor_pid 2>/dev/null || true
    
    echo "$TIMESTAMP,max_memory_kb,$max_memory" >> "$PERF_DIR/memory_metrics.csv"
    echo "✅ 最大内存使用: ${max_memory}KB"
}

# 代码复杂度趋势监控
monitor_complexity_trends() {
    echo "📈 代码复杂度趋势监控..."
    
    # 统计文件数量
    local source_files=$(find src/ -name "*.ml" | wc -l)
    local test_files=$(find test/ -name "*.ml" | wc -l)
    local total_lines=$(find src/ -name "*.ml" -exec wc -l {} \; | awk '{sum += $1} END {print sum}')
    
    # 记录复杂度指标
    echo "$TIMESTAMP,source_files,$source_files" >> "$PERF_DIR/complexity_metrics.csv"
    echo "$TIMESTAMP,test_files,$test_files" >> "$PERF_DIR/complexity_metrics.csv"
    echo "$TIMESTAMP,total_lines,$total_lines" >> "$PERF_DIR/complexity_metrics.csv"
    
    echo "✅ 源文件数: $source_files"
    echo "✅ 测试文件数: $test_files"
    echo "✅ 总代码行数: $total_lines"
}

# 生成性能报告
generate_performance_report() {
    echo "📋 生成性能报告..."
    
    local report_file="$PERF_DIR/performance_report_$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# 骆言项目性能监控报告

**生成时间**: $(date)
**监控版本**: $(git rev-parse HEAD 2>/dev/null || echo "unknown")

## 编译性能

EOF

    # 添加最近的编译性能数据
    if [ -f "$PERF_DIR/compilation_metrics.csv" ]; then
        echo "### 构建时间趋势" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        tail -5 "$PERF_DIR/compilation_metrics.csv" | grep "build_time" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 代码复杂度

EOF

    # 添加复杂度数据
    if [ -f "$PERF_DIR/complexity_metrics.csv" ]; then
        echo "### 代码规模趋势" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        tail -3 "$PERF_DIR/complexity_metrics.csv" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
    fi

    echo "✅ 性能报告生成: $report_file"
}

# 主执行流程
main() {
    cd "$PROJECT_ROOT"
    
    # 初始化CSV文件头部（如果不存在）
    [ ! -f "$PERF_DIR/compilation_metrics.csv" ] && echo "timestamp,metric,value" > "$PERF_DIR/compilation_metrics.csv"
    [ ! -f "$PERF_DIR/runtime_metrics.csv" ] && echo "timestamp,metric,value" > "$PERF_DIR/runtime_metrics.csv"
    [ ! -f "$PERF_DIR/memory_metrics.csv" ] && echo "timestamp,metric,value" > "$PERF_DIR/memory_metrics.csv"
    [ ! -f "$PERF_DIR/complexity_metrics.csv" ] && echo "timestamp,metric,value" > "$PERF_DIR/complexity_metrics.csv"
    
    # 执行各项监控
    monitor_compilation_performance
    monitor_runtime_performance
    monitor_memory_usage
    monitor_complexity_trends
    generate_performance_report
    
    echo "=================================="
    echo "✅ 性能监控完成: $(date)"
    echo "📊 性能数据保存在: $PERF_DIR/"
}

# 检查依赖
if ! command -v bc >/dev/null 2>&1; then
    echo "❌ 错误: 需要安装bc计算器"
    exit 1
fi

# 运行主程序
main "$@"