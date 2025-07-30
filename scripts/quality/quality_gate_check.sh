#!/bin/bash
# 质量门控检查脚本 - Fix #1799
# 
# 集成所有质量检查工具的主入口脚本
# 基于Beta代理对代码质量问题的分析
#
# Author: Beta, 代码审查专家

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查结果变量
DATA_INTEGRITY_PASSED=true
TEST_COVERAGE_PASSED=true
PERFORMANCE_PASSED=true
OVERALL_PASSED=true

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}质量门控检查开始 - Fix #1799${NC}"
echo -e "${BLUE}======================================${NC}"

# 1. 数据完整性检查
echo -e "\n${BLUE}1. 数据完整性检查${NC}"
echo "检查韵律数据重复和分类错误..."

if [ -f "$PROJECT_ROOT/src/poetry/unified_rhyme_core_consolidated.ml" ]; then
    if python3 "$SCRIPT_DIR/data_integrity_validator.py" "$PROJECT_ROOT/src/poetry/unified_rhyme_core_consolidated.ml"; then
        echo -e "${GREEN}✅ 数据完整性检查通过${NC}"
    else
        echo -e "${RED}❌ 数据完整性检查失败${NC}"
        DATA_INTEGRITY_PASSED=false
        OVERALL_PASSED=false
    fi
else
    echo -e "${YELLOW}⚠️ 韵律数据文件不存在，跳过检查${NC}"
fi

# 2. 测试覆盖率检查
echo -e "\n${BLUE}2. 测试覆盖率检查${NC}"
echo "检查核心模块测试覆盖率..."

if python3 "$SCRIPT_DIR/test_coverage_enforcer.py" 90; then
    echo -e "${GREEN}✅ 测试覆盖率检查通过${NC}"
else
    echo -e "${RED}❌ 测试覆盖率检查失败${NC}"
    TEST_COVERAGE_PASSED=false
    OVERALL_PASSED=false
fi

# 3. 性能基准检查
echo -e "\n${BLUE}3. 性能基准检查${NC}"
echo "检查算法复杂度和性能问题..."

if python3 "$SCRIPT_DIR/performance_validator.py"; then
    echo -e "${GREEN}✅ 性能基准检查通过${NC}"
else
    echo -e "${RED}❌ 性能基准检查失败${NC}"
    PERFORMANCE_PASSED=false
    OVERALL_PASSED=false
fi

# 4. 编译检查（如果存在）
echo -e "\n${BLUE}4. 编译检查${NC}"
echo "验证代码编译通过..."

cd "$PROJECT_ROOT"
if command -v dune >/dev/null 2>&1; then
    if dune build 2>/dev/null; then
        echo -e "${GREEN}✅ 编译检查通过${NC}"
    else
        echo -e "${RED}❌ 编译检查失败${NC}"
        OVERALL_PASSED=false
    fi
else
    echo -e "${YELLOW}⚠️ Dune未安装，跳过编译检查${NC}"
fi

# 5. 生成综合报告
echo -e "\n${BLUE}======================================${NC}"
echo -e "${BLUE}质量门控检查报告${NC}"
echo -e "${BLUE}======================================${NC}"

echo -e "\n📋 检查结果汇总:"
echo -e "   数据完整性: $([ "$DATA_INTEGRITY_PASSED" = true ] && echo -e "${GREEN}通过${NC}" || echo -e "${RED}失败${NC}")"
echo -e "   测试覆盖率: $([ "$TEST_COVERAGE_PASSED" = true ] && echo -e "${GREEN}通过${NC}" || echo -e "${RED}失败${NC}")"
echo -e "   性能基准:   $([ "$PERFORMANCE_PASSED" = true ] && echo -e "${GREEN}通过${NC}" || echo -e "${RED}失败${NC}")"

if [ "$OVERALL_PASSED" = true ]; then
    echo -e "\n${GREEN}🎉 所有质量门控检查通过！${NC}"
    echo -e "${GREEN}✅ 代码质量达到项目标准，可以合并${NC}"
    exit 0
else
    echo -e "\n${RED}❌ 质量门控检查失败${NC}"
    echo -e "${RED}🚫 代码质量未达标，需要修复后再提交${NC}"
    
    echo -e "\n📝 修复建议:"
    if [ "$DATA_INTEGRITY_PASSED" = false ]; then
        echo -e "${RED}   • 修复数据重复和分类错误${NC}"
    fi
    if [ "$TEST_COVERAGE_PASSED" = false ]; then
        echo -e "${RED}   • 增加测试用例，提升覆盖率到90%以上${NC}"
    fi
    if [ "$PERFORMANCE_PASSED" = false ]; then
        echo -e "${RED}   • 优化算法复杂度，使用高效数据结构${NC}"
    fi
    
    exit 1
fi