#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'scripts'))

from github.github_auth import github_api_request

def close_duplicate_papa_issues():
    """关闭重复的Papa战略规划issues"""
    
    # 需要关闭的重复issues及其关闭原因
    duplicate_issues = {
        1997: "重复战略规划 - 内容已整合到Issue #1998 Papa战略执行转换综合蓝图",
        1996: "功能重叠 - 统一协调功能已整合到Issue #1998",
        1974: "目标相同 - 协调中心功能已在Issue #1998中建立",
        1972: "内容重复 - Papa战略执行内容已合并到Issue #1998",
        1875: "规划性重复 - 战略实施总体规划已在Issue #1998中完善",
        1876: "已被更全面规划覆盖 - Poetry模块重构详细计划已在Issue #1998和Issue #1999中提供"
    }
    
    # 引用新的综合issue
    master_issue_ref = """

**注意**: 此issue的内容已整合到以下新的综合战略执行issue中:
- **主要协调**: Issue #1998 - 🎯 【Papa战略执行转换】骆言项目2025年8月技术实施综合蓝图
- **具体技术任务**: Issue #1999, #2000, #2001 - 具体的技术实施任务

请关注新的综合issue以获取最新的项目执行信息。

**Author: Papa, Project Planner - 战略整合完成**"""
    
    closed_count = 0
    
    for issue_number, close_reason in duplicate_issues.items():
        try:
            # 先添加关闭说明评论
            comment_data = {
                "body": f"## 🔄 Papa战略整合通知\n\n**关闭原因**: {close_reason}\n{master_issue_ref}"
            }
            
            print(f"正在为Issue #{issue_number}添加关闭说明...")
            comment_response = github_api_request(
                f'/repos/UltimatePea/chinese-ocaml/issues/{issue_number}/comments', 
                'POST', 
                comment_data
            )
            
            if comment_response.status_code == 201:
                print(f"✅ Issue #{issue_number} 关闭说明添加成功")
            else:
                print(f"⚠️ Issue #{issue_number} 评论添加失败: {comment_response.status_code}")
            
            # 关闭issue
            close_data = {
                "state": "closed",
                "state_reason": "completed"  # 表示任务已完成并整合
            }
            
            print(f"正在关闭Issue #{issue_number}...")
            close_response = github_api_request(
                f'/repos/UltimatePea/chinese-ocaml/issues/{issue_number}', 
                'PATCH', 
                close_data
            )
            
            if close_response.status_code == 200:
                print(f"✅ Issue #{issue_number} 关闭成功")
                closed_count += 1
            else:
                print(f"❌ Issue #{issue_number} 关闭失败: {close_response.status_code}")
                print(f"响应: {close_response.text}")
                
        except Exception as e:
            print(f"❌ 处理Issue #{issue_number}时出错: {e}")
    
    return closed_count

if __name__ == "__main__":
    print("🔄 开始关闭重复的Papa战略规划issues...")
    closed = close_duplicate_papa_issues()
    print(f"\n🎯 总结: 成功关闭了 {closed} 个重复的Papa战略规划issues")
    if closed > 0:
        print("✅ Papa战略整合完成！项目现在有清晰的执行方向和具体的技术任务。")
        print("🚀 技术实施阶段正式启动！")