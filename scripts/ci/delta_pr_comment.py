#!/usr/bin/env python3
"""
Delta代理PR评论工具
"""

import requests
import time
import jwt
import argparse
from pathlib import Path

# GitHub App 配置
APP_ID = '1595512'
INSTALLATION_ID = '75590650'
PRIVATE_KEY_PATH = '../../claudeai-v1.pem'

def generate_jwt():
    private_key_path = Path('/home/zc/chinese-ocaml-worktrees/claudeai-v1.pem')
    
    with open(private_key_path, 'r') as f:
        private_key = f.read()
    
    now = int(time.time())
    payload = {
        'iat': now,
        'exp': now + 600,
        'iss': APP_ID
    }
    
    return jwt.encode(payload, private_key, algorithm='RS256')

def get_installation_token():
    jwt_token = generate_jwt()
    
    headers = {
        'Authorization': f'Bearer {jwt_token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/app/installations/{INSTALLATION_ID}/access_tokens'
    
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    
    return response.json()['token']

def comment_on_pr(pr_number, comment):
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues/{pr_number}/comments'
    
    data = {
        'body': comment
    }
    
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    
    return response.json()

def main():
    parser = argparse.ArgumentParser(description='Add comment to PR')
    parser.add_argument('--pr', type=int, required=True, help='PR number')
    parser.add_argument('--comment', required=True, help='Comment content')
    
    args = parser.parse_args()
    
    try:
        result = comment_on_pr(args.pr, args.comment)
        print(f'✅ Comment added to PR #{args.pr}')
        print(f'Comment ID: {result["id"]}')
    except Exception as e:
        print(f'❌ Failed to add comment: {e}')

if __name__ == '__main__':
    main()