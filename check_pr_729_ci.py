#!/usr/bin/env python3
"""
检查PR #729和commit fd6c8a86的CI状态
"""

import json
import requests
from github_auth import get_installation_token

def get_github_data(endpoint):
    """使用installation token获取GitHub数据"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml{endpoint}'
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    return response.json()

def check_pr_status(pr_number):
    """检查指定PR的状态和CI"""
    print(f"=== 检查 PR #{pr_number} 状态 ===")
    
    # 获取PR基本信息
    pr_data = get_github_data(f'/pulls/{pr_number}')
    print(f"PR标题: {pr_data['title']}")
    print(f"状态: {pr_data['state']}")
    print(f"可合并: {pr_data.get('mergeable', 'unknown')}")
    print(f"合并状态: {pr_data.get('mergeable_state', 'unknown')}")
    print(f"最新commit: {pr_data['head']['sha']}")
    print(f"创建时间: {pr_data['created_at']}")
    print(f"更新时间: {pr_data['updated_at']}")
    print()
    
    # 获取PR的所有commits
    print("=== PR的所有commits ===")
    commits = get_github_data(f'/pulls/{pr_number}/commits')
    for i, commit in enumerate(commits):
        commit_sha = commit['sha']
        commit_message = commit['commit']['message'].strip().split('\n')[0]
        commit_time = commit['commit']['author']['date']
        print(f"{i+1}. {commit_sha[:8]} - {commit_message}")
        print(f"   时间: {commit_time}")
        
        # 检查这个commit是否是fd6c8a86
        if commit_sha.startswith('fd6c8a86'):
            print(f"   *** 这是我们要找的commit fd6c8a86 ***")
    print()
    
    return pr_data['head']['sha']

def check_commit_ci(commit_sha, description=""):
    """检查指定commit的CI状态"""
    print(f"=== 检查commit {commit_sha[:8]} 的CI状态 {description} ===")
    
    try:
        # 获取Actions workflow runs
        runs_data = get_github_data(f'/actions/runs?head_sha={commit_sha}')
        
        if runs_data['workflow_runs']:
            print(f"找到 {len(runs_data['workflow_runs'])} 个workflow runs:")
            for run in runs_data['workflow_runs']:
                print(f"  工作流: {run['name']}")
                print(f"  状态: {run['status']}")
                print(f"  结论: {run.get('conclusion', 'N/A')}")
                print(f"  分支: {run['head_branch']}")
                print(f"  运行号: {run['run_number']}")
                print(f"  开始时间: {run['created_at']}")
                if run['updated_at']:
                    print(f"  更新时间: {run['updated_at']}")
                print(f"  URL: {run['html_url']}")
                
                # 获取这个workflow run的jobs
                try:
                    jobs_data = get_github_data(f"/actions/runs/{run['id']}/jobs")
                    if jobs_data['jobs']:
                        print(f"  Jobs:")
                        for job in jobs_data['jobs']:
                            print(f"    - {job['name']}: {job['status']} ({job.get('conclusion', 'N/A')})")
                            if job.get('conclusion') == 'failure':
                                print(f"      失败时间: {job.get('completed_at', 'N/A')}")
                except Exception as e:
                    print(f"    获取jobs失败: {e}")
                print()
        else:
            print("没有找到相关的workflow runs")
    except Exception as e:
        print(f"获取workflow runs失败: {e}")
    
    try:
        # 获取commit status
        status_data = get_github_data(f'/commits/{commit_sha}/status')
        print(f"Commit Status: {status_data['state']}")
        if status_data['statuses']:
            for status in status_data['statuses']:
                print(f"  - {status['context']}: {status['state']}")
                if status.get('description'):
                    print(f"    描述: {status['description']}")
        print()
    except Exception as e:
        print(f"获取commit status失败: {e}")
    
    try:
        # 获取check runs
        check_runs_data = get_github_data(f'/commits/{commit_sha}/check-runs')
        if check_runs_data['check_runs']:
            print("Check Runs:")
            for check in check_runs_data['check_runs']:
                print(f"  - {check['name']}: {check['status']} ({check.get('conclusion', 'N/A')})")
                if check.get('html_url'):
                    print(f"    URL: {check['html_url']}")
        print()
    except Exception as e:
        print(f"获取check runs失败: {e}")

def find_commit_in_pr(pr_number, target_commit_prefix):
    """在PR中查找指定的commit"""
    commits = get_github_data(f'/pulls/{pr_number}/commits')
    for commit in commits:
        if commit['sha'].startswith(target_commit_prefix):
            return commit['sha']
    return None

def main():
    try:
        # 1. 检查PR #729的状态
        latest_commit = check_pr_status(729)
        
        # 2. 检查PR的最新commit的CI状态
        check_commit_ci(latest_commit, "(PR最新commit)")
        
        # 3. 查找并检查commit fd6c8a86
        target_commit = find_commit_in_pr(729, 'fd6c8a86')
        if target_commit:
            print(f"找到目标commit: {target_commit}")
            check_commit_ci(target_commit, "(目标commit fd6c8a86)")
        else:
            print("在PR #729中没有找到以fd6c8a86开头的commit")
            print("尝试直接检查commit fd6c8a86...")
            try:
                # 尝试检查可能的完整SHA
                possible_shas = [
                    'fd6c8a86',
                    'fd6c8a869e1f1a6e4c8a2b3c4d5e6f7g8h9i0j1k',  # 假设的完整SHA
                ]
                for sha in possible_shas:
                    try:
                        check_commit_ci(sha, f"(直接检查 {sha})")
                        break
                    except Exception as e:
                        print(f"检查 {sha} 失败: {e}")
            except Exception as e:
                print(f"直接检查也失败: {e}")
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())