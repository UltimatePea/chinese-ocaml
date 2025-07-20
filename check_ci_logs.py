#!/usr/bin/env python3
"""
检查CI详细日志
"""

import json
import requests
from github_auth import get_installation_token

def get_workflow_run_jobs(run_id):
    """获取workflow run的具体jobs"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    jobs_url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/actions/runs/{run_id}/jobs'
    jobs_response = requests.get(jobs_url, headers=headers)
    jobs_response.raise_for_status()
    
    return jobs_response.json()

def main():
    try:
        # 使用从上面获取的run ID
        run_id = "16404131019"
        
        print(f"=== CI Jobs详细状态 (run_id: {run_id}) ===")
        
        data = get_workflow_run_jobs(run_id)
        
        if data['jobs']:
            for job in data['jobs']:
                print(f"Job: {job['name']}")
                print(f"状态: {job['status']}")
                print(f"结论: {job['conclusion']}")
                print(f"开始时间: {job['started_at']}")
                if job['completed_at']:
                    print(f"完成时间: {job['completed_at']}")
                print(f"运行器: {job['runner_name']}")
                print(f"URL: {job['html_url']}")
                
                # 显示步骤详情
                if job['steps']:
                    print("步骤:")
                    for step in job['steps']:
                        status_icon = "✅" if step['conclusion'] == 'success' else "❌" if step['conclusion'] == 'failure' else "🔄" if step['status'] == 'in_progress' else "⏸️"
                        print(f"  {status_icon} {step['name']}: {step['status']} / {step['conclusion']}")
                        if step['conclusion'] == 'failure':
                            print(f"    开始: {step['started_at']}")
                            if step['completed_at']:
                                print(f"    完成: {step['completed_at']}")
                print()
        else:
            print("没有找到jobs信息")
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())