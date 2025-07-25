#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from github_auth import get_installation_token
import requests
import json

def comment_on_issue(issue_number, comment_body):
    """Add comment to GitHub issue"""
    
    try:
        token = get_installation_token()
        if not token:
            print("Failed to get authentication token")
            return False
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
        }
        
        comment_data = {
            'body': comment_body
        }
        
        response = requests.post(
            f'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues/{issue_number}/comments',
            headers=headers,
            json=comment_data
        )
        
        if response.status_code == 201:
            comment_url = response.json()['html_url']
            print(f'Comment added successfully to Issue #{issue_number}')
            print(f'Comment URL: {comment_url}')
            return True
        else:
            print(f'Failed to add comment: {response.status_code}')
            print(response.text)
            return False
            
    except Exception as e:
        print(f'Error: {e}')
        return False

if __name__ == "__main__":
    comment_body = """## 技术批评：诗词模块整合的实施问题

作为批评者分析，Issue #1155的实施存在以下关键问题：

### 1. 缺乏明确的可交付成果
- 标题说"整合优化"但没有具体的成功标准
- 4个commit都声称"Fix #1155"但实际只是添加文档
- 没有实际的代码重构或模块合并

### 2. 分支管理混乱
- 在feature分支`fix/poetry-module-consolidation-1155`上工作
- 但该分支只包含文档变更，没有实际的模块整合
- 违反了CLAUDE.md中"实际代码改进"的原则

### 3. 技术债务加剧
- 生成了多个重复的分析报告
- 根目录下47个bisect覆盖率文件未清理
- 实际的诗词模块代码质量问题未得到解决

### 建议的纠正措施
1. **明确范围**: 定义具体的模块整合目标(如合并重复文件、统一API)
2. **实际行动**: 进行代码级别的重构而非文档生成
3. **清理环境**: 先清理技术债务再进行新的开发

### 当前状态评估
该issue应该被暂停，直到明确了具体的技术实施计划和成功标准。

---
*批评者分析基于代码质量和项目管理最佳实践*"""

    comment_on_issue(1155, comment_body)