#!/usr/bin/env python3
"""
合并PR的工具脚本
"""

import sys
import requests
from github_auth import get_installation_token

def merge_pr(pr_number, merge_method="squash"):
    """合并指定的PR"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 首先检查PR状态
    pr_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}'
    pr_response = requests.get(pr_url, headers=headers)
    pr_response.raise_for_status()
    pr_data = pr_response.json()
    
    if pr_data['state'] != 'open':
        print(f"错误: PR #{pr_number} 不是开放状态，当前状态: {pr_data['state']}")
        return False
    
    if not pr_data['mergeable']:
        print(f"错误: PR #{pr_number} 不可合并")
        return False
    
    # 执行合并
    merge_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}/merge'
    merge_data = {
        'commit_title': pr_data['title'],
        'commit_message': f"{pr_data['body']}\n\n🤖 自动合并技术债务修复",
        'merge_method': merge_method
    }
    
    merge_response = requests.put(merge_url, headers=headers, json=merge_data)
    
    if merge_response.status_code == 200:
        print(f"✅ 成功合并 PR #{pr_number}")
        result = merge_response.json()
        print(f"合并提交: {result['sha']}")
        return True
    else:
        print(f"❌ 合并失败: {merge_response.status_code}")
        print(merge_response.text)
        return False

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("用法: python3 merge_pr.py <PR号码>")
        sys.exit(1)
    
    pr_number = sys.argv[1]
    success = merge_pr(pr_number)
    sys.exit(0 if success else 1)