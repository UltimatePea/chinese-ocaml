#!/usr/bin/env python3
"""
更新所有开放PR的描述，确保包含"Fix #issue-number"链接
用于响应Issue #142的要求
"""

import requests
import json
import os

# 获取GitHub token
def get_github_token():
    """获取GitHub API token"""
    import subprocess
    result = subprocess.run(['python3', 'github_auth.py'], capture_output=True, text=True)
    return result.stdout.strip()

def get_open_prs():
    """获取所有开放的PRs"""
    token = get_github_token()
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls?state=open&per_page=50'
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def update_pr_description(pr_number, current_body, title):
    """更新PR描述，确保包含Fix #number"""
    # 从标题中提取issue number
    import re
    match = re.search(r'Fix #(\d+)', title)
    if not match:
        print(f"PR #{pr_number}: 无法从标题中提取issue number")
        return False
    
    issue_number = match.group(1)
    fix_line = f"Fix #{issue_number}"
    
    # 检查描述是否已经包含Fix #number
    if current_body and current_body.startswith(fix_line):
        print(f"PR #{pr_number}: 已经包含正确的Fix #{issue_number}链接")
        return True
    
    # 创建新的描述
    if current_body:
        new_body = f"{fix_line}\n\n{current_body}"
    else:
        new_body = fix_line
    
    # 更新PR
    token = get_github_token()
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}'
    data = {'body': new_body}
    
    response = requests.patch(url, headers=headers, json=data)
    if response.status_code == 200:
        print(f"PR #{pr_number}: 成功更新描述")
        return True
    else:
        print(f"PR #{pr_number}: 更新失败 - {response.status_code}")
        return False

def main():
    """主函数"""
    print("开始更新所有开放PR的描述...")
    
    try:
        prs = get_open_prs()
        updated_count = 0
        
        for pr in prs:
            pr_number = pr['number']
            title = pr['title']
            current_body = pr['body']
            
            print(f"\n处理 PR #{pr_number}: {title}")
            
            if update_pr_description(pr_number, current_body, title):
                updated_count += 1
        
        print(f"\n完成！更新了 {updated_count} 个PR")
        
    except Exception as e:
        print(f"错误：{e}")
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())