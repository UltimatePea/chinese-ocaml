#!/bin/bash
# CI性能监控脚本 - Fix #1514
# 监控CI流水线各阶段执行时间，防止性能退化

set -e

echo "🚀 CI性能监控开始 - $(date)"
start_time=$(date +%s)

# 性能阈值配置 (秒)
DEPENDENCY_THRESHOLD=180  # 3分钟
BUILD_THRESHOLD=240       # 4分钟  
TOTAL_THRESHOLD=420       # 7分钟

# 创建性能日志目录
mkdir -p /tmp/ci_performance_logs

# 记录环境信息
echo "📋 CI环境信息:" | tee /tmp/ci_performance_logs/environment.log
echo "  OCaml版本: $(ocaml -version 2>/dev/null || echo 'N/A')" | tee -a /tmp/ci_performance_logs/environment.log
echo "  系统信息: $(uname -a)" | tee -a /tmp/ci_performance_logs/environment.log
echo "  内存信息: $(free -h | head -2)" | tee -a /tmp/ci_performance_logs/environment.log

# 函数：计时执行
time_execution() {
    local step_name="$1"
    local command="$2"
    local threshold="$3"
    
    echo "📦 开始执行: $step_name"
    local step_start=$(date +%s)
    
    # 执行命令并捕获输出
    if eval "$command"; then
        local step_end=$(date +%s)
        local step_duration=$((step_end - step_start))
        
        echo "✅ $step_name 完成 - 耗时: ${step_duration}s"
        
        # 检查是否超过阈值
        if [ $step_duration -gt $threshold ]; then
            echo "⚠️ 警告: $step_name 执行时间 (${step_duration}s) 超过阈值 (${threshold}s)"
            echo "$(date): $step_name SLOW ${step_duration}s" >> /tmp/ci_performance_logs/performance_warnings.log
        else
            echo "$(date): $step_name OK ${step_duration}s" >> /tmp/ci_performance_logs/performance_ok.log
        fi
        
        return $step_duration
    else
        local step_end=$(date +%s)
        local step_duration=$((step_end - step_start))
        echo "❌ $step_name 失败 - 耗时: ${step_duration}s"
        echo "$(date): $step_name FAILED ${step_duration}s" >> /tmp/ci_performance_logs/performance_errors.log
        return 999  # 返回错误标识
    fi
}

# 执行CI性能监控的各个阶段
echo "================================================"
echo "🔧 Phase 1: 依赖安装性能监控"
echo "================================================"

dep_duration=$(time_execution "依赖安装" "opam install -y dune menhir ppx_deriving alcotest bisect_ppx yojson" $DEPENDENCY_THRESHOLD)

echo "================================================"
echo "🏗️ Phase 2: 项目构建性能监控" 
echo "================================================"

build_duration=$(time_execution "项目构建" "opam exec -- dune build" $BUILD_THRESHOLD)

echo "================================================"  
echo "🧪 Phase 3: 基础测试性能监控"
echo "================================================"

test_duration=$(time_execution "基础测试" "opam exec -- dune runtest --profile dev" 120)

# 计算总执行时间
end_time=$(date +%s)
total_time=$((end_time - start_time))

echo "================================================"
echo "📊 CI性能监控报告"
echo "================================================"
echo "  依赖安装时间: ${dep_duration}s (阈值: ${DEPENDENCY_THRESHOLD}s)"
echo "  项目构建时间: ${build_duration}s (阈值: ${BUILD_THRESHOLD}s)" 
echo "  基础测试时间: ${test_duration}s (阈值: 120s)"
echo "  总执行时间: ${total_time}s (阈值: ${TOTAL_THRESHOLD}s)"

# 性能状态评估
performance_status="GOOD"
if [ $dep_duration -gt $DEPENDENCY_THRESHOLD ] || [ $build_duration -gt $BUILD_THRESHOLD ] || [ $total_time -gt $TOTAL_THRESHOLD ]; then
    performance_status="DEGRADED"
fi

echo "  性能状态: $performance_status"

# 生成性能趋势数据
echo "$(date +%Y%m%d_%H%M%S),$dep_duration,$build_duration,$test_duration,$total_time,$performance_status" >> /tmp/ci_performance_logs/performance_trend.csv

# 创建性能报告JSON
cat > /tmp/ci_performance_logs/performance_report.json << EOF
{
  "timestamp": "$(date -Iseconds)",
  "total_duration": $total_time,
  "phases": {
    "dependency_install": {
      "duration": $dep_duration,
      "threshold": $DEPENDENCY_THRESHOLD,
      "status": "$([ $dep_duration -le $DEPENDENCY_THRESHOLD ] && echo 'OK' || echo 'SLOW')"
    },
    "build": {
      "duration": $build_duration,
      "threshold": $BUILD_THRESHOLD,
      "status": "$([ $build_duration -le $BUILD_THRESHOLD ] && echo 'OK' || echo 'SLOW')"
    },
    "test": {
      "duration": $test_duration,
      "threshold": 120,
      "status": "$([ $test_duration -le 120 ] && echo 'OK' || echo 'SLOW')"
    }
  },
  "overall_status": "$performance_status"
}
EOF

# 性能阈值检查和退出处理
if [ "$performance_status" = "DEGRADED" ]; then
    echo "💥 严重警告: CI性能显著退化！"
    echo "🔍 建议检查项目:"
    echo "   1. 最近的代码变更是否引入了性能问题"
    echo "   2. 依赖版本是否有重大更新"
    echo "   3. 系统资源是否不足"
    echo "   4. 缓存是否失效"
    echo ""
    echo "📁 性能日志保存在: /tmp/ci_performance_logs/"
    
    # 如果是推送到主分支，性能退化应该是警告而不是失败
    if [ "${GITHUB_REF:-}" = "refs/heads/main" ]; then
        echo "⚠️ 主分支性能退化 - 继续构建但记录警告"
        exit 0
    else
        echo "❌ 分支性能退化 - 构建失败"
        exit 1
    fi
else
    echo "✅ CI性能监控完成 - 性能表现良好"
    echo "📁 性能日志保存在: /tmp/ci_performance_logs/"
fi

echo "🏁 CI性能监控结束 - $(date)"