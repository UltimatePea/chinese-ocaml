#!/bin/bash

# PR状态检查脚本
# 用于监控所有开放PR的合并就绪状态

echo "🔍 检查所有开放PR的状态..."
echo "=================================="

# 检查GitHub CLI是否已认证
if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI未认证，正在尝试认证..."
    python3 github_auth.py | gh auth login --with-token
fi

echo "📋 PR合并状态检查："
echo ""

# 检查每个PR的合并状态
for pr in $(gh pr list --state open --json number --jq '.[].number'); do
    echo "=== PR #$pr ==="
    
    # 获取PR基本信息
    pr_info=$(gh pr view $pr --json title,mergeable,url)
    title=$(echo "$pr_info" | jq -r '.title')
    mergeable=$(echo "$pr_info" | jq -r '.mergeable')
    url=$(echo "$pr_info" | jq -r '.url')
    
    echo "标题: $title"
    echo "可合并: $mergeable"
    
    # 检查CI状态
    echo "CI状态:"
    gh pr checks $pr 2>&1 | grep -E "(pass|fail|pending)" | head -3
    
    echo "链接: $url"
    echo ""
done

echo "✅ 检查完成！"
echo ""
echo "💡 建议："
echo "1. 优先合并标记为高优先级的PR"
echo "2. 确保CI测试全部通过后再合并"
echo "3. 按照doc/issues/0001-pr-merge-readiness-analysis.md中的建议顺序合并"