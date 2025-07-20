#!/usr/bin/env python3
"""
创建新的GitHub issue来描述技术债务改进机会
"""

import requests
from github_auth import get_installation_token

def create_issue(title, body, labels=None):
    """创建新的GitHub issue"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    issue_data = {
        'title': title,
        'body': body
    }
    
    if labels:
        issue_data['labels'] = labels
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    response = requests.post(url, headers=headers, json=issue_data)
    response.raise_for_status()
    
    issue = response.json()
    print(f"✅ 创建issue成功!")
    print(f"Issue #{issue['number']}: {issue['title']}")
    print(f"URL: {issue['html_url']}")
    
    return issue['number']

if __name__ == '__main__':
    title = "技术债务改进：补全剩余缺失的.mli接口文件（第二阶段）"
    
    body = """## 问题描述

在完成string_processing目录的.mli文件添加后，代码库分析发现仍有19个.ml文件缺少对应的.mli接口文件。

## 详细分析

### 缺失.mli文件的模块列表：

1. `src/chinese_best_practices_backup.ml` 
2. `src/error_messages_analysis.ml`
3. `src/error_messages_generation.ml`
4. `src/error_messages_reporting.ml`
5. `src/error_messages_translation.ml`
6. `src/keyword_converter_basic.ml`
7. `src/keyword_converter_chinese.ml`
8. `src/keyword_converter_main.ml`
9. `src/keyword_converter_special.ml`
10. `src/lexer_utils_modular.ml`
11. `src/poetry/data/externalized_data_loader.ml`
12. `src/poetry/data/externalized_data_loader_refactored.ml`
13. `src/token_compatibility_core.ml`
14. `src/token_compatibility_delimiters.ml`
15. `src/token_compatibility_keywords.ml`
16. `src/token_compatibility_literals.ml`
17. `src/token_compatibility_operators.ml`
18. `src/token_compatibility_reports.ml`
19. `src/unicode_constants_new.ml`

## 改进目标

1. **模块封装性提升**：为所有模块提供清晰的公共接口
2. **编译优化**：支持增量编译和更好的模块边界控制
3. **API文档化**：通过接口文件明确模块的公共API
4. **代码质量**：提高模块间的解耦度

## 实施计划

### 第一优先级
- 为核心功能模块创建.mli文件（error_messages_*, token_compatibility_*）
- 清理和评估备份文件的必要性

### 第二优先级  
- 为转换器模块创建接口文件（keyword_converter_*）
- 完善poetry/data子模块的接口定义

### 第三优先级
- 处理工具类模块的接口文件
- 统一模块命名和组织结构

## 验收标准

- [ ] 所有列出的.ml文件都有对应的.mli文件
- [ ] 所有新增接口文件都通过编译检查
- [ ] 现有功能不受影响
- [ ] 代码风格与项目标准一致
- [ ] CI构建全部通过

## 相关信息

- 前置工作：已在 #710 中完成string_processing目录的接口文件添加
- 这是技术债务改进的第二阶段工作
- 重点关注代码结构优化而非功能增强

---

这个issue将通过PR的方式分阶段解决，确保每个阶段都能保持代码库的稳定性。"""

    labels = ['technical-debt', 'code-quality', 'mli-files']
    
    issue_number = create_issue(title, body, labels)
    print(f"Issue #{issue_number} 创建完成")