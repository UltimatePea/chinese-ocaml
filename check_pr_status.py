#!/usr/bin/env python3
"""
检查特定PR的详细状态
"""

import json
import requests
from github_auth import get_installation_token

def get_pr_details(pr_number):
    """获取PR的详细信息"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 获取PR基本信息
    pr_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}'
    pr_response = requests.get(pr_url, headers=headers)
    pr_response.raise_for_status()
    pr_data = pr_response.json()
    
    # 获取PR的状态检查信息
    status_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/commits/{pr_data["head"]["sha"]}/status'
    status_response = requests.get(status_url, headers=headers)
    status_response.raise_for_status()
    status_data = status_response.json()
    
    # 获取PR的检查运行信息
    checks_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/commits/{pr_data["head"]["sha"]}/check-runs'
    checks_response = requests.get(checks_url, headers=headers)
    checks_response.raise_for_status()
    checks_data = checks_response.json()
    
    # 获取PR的评论
    comments_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}/comments'
    comments_response = requests.get(comments_url, headers=headers)
    comments_response.raise_for_status()
    comments_data = comments_response.json()
    
    # 获取PR的reviews
    reviews_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}/reviews'
    reviews_response = requests.get(reviews_url, headers=headers)
    reviews_response.raise_for_status()
    reviews_data = reviews_response.json()
    
    return {
        'pr': pr_data,
        'status': status_data,
        'checks': checks_data,
        'comments': comments_data,
        'reviews': reviews_data
    }

def main():
    try:
        pr_number = 733
        data = get_pr_details(pr_number)
        
        pr = data['pr']
        print(f"=== PR #{pr_number} 详细状态 ===")
        print(f"标题: {pr['title']}")
        print(f"状态: {pr['state']}")
        print(f"作者: {pr['user']['login']}")
        print(f"创建时间: {pr['created_at']}")
        print(f"更新时间: {pr['updated_at']}")
        print()
        
        print("=== 合并状态 ===")
        print(f"可合并: {pr.get('mergeable', 'unknown')}")
        print(f"合并状态: {pr.get('mergeable_state', 'unknown')}")
        print(f"分支: {pr['head']['ref']} -> {pr['base']['ref']}")
        print(f"HEAD SHA: {pr['head']['sha']}")
        print()
        
        print("=== CI/CD 状态检查 ===")
        status = data['status']
        print(f"总体状态: {status['state']}")
        if status['statuses']:
            for s in status['statuses']:
                print(f"  - {s['context']}: {s['state']} ({s.get('description', 'No description')})")
        else:
            print("  无状态检查")
        print()
        
        print("=== 检查运行 ===")
        checks = data['checks']
        if checks['check_runs']:
            for check in checks['check_runs']:
                print(f"  - {check['name']}: {check['status']} / {check['conclusion']}")
        else:
            print("  无检查运行")
        print()
        
        print("=== 评论 ===")
        comments = data['comments']
        if comments:
            for comment in comments:
                print(f"  - {comment['user']['login']} 在 {comment['created_at']} 评论:")
                print(f"    {comment['body'][:100]}...")
        else:
            print("  无评论")
        print()
        
        print("=== 代码审查 ===")
        reviews = data['reviews']
        if reviews:
            for review in reviews:
                print(f"  - {review['user']['login']} 在 {review['submitted_at']} 提交审查:")
                print(f"    状态: {review['state']}")
                if review['body']:
                    print(f"    评论: {review['body'][:100]}...")
        else:
            print("  无代码审查")
        print()
        
        # 检查是否可以安全合并
        print("=== 合并安全性评估 ===")
        can_merge = True
        issues = []
        
        if pr.get('mergeable') is False:
            can_merge = False
            issues.append("存在合并冲突")
        
        if status['state'] in ['failure', 'error']:
            can_merge = False
            issues.append("CI/CD检查失败")
        
        if pr['state'] != 'open':
            can_merge = False
            issues.append("PR状态不是开放状态")
        
        if can_merge:
            print("✅ PR可以安全合并")
        else:
            print("❌ PR不能安全合并，存在以下问题:")
            for issue in issues:
                print(f"  - {issue}")
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())