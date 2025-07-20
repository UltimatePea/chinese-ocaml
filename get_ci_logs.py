#!/usr/bin/env python3
"""
获取CI构建失败的详细日志
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
        # 从之前的输出获取失败的job ID
        # build-and-test job ID: 46347642000
        job_id = "46347642000"
        
        print(f"=== Job {job_id} 详细日志 ===")
        
        logs = get_job_logs(job_id)
        
        # 只显示最后部分日志，特别是错误部分
        lines = logs.split('\n')
        error_start = -1
        
        # 查找构建失败的部分
        for i, line in enumerate(lines):
            if 'Build project' in line or 'dune build' in line:
                # 找到构建开始的地方
                for j in range(i, len(lines)):
                    if 'Error:' in lines[j] or 'error:' in lines[j] or 'FAILED' in lines[j]:
                        error_start = max(0, j - 20)  # 显示错误前20行
                        break
                break
        
        if error_start >= 0:
            print("构建失败相关日志:")
            for line in lines[error_start:error_start + 100]:  # 显示100行日志
                print(line)
        else:
            # 如果没找到明确的错误，显示最后的日志
            print("构建日志的最后部分:")
            for line in lines[-200:]:  # 显示最后200行
                print(line)
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())