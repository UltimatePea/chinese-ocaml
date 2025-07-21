#\!/usr/bin/env python3
"""
获取GitHub Issues和PRs的详细信息
"""

import json
from github_auth import get_github_data, get_installation_token
import requests

def get_issue_details(issue_number):
    """获取issue的详细信息"""
    print(f"=== Issue #{issue_number} 详细信息 ===")
    
    # 获取issue信息
    issue_data = get_github_data(f'/issues/{issue_number}')
    
    print(f"标题: {issue_data['title']}")
    print(f"作者: {issue_data['user']['login']}")
    print(f"状态: {issue_data['state']}")
    print(f"创建时间: {issue_data['created_at']}")
    print(f"更新时间: {issue_data['updated_at']}")
    print(f"描述:")
    print(issue_data['body'] or "无描述")
    print()
    
    # 获取comments
    comments = get_github_data(f'/issues/{issue_number}/comments')
    if comments:
        print("评论:")
        for i, comment in enumerate(comments, 1):
            print(f"  评论 {i} (作者: {comment['user']['login']}, 时间: {comment['created_at']}):")
            print(f"    {comment['body']}")
            print()
    else:
        print("无评论")
    
    print("-" * 80)

def get_pr_details(pr_number):
    """获取PR的详细信息"""
    print(f"=== Pull Request #{pr_number} 详细信息 ===")
    
    # 获取PR信息
    pr_data = get_github_data(f'/pulls/{pr_number}')
    
    print(f"标题: {pr_data['title']}")
    print(f"作者: {pr_data['user']['login']}")
    print(f"状态: {pr_data['state']}")
    print(f"创建时间: {pr_data['created_at']}")
    print(f"更新时间: {pr_data['updated_at']}")
    print(f"来源分支: {pr_data['head']['ref']}")
    print(f"目标分支: {pr_data['base']['ref']}")
    print(f"可合并: {pr_data.get('mergeable', 'unknown')}")
    print(f"合并状态: {pr_data.get('mergeable_state', 'unknown')}")
    print(f"描述:")
    print(pr_data['body'] or "无描述")
    print()
    
    # 获取CI状态
    print("=== CI状态检查 ===")
    statuses = get_github_data(f'/commits/{pr_data["head"]["sha"]}/status')
    print(f"总体状态: {statuses.get('state', 'unknown')}")
    
    if 'statuses' in statuses and statuses['statuses']:
        print("详细状态:")
        for status in statuses['statuses']:
            print(f"  - {status['context']}: {status['state']}")
            if status.get('description'):
                print(f"    描述: {status['description']}")
            if status.get('target_url'):
                print(f"    链接: {status['target_url']}")
    
    # 获取check runs (GitHub Actions)
    check_runs = get_github_data(f'/commits/{pr_data["head"]["sha"]}/check-runs')
    if 'check_runs' in check_runs and check_runs['check_runs']:
        print("GitHub Actions 检查:")
        for check in check_runs['check_runs']:
            print(f"  - {check['name']}: {check['status']} / {check['conclusion']}")
            if check.get('html_url'):
                print(f"    链接: {check['html_url']}")
    
    # 获取PR comments
    comments = get_github_data(f'/issues/{pr_number}/comments')
    if comments:
        print("评论:")
        for i, comment in enumerate(comments, 1):
            print(f"  评论 {i} (作者: {comment['user']['login']}, 时间: {comment['created_at']}):")
            print(f"    {comment['body']}")
            print()
    else:
        print("无评论")
    
    print("-" * 80)

def main():
    try:
        # 获取Issue #728详情
        get_issue_details(728)
        
        # 获取Issue #729详情 (注意这是PR，但API中也作为issue)
        get_issue_details(729)
        
        # 获取PR #729详情
        get_pr_details(729)
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())
