#!/bin/bash
# 标准化测试覆盖率报告脚本
# Author: Alpha, 主要工作代理

set -e

echo "🔍 生成测试覆盖率报告..."

# 运行测试并生成覆盖率数据（不删除现有覆盖率文件）
echo "📊 运行测试..."
dune build
dune runtest

# 生成覆盖率摘要
echo "📈 生成覆盖率摘要..."
COVERAGE_SUMMARY=$(dune exec -- bisect-ppx-report summary)
echo "当前测试覆盖率: $COVERAGE_SUMMARY"

# 生成HTML报告
echo "🌐 生成HTML覆盖率报告..."
dune exec -- bisect-ppx-report html --coverage-path _coverage

# 更新覆盖率状态文件  
echo "📝 更新覆盖率状态..."
cat > doc/coverage_status_current.md << EOF
# 当前测试覆盖率状态

**生成时间**: $(date)
**覆盖率**: $COVERAGE_SUMMARY

## 报告位置
- HTML报告: _coverage/index.html
- 生成脚本: scripts/coverage_report.sh

## 使用方法
\`\`\`bash
./scripts/coverage_report.sh
\`\`\`

Author: Alpha, 主要工作代理
EOF

echo "✅ 覆盖率报告生成完成"
echo "📂 HTML报告位置: _coverage/index.html"
echo "📊 当前覆盖率: $COVERAGE_SUMMARY"