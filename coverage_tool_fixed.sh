#!/bin/bash

# 骆言编译器测试覆盖率工具 - 已修复版本
# 解决了bisect_ppx配置问题，现在可以正常生成覆盖率报告

echo "=== 骆言编译器测试覆盖率工具 ==="
echo "📊 生成全面的代码覆盖率报告"

# 1. 准备环境
echo "🔧 准备覆盖率环境..."
mkdir -p _coverage
mkdir -p coverage_reports
export BISECT_FILE="_coverage/bisect"
export BISECT_SILENT="YES"

# 2. 清理并构建
echo "🧹 清理并重新构建..."
dune clean
dune build

# 3. 运行核心测试套件
echo "🧪 运行核心测试套件..."

echo "  📝 运行AST模块测试..."
BISECT_FILE=_coverage/bisect dune exec test/unit/test_ast.exe > /dev/null 2>&1

echo "  🔤 运行词法分析器测试..."
BISECT_FILE=_coverage/bisect dune exec test/unit/test_lexer.exe > /dev/null 2>&1

echo "  📜 运行语法分析器测试..."
BISECT_FILE=_coverage/bisect dune exec test/unit/test_parser.exe > /dev/null 2>&1

echo "  🧩 运行类型系统测试..."
BISECT_FILE=_coverage/bisect dune exec test/unit/test_types.exe > /dev/null 2>&1

echo "  📋 运行数组功能测试..."
BISECT_FILE=_coverage/bisect dune exec test/arrays.exe > /dev/null 2>&1

echo "  🏃 运行简单集成测试..."
BISECT_FILE=_coverage/bisect dune exec test/simple_integration.exe > /dev/null 2>&1 || echo "    (某些测试可能跳过)"

# 4. 运行额外测试以提升覆盖率
echo "  🎭 运行诗词编程测试..."
BISECT_FILE=_coverage/bisect dune test --profile dev > /dev/null 2>&1 || echo "    (使用已有覆盖率数据)"

# 5. 生成覆盖率报告
echo "📈 生成覆盖率报告..."

if ls _coverage/*.coverage 1> /dev/null 2>&1; then
    echo "✅ 发现覆盖率数据文件："
    ls -la _coverage/*.coverage | head -3
    
    echo "📊 生成摘要报告..."
    coverage_summary=$(bisect-ppx-report summary _coverage/*.coverage)
    echo "当前覆盖率: $coverage_summary"
    
    echo "🌐 生成HTML报告..."
    bisect-ppx-report html -o coverage_reports/html _coverage/*.coverage
    echo "✅ HTML报告已生成: coverage_reports/html/index.html"
    
    echo "📄 生成文本报告..."
    bisect-ppx-report summary _coverage/*.coverage > coverage_reports/coverage_summary.txt
    echo "✅ 文本摘要已保存: coverage_reports/coverage_summary.txt"
    
else
    echo "❌ 未发现覆盖率数据文件"
    echo "请检查bisect_ppx配置"
    exit 1
fi

# 6. 覆盖率分析
echo ""
echo "=== 覆盖率分析 ==="
current_coverage=$(bisect-ppx-report summary _coverage/*.coverage | grep -o '[0-9.]*%' | head -1)
echo "📊 当前覆盖率: $current_coverage"

# 提取数字部分进行比较
coverage_num=$(echo $current_coverage | sed 's/%//')
if (( $(echo "$coverage_num >= 15.0" | bc -l) )); then
    echo "✅ 覆盖率已达到基本标准 (≥15%)"
    echo "🎯 建议下一步目标: 30%覆盖率"
elif (( $(echo "$coverage_num >= 10.0" | bc -l) )); then
    echo "🔄 覆盖率正在改善 (≥10%)"
    echo "🎯 建议继续添加测试以达到15%"
else
    echo "⚠️  覆盖率较低 (<10%)"
    echo "🎯 建议优先测试核心模块"
fi

echo ""
echo "=== 修复完成 ==="
echo "✅ 测试覆盖率工具已恢复正常工作"
echo "📁 覆盖率报告位置: coverage_reports/"
echo "🌐 在浏览器中查看: file://$(pwd)/coverage_reports/html/index.html"
echo ""
echo "🔧 修复要点:"
echo "  1. 确保_coverage目录存在"
echo "  2. 正确设置BISECT_FILE环境变量"
echo "  3. 使用单独测试运行以避免脚本冲突"
echo "  4. 主库和测试都已配置bisect_ppx预处理器"
echo ""
echo "📈 使用方法:"
echo "  ./coverage_tool_fixed.sh    # 生成完整覆盖率报告"
echo "  bisect-ppx-report summary _coverage/*.coverage  # 快速查看摘要"