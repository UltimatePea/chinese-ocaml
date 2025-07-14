#!/usr/bin/env python3
"""
自动化处理所有PR合并冲突的工具
Fix #143: 需要重新处理所有pr的merge conflict

这个脚本将：
1. 获取所有开放的PR列表
2. 检查每个PR的合并状态
3. 自动处理可以解决的合并冲突
4. 生成详细的处理报告
"""

import subprocess
import json
import sys
import time
from typing import List, Dict, Any

def run_command(cmd: List[str], capture_output=True) -> subprocess.CompletedProcess:
    """执行命令并返回结果"""
    print(f"执行命令: {' '.join(cmd)}")
    if capture_output:
        result = subprocess.run(cmd, capture_output=True, text=True)
    else:
        result = subprocess.run(cmd)
    return result

def get_open_prs() -> List[Dict[str, Any]]:
    """获取所有开放的PR列表"""
    result = run_command(['gh', 'pr', 'list', '--state=open', '--json', 'number,title,headRefName,baseRefName,mergeable'])
    if result.returncode != 0:
        print(f"获取PR列表失败: {result.stderr}")
        return []
    
    try:
        prs = json.loads(result.stdout)
        return prs
    except json.JSONDecodeError:
        print("解析PR列表JSON失败")
        return []

def get_pr_details(pr_number: int) -> Dict[str, Any]:
    """获取PR的详细信息"""
    result = run_command(['gh', 'pr', 'view', str(pr_number), '--json', 'number,title,headRefName,baseRefName,mergeable,mergeStateStatus'])
    if result.returncode != 0:
        print(f"获取PR {pr_number} 详情失败: {result.stderr}")
        return {}
    
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        print(f"解析PR {pr_number} 详情JSON失败")
        return {}

def fix_pr_merge_conflict(pr_number: int, branch_name: str) -> bool:
    """修复指定PR的合并冲突"""
    print(f"\n🔧 开始处理PR #{pr_number} 的合并冲突...")
    
    # 保存当前分支
    current_branch_result = run_command(['git', 'branch', '--show-current'])
    if current_branch_result.returncode != 0:
        print("无法获取当前分支")
        return False
    current_branch = current_branch_result.stdout.strip()
    
    try:
        # 1. 切换到PR分支
        print(f"切换到分支: {branch_name}")
        result = run_command(['git', 'checkout', branch_name])
        if result.returncode != 0:
            print(f"切换分支失败: {result.stderr}")
            return False
        
        # 2. 拉取最新的分支状态
        print(f"拉取最新的分支状态")
        result = run_command(['git', 'pull', 'origin', branch_name])
        if result.returncode != 0:
            print(f"拉取分支失败，继续处理...")
        
        # 3. 获取最新的main分支
        print("获取最新的main分支")
        result = run_command(['git', 'fetch', 'origin', 'main'])
        if result.returncode != 0:
            print(f"拉取main分支失败: {result.stderr}")
            return False
        
        # 4. 尝试合并main分支
        print("尝试合并main分支")
        result = run_command(['git', 'merge', 'origin/main'])
        
        if result.returncode == 0:
            print("✅ 合并成功，无冲突")
            # 推送更新
            push_result = run_command(['git', 'push', 'origin', branch_name])
            if push_result.returncode == 0:
                print("✅ 推送成功")
                return True
            else:
                print(f"❌ 推送失败: {push_result.stderr}")
                return False
        else:
            print("⚠️  检测到合并冲突，需要手动解决")
            # 取消合并
            run_command(['git', 'merge', '--abort'])
            print("已取消合并，PR需要手动处理")
            return False
            
    except Exception as e:
        print(f"处理PR {pr_number} 时发生错误: {e}")
        return False
    finally:
        # 恢复到原始分支
        print(f"恢复到原始分支: {current_branch}")
        run_command(['git', 'checkout', current_branch])

def main():
    """主函数"""
    print("🚀 开始处理所有PR的合并冲突...")
    print("=" * 50)
    
    # 获取所有开放的PR
    prs = get_open_prs()
    if not prs:
        print("没有找到开放的PR")
        return
    
    print(f"找到 {len(prs)} 个开放的PR")
    
    # 处理结果统计
    success_count = 0
    failed_count = 0
    skip_count = 0
    
    processed_prs = []
    
    for pr in prs:
        pr_number = pr['number']
        title = pr['title']
        branch_name = pr['headRefName']
        
        print(f"\n📋 处理PR #{pr_number}: {title}")
        print(f"   分支: {branch_name}")
        
        # 获取详细信息检查合并状态
        details = get_pr_details(pr_number)
        if not details:
            print("❌ 无法获取PR详情，跳过")
            skip_count += 1
            continue
        
        # 尝试修复合并冲突
        success = fix_pr_merge_conflict(pr_number, branch_name)
        
        status = "成功" if success else "失败"
        processed_prs.append({
            'number': pr_number,
            'title': title,
            'branch': branch_name,
            'status': status
        })
        
        if success:
            success_count += 1
        else:
            failed_count += 1
        
        # 短暂延迟，避免过于频繁的操作
        time.sleep(1)
    
    # 生成处理报告
    print("\n" + "=" * 50)
    print("🏆 处理完成总结")
    print("=" * 50)
    print(f"总计PR数量: {len(prs)}")
    print(f"成功处理: {success_count}")
    print(f"处理失败: {failed_count}")
    print(f"跳过处理: {skip_count}")
    
    print("\n📊 详细结果:")
    for pr_info in processed_prs:
        status_emoji = "✅" if pr_info['status'] == "成功" else "❌"
        print(f"  {status_emoji} PR #{pr_info['number']}: {pr_info['title']} ({pr_info['status']})")
    
    if failed_count > 0:
        print(f"\n⚠️  有 {failed_count} 个PR需要手动处理合并冲突")
        print("请查看上述详细日志，手动解决冲突后重新运行此脚本")
    
    print("\n🎯 下一步建议:")
    print("1. 检查所有PR的CI状态")
    print("2. 通知维护者审核已更新的PR")
    print("3. 对于失败的PR，手动解决冲突后重新运行脚本")

if __name__ == "__main__":
    main()