#!/bin/bash

# 骆言测试总结脚本
# 当测试数量超过20个时提供简化输出

echo "🔍 正在运行骆言编译器测试套件..."

# 运行测试并捕获输出
output=$(dune runtest 2>&1)
exit_code=$?

# 如果dune runtest没有产生输出，直接运行测试可执行文件
if [ -z "$output" ]; then
    echo "检测到dune runtest静默运行，正在统计已构建的测试..."
    
    # 统计测试可执行文件数量
    test_exe_count=$(find _build/default/test -name "*.exe" 2>/dev/null | wc -l)
    
    if [ $test_exe_count -gt 0 ]; then
        echo "发现 $test_exe_count 个测试可执行文件"
        
        # 运行几个示例测试来获取统计信息
        sample_output=""
        sample_count=0
        for test_exe in $(find _build/default/test -name "*.exe" | head -5); do
            if [ -x "$test_exe" ]; then
                sample_run=$($test_exe 2>&1)
                sample_output="$sample_output\n$sample_run"
                sample_count=$((sample_count + 1))
            fi
        done
        output="$sample_output"
    fi
fi

# 统计测试结果 - 匹配彩色输出格式
total_tests=$(echo "$output" | grep -oE '\[32m\[OK\]\[0m' | wc -l)
failed_tests=$(echo "$output" | grep -oE '\[31m\[FAIL\]\[0m|\[FAILED\]' | wc -l)
error_tests=$(echo "$output" | grep -oE '\[31m\[ERROR\]\[0m' | wc -l)

# 计算总的测试套件数 - 匹配彩色输出格式
test_suites=$(echo "$output" | grep -E "Testing.*\[1m.*\[0m" | wc -l)

# 如果没有找到彩色格式，尝试纯文本格式
if [ $total_tests -eq 0 ]; then
    total_tests=$(echo "$output" | grep -c "\[OK\]")
fi
if [ $failed_tests -eq 0 ]; then
    failed_tests=$(echo "$output" | grep -c "\[FAIL\]")
fi
if [ $error_tests -eq 0 ]; then
    error_tests=$(echo "$output" | grep -c "\[ERROR\]")
fi
if [ $test_suites -eq 0 ]; then
    test_suites=$(echo "$output" | grep "Testing" | wc -l)
fi

# 如果仍然没有找到测试，尝试查找测试成功的消息
if [ $total_tests -eq 0 ]; then
    successful_runs=$(echo "$output" | grep -c "Test Successful")
    if [ $successful_runs -gt 0 ]; then
        # 从成功消息中提取测试数量
        total_tests=$(echo "$output" | grep -oE '[0-9]+ tests run' | grep -oE '[0-9]+' | awk '{sum += $1} END {print sum}')
        test_suites=$successful_runs
    fi
fi

echo "📊 测试总结："
echo "   测试套件数：$test_suites"
echo "   总测试数：$total_tests"

if [ $failed_tests -eq 0 ] && [ $error_tests -eq 0 ]; then
    echo "✅ 全部 $total_tests 个测试通过！"
    
    # 如果测试数量少于20个，显示详细输出
    if [ $total_tests -lt 20 ]; then
        echo ""
        echo "详细输出："
        echo "$output"
    fi
else
    echo "❌ 发现失败：$failed_tests 个失败，$error_tests 个错误"
    echo ""
    echo "失败的测试："
    echo "$output" | grep -E "\[FAIL\]|\[ERROR\]"
    echo ""
    echo "完整输出："
    echo "$output"
fi

exit $exit_code