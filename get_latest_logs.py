#!/usr/bin/env python3
"""
获取最新的CI失败日志
"""

import json
import requests
from github_auth import get_installation_token

def get_job_logs(job_id):
    """获取特定job的日志"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    logs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/jobs/{job_id}/logs'
    logs_response = requests.get(logs_url, headers=headers)
    
    if logs_response.status_code == 200:
        return logs_response.text
    else:
        return f"无法获取日志，状态码: {logs_response.status_code}"

def main():
    try:
        # 从最新的run获取失败的job ID
        # 需要先获取run ID
        token = get_installation_token()
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json'
        }
        
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
            
            # 找到失败的build-and-test job
            for job in jobs_data['jobs']:
                if job['name'] == 'build-and-test' and job['conclusion'] == 'failure':
                    print(f"=== 获取Job {job['id']} 日志 ===")
                    logs = get_job_logs(job['id'])
                    
                    # 显示与构建错误相关的日志
                    lines = logs.split('\n')
                    error_context = []
                    
                    # 查找错误上下文
                    for i, line in enumerate(lines):
                        if 'Error:' in line or 'error:' in line or 'FAILED' in line:
                            # 显示错误前后的上下文
                            start = max(0, i - 10)
                            end = min(len(lines), i + 20)
                            error_context.extend(lines[start:end])
                            error_context.append("="*50)
                    
                    if error_context:
                        print("构建错误相关日志:")
                        for line in error_context:
                            print(line)
                    else:
                        # 如果没找到明确错误，显示最后部分
                        print("构建失败，显示最后200行日志:")
                        for line in lines[-200:]:
                            print(line)
                    break
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())