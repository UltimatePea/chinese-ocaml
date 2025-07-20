#!/usr/bin/env python3
"""
获取PR #709的CI构建失败详细日志
"""

import json
import requests
from github_auth import get_installation_token

def get_pr_checks(pr_number):
    """获取PR的CI检查状态"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 获取PR详情
    pr_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}'
    pr_response = requests.get(pr_url, headers=headers)
    pr_response.raise_for_status()
    pr_data = pr_response.json()
    
    # 获取最新的commit SHA
    commit_sha = pr_data['head']['sha']
    print(f"PR #{pr_number} HEAD commit: {commit_sha}")
    
    # 获取commit的check runs
    checks_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/commits/{commit_sha}/check-runs'
    checks_response = requests.get(checks_url, headers=headers)
    checks_response.raise_for_status()
    checks_data = checks_response.json()
    
    print(f"发现 {checks_data['total_count']} 个检查")
    
    failed_jobs = []
    for check_run in checks_data['check_runs']:
        print(f"\n检查: {check_run['name']}")
        print(f"状态: {check_run['status']}")
        print(f"结论: {check_run.get('conclusion', 'N/A')}")
        print(f"开始时间: {check_run.get('started_at', 'N/A')}")
        print(f"完成时间: {check_run.get('completed_at', 'N/A')}")
        
        if check_run.get('conclusion') == 'failure':
            failed_jobs.append(check_run)
    
    return failed_jobs, commit_sha

def get_workflow_runs(commit_sha):
    """获取workflow runs"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 获取workflow runs
    runs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/runs?head_sha={commit_sha}'
    runs_response = requests.get(runs_url, headers=headers)
    runs_response.raise_for_status()
    runs_data = runs_response.json()
    
    return runs_data['workflow_runs']

def get_job_logs(run_id):
    """获取workflow run的所有jobs和日志"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # 获取jobs
    jobs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/runs/{run_id}/jobs'
    jobs_response = requests.get(jobs_url, headers=headers)
    jobs_response.raise_for_status()
    jobs_data = jobs_response.json()
    
    print(f"Workflow run {run_id} 包含 {jobs_data['total_count']} 个job")
    
    for job in jobs_data['jobs']:
        print(f"\nJob: {job['name']}")
        print(f"状态: {job['status']}")
        print(f"结论: {job.get('conclusion', 'N/A')}")
        print(f"Job ID: {job['id']}")
        
        if job.get('conclusion') == 'failure':
            print(f"\n=== 获取失败Job {job['id']} 的日志 ===")
            
            # 获取日志
            logs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/jobs/{job["id"]}/logs'
            logs_response = requests.get(logs_url, headers=headers)
            
            if logs_response.status_code == 200:
                logs = logs_response.text
                
                # 查找错误相关的日志
                lines = logs.split('\n')
                error_found = False
                
                # 查找构建失败的部分
                for i, line in enumerate(lines):
                    if ('Error:' in line or 'error:' in line or 'FAILED' in line or 
                        'Fatal error' in line or 'make: ***' in line or 'dune build' in line):
                        print(f"\n发现错误在第 {i+1} 行:")
                        # 显示错误前后的上下文
                        start = max(0, i - 10)
                        end = min(len(lines), i + 50)
                        for j in range(start, end):
                            marker = ">>> " if j == i else "    "
                            print(f"{marker}{j+1:4d}: {lines[j]}")
                        error_found = True
                        print("\n" + "="*80)
                
                if not error_found:
                    print("未发现明确的错误标志，显示最后的日志:")
                    for line in lines[-100:]:
                        print(line)
            else:
                print(f"无法获取日志，状态码: {logs_response.status_code}")

def main():
    try:
        pr_number = 709
        
        print(f"=== 检查PR #{pr_number}的CI状态 ===")
        
        # 获取PR的检查状态
        failed_jobs, commit_sha = get_pr_checks(pr_number)
        
        # 获取workflow runs
        print(f"\n=== 获取commit {commit_sha}的workflow runs ===")
        workflow_runs = get_workflow_runs(commit_sha)
        
        for run in workflow_runs:
            print(f"\nWorkflow: {run['name']}")
            print(f"状态: {run['status']}")
            print(f"结论: {run.get('conclusion', 'N/A')}")
            print(f"Run ID: {run['id']}")
            
            if run.get('conclusion') == 'failure':
                print(f"\n=== 分析失败的workflow run {run['id']} ===")
                get_job_logs(run['id'])
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())