#!/bin/bash

# 骆言测试总结脚本
# 当测试数量超过20个时提供简化输出

echo "🔍 正在运行骆言编译器测试套件..."

# 运行测试并捕获输出
output=$(dune runtest 2>&1)
exit_code=$?

# 统计测试结果
total_tests=$(echo "$output" | grep -c "\[OK\]")
failed_tests=$(echo "$output" | grep -c "\[FAIL\]")
error_tests=$(echo "$output" | grep -c "\[ERROR\]")

# 计算总的测试套件数
test_suites=$(echo "$output" | grep "Testing" | wc -l)

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