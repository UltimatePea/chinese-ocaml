#!/usr/bin/env python3
"""
检查特定commit的CI状态
"""

import json
import requests
from github_auth import get_installation_token

def get_ci_status(commit_sha):
    """获取指定commit的CI状态"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 获取workflow runs
    runs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/runs'
    params = {'head_sha': commit_sha}
    runs_response = requests.get(runs_url, headers=headers, params=params)
    runs_response.raise_for_status()
    runs_data = runs_response.json()
    
    return runs_data

def main():
    try:
        # 使用当前HEAD的SHA
        commit_sha = "34417fc206392787835ab153cdad32d7455e9520"
        
        print(f"=== CI状态检查 (commit: {commit_sha[:8]}) ===")
        
        data = get_ci_status(commit_sha)
        
        if data['workflow_runs']:
            for run in data['workflow_runs']:
                print(f"工作流: {run['name']}")
                print(f"状态: {run['status']}")
                print(f"结论: {run['conclusion']}")
                print(f"分支: {run['head_branch']}")
                print(f"开始时间: {run['created_at']}")
                if run['updated_at']:
                    print(f"更新时间: {run['updated_at']}")
                print(f"URL: {run['html_url']}")
                print()
        else:
            print("没有找到相关的workflow runs")
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())