#!/usr/bin/env python3
"""
检查最新的CI失败原因
"""

import json
import requests
from github_auth import get_installation_token

def get_latest_run():
    """获取最新的workflow run"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 获取最新的SHA
    commit_sha = "0f4408234bc118f4882d764f6f16a3e86a55c6a5"
    
    # 获取workflow runs
    runs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/runs'
    params = {'head_sha': commit_sha}
    runs_response = requests.get(runs_url, headers=headers, params=params)
    runs_response.raise_for_status()
    runs_data = runs_response.json()
    
    if runs_data['workflow_runs']:
        latest_run = runs_data['workflow_runs'][0]
        run_id = latest_run['id']
        
        # 获取job详情
        jobs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/runs/{run_id}/jobs'
        jobs_response = requests.get(jobs_url, headers=headers)
        jobs_response.raise_for_status()
        jobs_data = jobs_response.json()
        
        return latest_run, jobs_data
    
    return None, None

def main():
    try:
        run, jobs = get_latest_run()
        
        if not run:
            print("没有找到相关的workflow run")
            return
        
        print(f"=== 最新CI状态 (run_id: {run['id']}) ===")
        print(f"状态: {run['status']} / {run['conclusion']}")
        print(f"开始时间: {run['created_at']}")
        print(f"更新时间: {run['updated_at']}")
        print()
        
        if jobs and jobs['jobs']:
            for job in jobs['jobs']:
                print(f"Job: {job['name']}")
                print(f"状态: {job['status']} / {job['conclusion']}")
                
                if job['conclusion'] == 'failure':
                    print("失败的步骤:")
                    for step in job['steps']:
                        if step['conclusion'] == 'failure':
                            print(f"  ❌ {step['name']}")
                            print(f"    开始: {step['started_at']}")
                            if step['completed_at']:
                                print(f"    完成: {step['completed_at']}")
                print()
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())