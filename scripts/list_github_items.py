#!/usr/bin/env python3
"""
列出GitHub Issues和PRs
"""

import json
import sys
import os
import requests

# Add current directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'ci'))

from github_auth import get_installation_token, generate_jwt

def get_github_data(path):
    """获取GitHub API数据"""
    jwt_token = generate_jwt()
    token = get_installation_token(jwt_token)
    
    if not token:
        raise Exception("无法获取GitHub访问token")
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml{path}'
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    return response.json()

def list_issues():
    """列出开放的issues"""
    print("=== 开放的Issues ===")
    
    try:
        issues = get_github_data('/issues?state=open&per_page=20')
        
        if not issues:
            print("无开放的issues")
            return
            
        for issue in issues:
            # 过滤掉pull requests
            if 'pull_request' not in issue:
                print(f"Issue #{issue['number']}: {issue['title']}")
                print(f"  作者: {issue['user']['login']}")
                print(f"  创建时间: {issue['created_at']}")
                print(f"  标签: {', '.join([label['name'] for label in issue['labels']])}")
                print()
                
    except Exception as e:
        print(f"获取issues时出错: {e}")

def list_prs():
    """列出开放的pull requests"""
    print("=== 开放的Pull Requests ===")
    
    try:
        prs = get_github_data('/pulls?state=open&per_page=20')
        
        if not prs:
            print("无开放的pull requests")
            return
            
        for pr in prs:
            print(f"PR #{pr['number']}: {pr['title']}")
            print(f"  作者: {pr['user']['login']}")
            print(f"  分支: {pr['head']['ref']} -> {pr['base']['ref']}")
            print(f"  创建时间: {pr['created_at']}")
            print(f"  可合并: {pr.get('mergeable', 'unknown')}")
            print()
                
    except Exception as e:
        print(f"获取PRs时出错: {e}")

def main():
    list_issues()
    print("\n" + "="*60 + "\n")
    list_prs()
    return 0

if __name__ == '__main__':
    exit(main())