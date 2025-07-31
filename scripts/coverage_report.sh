#!/bin/bash
# 标准化测试覆盖率报告脚本
# Author: Whisky, PR Worker
# Fixed version that properly configures and uses bisect-ppx

set -e

echo "🔍 生成测试覆盖率报告..."

# 构建项目并运行测试以生成覆盖率数据
echo "🧪 运行测试并生成覆盖率数据..."
dune build
export BISECT_ENABLE=yes
dune runtest

# 检查是否生成了覆盖率文件
COVERAGE_FILES=$(find _build -name "*.coverage" | wc -l)
echo "📊 发现 $COVERAGE_FILES 个覆盖率文件"

if [ "$COVERAGE_FILES" -gt 0 ]; then
    # 生成覆盖率摘要
    echo "📈 生成覆盖率摘要..."
    COVERAGE_SUMMARY=$(dune exec -- bisect-ppx-report summary --coverage-path=_build/default/test)
    echo "📊 $COVERAGE_SUMMARY"
    
    # 提取覆盖率百分比
    COVERAGE_PERCENTAGE=$(echo "$COVERAGE_SUMMARY" | grep -o '[0-9]\+\.[0-9]\+%' | head -1)
    COVERAGE_FRACTION=$(echo "$COVERAGE_SUMMARY" | grep -o '[0-9]\+/[0-9]\+')
    
    # 确保数据目录存在
    mkdir -p coverage_reports/data
    
    # 更新覆盖率数据文件
    echo "$COVERAGE_PERCENTAGE" | sed 's/%//' > coverage_reports/data/latest_coverage.txt
    
    # 统计项目文件
    SOURCE_FILES=$(find src -name "*.ml" | wc -l)
    TEST_FILES=$(find test -name "*.ml" | wc -l)
    TOTAL_FILES=$((SOURCE_FILES + TEST_FILES))
    
    # 生成HTML报告
    echo "🌐 生成HTML覆盖率报告..."
    mkdir -p coverage_reports/html
    dune exec -- bisect-ppx-report html --coverage-path=_build/default/test --output-dir=coverage_reports/html/
    
    # 更新覆盖率状态文件  
    echo "📝 更新覆盖率状态..."
    cat > doc/coverage_status_current.md << EOF
# 当前测试覆盖率状态

**生成时间**: $(date)
**覆盖率**: $COVERAGE_PERCENTAGE ($COVERAGE_FRACTION)
**数据来源**: bisect-ppx实时生成

## 项目结构分析
- 源文件: $SOURCE_FILES 个
- 测试文件: $TEST_FILES 个
- 总文件: $TOTAL_FILES 个
- 覆盖率文件: $COVERAGE_FILES 个

## 报告文件
- HTML报告: coverage_reports/html/index.html
- 摘要数据: coverage_reports/data/latest_coverage.txt

## 使用方法
\`\`\`bash
./scripts/coverage_report.sh
\`\`\`

## 查看HTML报告
\`\`\`bash
open coverage_reports/html/index.html
\`\`\`

Author: Whisky, PR Worker
EOF

    echo "✅ 覆盖率报告生成完成"
    echo "📊 当前覆盖率: $COVERAGE_PERCENTAGE ($COVERAGE_FRACTION)"
    echo "🌐 HTML报告: coverage_reports/html/index.html"
    echo "📄 状态文档: doc/coverage_status_current.md"
else
    echo "❌ 未找到覆盖率文件"
    echo "⚠️  bisect-ppx配置可能有问题"
    
    # 创建状态文件说明情况
    cat > doc/coverage_status_current.md << EOF
# 测试覆盖率状态 - 生成失败

**生成时间**: $(date)
**状态**: 覆盖率文件生成失败

## 发现的问题
1. 未找到.coverage文件
2. 可能的bisect-ppx配置问题
3. 需要检查环境变量和dune配置

## 调试信息
- 查找的覆盖率文件数量: $COVERAGE_FILES
- 构建状态: ✅ 成功
- 测试状态需要检查

## 后续工作
1. 检查bisect-ppx是否正确安装
2. 验证dune-project中的bisect_ppx依赖
3. 检查src/dune中的preprocess配置

Author: Whisky, PR Worker
EOF
    
    echo "⚠️  需要调试bisect-ppx配置"
    exit 1
fi