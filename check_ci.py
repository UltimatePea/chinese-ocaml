#!/usr/bin/env python3
from github_auth import get_github_data

# 获取PR详细信息
pr_data = get_github_data('/pulls/711')
print(f'合并状态: {pr_data.get("mergeable_state", "unknown")}')

# 获取PR的检查状态
try:
    checks = get_github_data(f'/commits/{pr_data["head"]["sha"]}/check-runs')
    print('CI检查状态:')
    all_completed = True
    all_success = True
    for check in checks['check_runs']:
        print(f'  {check["name"]}: {check["status"]} - {check["conclusion"]}')
        if check['status'] != 'completed':
            all_completed = False
        if check['conclusion'] not in ['success', 'skipped', None]:
            all_success = False
    
    print()
    print(f'所有检查完成: {all_completed}')
    print(f'所有检查成功: {all_success}')
    
    if all_completed and all_success:
        print('PR #711 准备合并!')
    elif all_completed and not all_success:
        print('PR #711 存在失败的检查，需要修复')
    else:
        print('PR #711 CI仍在进行中，请稍后再检查')
        
except Exception as e:
    print(f'无法获取CI检查状态: {e}')