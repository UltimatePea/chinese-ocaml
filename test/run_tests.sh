#!/bin/bash

# 骆言编译器测试运行脚本
# Luoyan Compiler Test Runner Script

set -e

echo "=== 骆言编译器测试套件 ==="
echo "开始运行所有测试..."
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 运行测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}运行测试: ${test_name}${NC}"
    echo "命令: $test_command"
    echo ""
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command" > /tmp/test_output.log 2>&1; then
        echo -e "${GREEN}✓ ${test_name} 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ ${test_name} 失败${NC}"
        echo "错误输出:"
        cat /tmp/test_output.log
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    echo ""
    echo "----------------------------------------"
    echo ""
}

# 检查是否在正确的目录
if [ ! -f "dune-project" ]; then
    echo -e "${RED}错误: 请在项目根目录运行此脚本${NC}"
    exit 1
fi

# 构建项目
echo -e "${YELLOW}构建项目...${NC}"
if dune build; then
    echo -e "${GREEN}构建成功${NC}"
else
    echo -e "${RED}构建失败${NC}"
    exit 1
fi

echo ""

# 运行单元测试
run_test "单元测试" "dune exec -- test_yyocamlc"

# 运行端到端测试
run_test "端到端测试" "dune exec -- test_e2e"

# 运行文件测试
run_test "文件测试" "dune exec -- test_file_runner_fixed"

# 运行所有测试
run_test "完整测试套件" "dune runtest --force"

# 清理临时文件
rm -f /tmp/test_output.log

# 显示测试结果摘要
echo "=== 测试结果摘要 ==="
echo -e "总测试数: ${TOTAL_TESTS}"
echo -e "${GREEN}通过: ${PASSED_TESTS}${NC}"
echo -e "${RED}失败: ${FAILED_TESTS}${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}所有测试都通过了！${NC}"
    exit 0
else
    echo -e "${RED}有 ${FAILED_TESTS} 个测试失败${NC}"
    exit 1
fi