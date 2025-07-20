#!/usr/bin/env python3
"""
获取GitHub issue详细信息
"""

import json
import time
import jwt
import requests
from pathlib import Path

# GitHub App 配置
APP_ID = "1595512"
INSTALLATION_ID = "75590650"
PRIVATE_KEY_PATH = "../claudeai-v1.pem"

def generate_jwt():
    """生成JWT token"""
    private_key_path = Path(__file__).parent / PRIVATE_KEY_PATH
    
    with open(private_key_path, 'r') as f:
        private_key = f.read()
    
    now = int(time.time())
    payload = {
        'iat': now,
        'exp': now + 600,  # 10分钟有效期
        'iss': APP_ID
    }
    
    return jwt.encode(payload, private_key, algorithm='RS256')

def get_installation_token():
    """获取installation token"""
    jwt_token = generate_jwt()
    
    headers = {
        'Authorization': f'Bearer {jwt_token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/app/installations/{INSTALLATION_ID}/access_tokens'
    
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    
    return response.json()['token']

def get_issue_details(issue_number):
    """获取指定issue的详细信息"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues/{issue_number}'
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    return response.json()

def main():
    """主函数"""
    try:
        issue = get_issue_details(705)
        print(f"Issue #{issue['number']}: {issue['title']}")
        print(f"作者: {issue['user']['login']}")
        print(f"状态: {issue['state']}")
        print(f"创建时间: {issue['created_at']}")
        print("\n--- 描述 ---")
        print(issue['body'])
        print("\n--- 标签 ---")
        for label in issue.get('labels', []):
            print(f"- {label['name']}")
            
    except Exception as e:
        print(f"错误: {e}")
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())