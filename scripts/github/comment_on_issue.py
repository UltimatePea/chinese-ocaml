#!/usr/bin/env python3
"""
GitHub Issue Comment Script
Comments on GitHub issues using the GitHub API
"""

import requests
import sys
import argparse
from github_auth import get_installation_token

def comment_on_issue(repo_owner, repo_name, issue_number, comment_body):
    """Comment on a GitHub issue"""
    token = get_installation_token()
    if not token:
        print("Failed to get GitHub token")
        return False
    
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/issues/{issue_number}/comments"
    
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json"
    }
    
    data = {
        "body": comment_body
    }
    
    try:
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 201:
            comment_data = response.json()
            print(f"评论创建成功！")
            print(f"评论ID: {comment_data['id']}")
            print(f"URL: {comment_data['html_url']}")
            return True
        else:
            print(f"评论创建失败: {response.status_code}")
            print(f"Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Comment on GitHub issue')
    parser.add_argument('--issue-number', type=int, required=True, help='Issue number')
    parser.add_argument('--comment', required=True, help='Comment body')
    parser.add_argument('--repo-owner', default='UltimatePea', help='Repository owner')
    parser.add_argument('--repo-name', default='chinese-ocaml', help='Repository name')
    
    args = parser.parse_args()
    
    success = comment_on_issue(args.repo_owner, args.repo_name, args.issue_number, args.comment)
    
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()