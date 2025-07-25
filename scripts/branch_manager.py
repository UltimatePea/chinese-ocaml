#!/usr/bin/env python3
"""
骆言项目分支清理工具
安全清理已合并的远程分支，提升项目可维护性
"""

import subprocess
import sys
import re
from datetime import datetime, timedelta
import argparse

def run_git_command(cmd):
    """执行Git命令并返回输出"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Git命令执行失败: {cmd}")
        print(f"错误: {e.stderr}")
        return None

def get_merged_branches():
    """获取已合并到main的远程分支"""
    output = run_git_command("git branch -r --merged main")
    if not output:
        return []
    
    branches = []
    for line in output.split('\n'):
        branch = line.strip()
        if branch and '->' not in branch and 'origin/main' not in branch:
            branches.append(branch)
    return branches

def get_claude_temp_branches():
    """获取claude临时分支（claude/issue-*模式）"""
    output = run_git_command("git branch -r")
    if not output:
        return []
    
    claude_branches = []
    for line in output.split('\n'):
        branch = line.strip()
        if 'claude/issue-' in branch:
            claude_branches.append(branch)
    return claude_branches

def get_old_feature_branches():
    """获取可能过时的feature分支（需要手动确认）"""
    output = run_git_command("git branch -r")
    if not output:
        return []
    
    feature_branches = []
    for line in output.split('\n'):
        branch = line.strip()
        if ('feature/' in branch or 'fix/' in branch) and 'origin/' in branch:
            # 检查最后提交时间
            branch_name = branch.replace('origin/', '')
            last_commit = run_git_command(f"git log -1 --format=%at {branch}")
            if last_commit:
                try:
                    commit_time = datetime.fromtimestamp(int(last_commit))
                    if commit_time < datetime.now() - timedelta(days=30):
                        feature_branches.append((branch, commit_time))
                except ValueError:
                    pass
    return feature_branches

def safe_delete_branch(branch_name):
    """安全删除远程分支"""
    # 移除origin/前缀
    if branch_name.startswith('origin/'):
        remote_branch = branch_name[7:]  # 移除'origin/'
    else:
        remote_branch = branch_name
    
    print(f"删除远程分支: {remote_branch}")
    cmd = f"git push origin --delete {remote_branch}"
    result = run_git_command(cmd)
    return result is not None

def analyze_branches():
    """分析分支情况"""
    print("=== 骆言项目分支分析 ===\n")
    
    # 统计总分支数
    all_branches = run_git_command("git branch -r").split('\n') if run_git_command("git branch -r") else []
    total_count = len([b for b in all_branches if b.strip() and '->' not in b])
    print(f"总远程分支数: {total_count}")
    
    # 已合并分支
    merged_branches = get_merged_branches()
    print(f"已合并到main的分支: {len(merged_branches)}")
    
    # Claude临时分支
    claude_branches = get_claude_temp_branches()
    print(f"Claude临时分支(claude/issue-*): {len(claude_branches)}")
    
    # 可能过时的feature分支
    old_feature_branches = get_old_feature_branches()
    print(f"超过30天无提交的feature/fix分支: {len(old_feature_branches)}")
    
    print("\n=== 清理建议 ===")
    print(f"可安全清理的已合并分支: {len(merged_branches)}")
    print(f"可清理的Claude临时分支: {len(claude_branches)}")
    print(f"需要确认的老旧分支: {len(old_feature_branches)}")
    
    total_cleanable = len(merged_branches) + len(claude_branches)
    print(f"\n预计清理后分支数: {total_count - total_cleanable}")
    
    return merged_branches, claude_branches, old_feature_branches

def cleanup_merged_branches(dry_run=True):
    """清理已合并的分支"""
    merged_branches = get_merged_branches()
    
    print(f"\n=== 清理已合并分支 ({'预览模式' if dry_run else '执行模式'}) ===")
    
    success_count = 0
    for branch in merged_branches:
        if dry_run:
            print(f"[预览] 将删除: {branch}")
        else:
            if safe_delete_branch(branch):
                print(f"[完成] 已删除: {branch}")
                success_count += 1
            else:
                print(f"[失败] 无法删除: {branch}")
    
    if not dry_run:
        print(f"\n成功删除 {success_count}/{len(merged_branches)} 个已合并分支")
    
    return success_count

def cleanup_claude_branches(dry_run=True):
    """清理Claude临时分支"""
    claude_branches = get_claude_temp_branches()
    
    print(f"\n=== 清理Claude临时分支 ({'预览模式' if dry_run else '执行模式'}) ===")
    
    success_count = 0
    for branch in claude_branches:
        if dry_run:
            print(f"[预览] 将删除: {branch}")
        else:
            if safe_delete_branch(branch):
                print(f"[完成] 已删除: {branch}")
                success_count += 1
            else:
                print(f"[失败] 无法删除: {branch}")
    
    if not dry_run:
        print(f"\n成功删除 {success_count}/{len(claude_branches)} 个Claude临时分支")
    
    return success_count

def main():
    parser = argparse.ArgumentParser(description='骆言项目分支清理工具')
    parser.add_argument('--analyze', action='store_true', help='分析分支情况')
    parser.add_argument('--cleanup-merged', action='store_true', help='清理已合并分支')
    parser.add_argument('--cleanup-claude', action='store_true', help='清理Claude临时分支')
    parser.add_argument('--cleanup-all', action='store_true', help='清理所有可安全清理的分支')
    parser.add_argument('--dry-run', action='store_true', default=True, help='预览模式（默认）')
    parser.add_argument('--execute', action='store_true', help='执行模式（实际删除）')
    
    args = parser.parse_args()
    
    # 如果指定了--execute，则关闭dry_run
    if args.execute:
        args.dry_run = False
    
    if args.analyze or (not any([args.cleanup_merged, args.cleanup_claude, args.cleanup_all])):
        analyze_branches()
    
    if args.cleanup_merged or args.cleanup_all:
        cleanup_merged_branches(args.dry_run)
    
    if args.cleanup_claude or args.cleanup_all:
        cleanup_claude_branches(args.dry_run)
    
    if args.dry_run and (args.cleanup_merged or args.cleanup_claude or args.cleanup_all):
        print("\n注意: 当前为预览模式，使用 --execute 参数实际执行删除操作")

if __name__ == '__main__':
    main()