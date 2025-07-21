#!/usr/bin/env python3

import github_auth
import requests

def create_issue():
    try:
        # 获取installation token
        token = github_auth.get_installation_token()
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json'
        }
        
        # 创建issue
        issue_data = {
            'title': '技术债务改进：第三阶段 failwith 错误处理统一化迁移 - 最终完善',
            'body': '''## 概述

基于最新的技术债务分析报告，推进 failwith 错误处理到统一错误处理系统的最终迁移阶段。这是继第一阶段（Issue #736）和第二阶段（Issue #738）之后的第三阶段改进，旨在完成整个错误处理系统的统一化。

## 背景

前两阶段已成功完成：
- **第一阶段**：核心模块错误消息格式统一化
- **第二阶段**：词法解析和诗词分析模块迁移

最新技术债务分析发现：
- 仍有 **25处 failwith 调用** 分布在 **13个文件** 中
- 主要集中在诗词处理和表达式解析模块
- 需要完成最终的错误处理统一化

## 第三阶段迁移范围

### 重点文件（基于分析报告）：

1. **诗词模块**：
   - `poetry/rhyme_json_data_loader.ml` - 韵律数据加载错误
   - `poetry/parallelism_analysis.ml` - 对偶分析错误
   - `poetry/poetry_classifier.ml` - 诗词分类错误

2. **解析器模块**：
   - `parser_expressions_utils.ml` - 表达式解析工具错误
   - `parser_types.ml` - 类型解析错误

3. **其他核心模块**：
   - 数据处理和文件操作相关错误
   - 编译器内部状态错误

### 技术目标

1. **错误类型扩展**：
   - 扩展 `unified_errors.ml` 支持诗词分析特定错误
   - 新增韵律数据、对偶分析、诗词分类错误子类型
   - 完善表达式解析错误处理

2. **迁移策略**：
   - 保持向后兼容性
   - 中文化错误消息
   - 避免模块循环依赖
   - 渐进式迁移，确保构建稳定

3. **质量保证**：
   - 每个迁移步骤独立验证
   - 完整的构建测试
   - 错误消息格式一致性检查

## 预期收益

- **代码质量**：消除所有 failwith 调用，实现100%统一错误处理
- **可维护性**：错误处理逻辑集中化，便于维护和调试
- **用户体验**：统一的中文错误消息格式
- **技术债务**：完成错误处理系统现代化改造

## 实施计划

1. **准备阶段**：扩展 `unified_errors.ml` 错误类型系统
2. **迁移阶段**：逐文件迁移剩余 failwith 调用
3. **验证阶段**：全面构建和错误处理测试
4. **完善阶段**：文档更新和最终优化

## 成功标准

- ✅ 代码库中无剩余 failwith 调用
- ✅ 所有错误消息使用统一格式
- ✅ 构建系统通过所有检查
- ✅ 错误处理文档完整更新

---

**类型**: 技术债务改进  
**优先级**: 高  
**影响范围**: 诗词分析和解析器模块  
**前置依赖**: Issue #738 (已完成)

**分配给**: @claudeai-v1[bot]

🤖 基于技术债务深度分析报告创建''',
            'assignees': ['claudeai-v1[bot]'],
            'labels': ['technical-debt', 'error-handling', 'phase-3']
        }
        
        url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
        response = requests.post(url, headers=headers, json=issue_data)
        
        if response.status_code == 201:
            issue_info = response.json()
            print(f'✅ Issue #{issue_info["number"]} 创建成功!')
            print(f'Issue URL: {issue_info["html_url"]}')
            return issue_info["number"]
        else:
            print(f'❌ Issue 创建失败:')
            print(f'状态码: {response.status_code}')
            print(f'响应: {response.text}')
            return None
            
    except Exception as e:
        print(f'错误: {e}')
        return None

if __name__ == '__main__':
    issue_number = create_issue()
    if issue_number:
        print(f'\n下一步：创建PR来解决 Issue #{issue_number}')