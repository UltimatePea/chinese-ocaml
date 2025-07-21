#!/usr/bin/env python3
"""
创建 failwith 统一错误处理迁移 issue
"""

import requests
import json
from github_auth import get_installation_token

def create_issue():
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # Issue 标题和内容
    title = "技术债务改进：继续推进 failwith 到统一错误处理系统的迁移"
    
    body = """## 问题描述

根据最新的技术债务分析，项目中仍存在一些 `failwith` 调用尚未迁移到统一错误处理系统。为了保持错误处理的一致性和可维护性，需要继续推进这一迁移工作。

## 当前状况

通过代码扫描发现以下文件中仍有 `failwith` 使用：

1. `src/poetry/parallelism_analysis.ml` - 律诗句数验证错误
2. `src/poetry/rhyme_json_data_loader.ml` - 无效韵律类别错误  
3. `src/parser_expressions_utils.ml` - 类型关键字验证错误
4. `src/lexer_parsers.ml` - 词法分析器字符处理错误

## 目标

将上述 `failwith` 调用迁移到项目的统一错误处理系统 (`unified_errors.ml`)，以提升：
- 错误处理的一致性
- 错误信息的标准化
- 代码的可维护性

## 实施计划

1. **分析现有 failwith 使用模式**
2. **为每种错误类型定义对应的统一错误类型**
3. **逐个文件进行迁移和测试**
4. **确保错误处理行为保持一致**

## 验收标准

- [ ] 项目中不再有 `failwith "..."` 调用
- [ ] 所有错误通过统一错误处理系统处理
- [ ] 现有测试仍然通过
- [ ] 错误信息保持用户友好

## 技术债务影响

这是一个**纯技术债务修复**，不涉及新功能，修复后可以提升代码质量和错误处理的一致性。

## 优先级

中等优先级 - 可以改善代码质量，但不影响核心功能。

---

*此 issue 基于项目技术债务分析报告创建，旨在持续改进代码质量。*
"""
    
    # 创建 issue
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    issue_data = {
        'title': title,
        'body': body,
        'labels': ['tech-debt', 'error-handling', 'refactoring']
    }
    
    response = requests.post(url, headers=headers, json=issue_data)
    
    if response.status_code == 201:
        issue = response.json()
        print(f"✅ Issue 创建成功!")
        print(f"Issue #{issue['number']}: {issue['title']}")
        print(f"URL: {issue['html_url']}")
        return issue['number']
    else:
        print(f"❌ Issue 创建失败:")
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return None

if __name__ == '__main__':
    issue_number = create_issue()
    if issue_number:
        print(f"\n接下来可以创建 PR 来解决 Issue #{issue_number}")