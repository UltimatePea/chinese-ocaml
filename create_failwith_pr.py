#!/usr/bin/env python3
"""
创建 failwith 统一错误处理迁移 PR
"""

import requests
from github_auth import get_installation_token

def create_pr():
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    # PR 标题和内容
    title = "技术债务改进：优化 failwith 错误消息格式统一性 Fix #736"
    
    body = """## 概述

本 PR 实施了 Issue #736 中提议的 failwith 错误消息统一化改进，提升了错误处理的一致性和用户友好性。

## 修改内容

### 🎯 主要改进
- **统一错误消息格式**: 为所有 failwith 调用添加了明确的错误类型前缀
- **中文错误消息**: 将英文错误消息替换为中文，符合骆言语言的设计理念
- **错误分类**: 按错误性质分类，便于用户理解和调试

### 📋 错误类型分类
- **类型错误**: 类型系统相关错误
- **词法错误**: 词法分析阶段错误
- **解析错误**: 数据解析相关错误
- **运行时错误**: 程序运行时验证错误
- **系统错误**: 系统级操作错误
- **编译器错误**: 编译器内部错误

### 📁 修改文件列表
- `src/poetry/parallelism_analysis.ml` - 律诗格式验证
- `src/poetry/rhyme_json_data_loader.ml` - JSON韵律数据加载
- `src/parser_expressions_utils.ml` - 表达式解析工具
- `src/lexer_parsers.ml` - 词法分析器解析器
- `src/parser_expressions_type_keywords.ml` - 类型关键字解析
- `src/parser_ancient.ml` - 古雅体语法解析

## 示例对比

### 改进前 ❌
```ocaml
failwith "Invalid rhyme category"
failwith "律诗必须是八句"
failwith "不是类型关键字"
failwith "未闭合的引用标识符"
```

### 改进后 ✅
```ocaml
failwith "解析错误：无效的韵律类别: ..."
failwith "运行时错误：律诗必须是八句"
failwith "类型错误：不是类型关键字"
failwith "词法错误：未闭合的引用标识符"
```

## 验证结果

- ✅ **构建测试**: `dune build` 通过
- ✅ **单元测试**: `dune runtest` 正常运行
- ✅ **错误格式**: 消息格式保持一致
- ✅ **向后兼容**: 不影响现有功能
- ✅ **错误数量**: 从原来的简单 failwith 优化为 6 个格式化的错误调用

## 技术债务影响

### 直接效益
- 🎯 **提升用户体验**: 错误消息更加清晰和友好
- 🔧 **便于调试**: 错误类型分类明确，便于快速定位问题
- 📖 **中文化支持**: 符合骆言语言的中文编程理念
- 🏗️ **代码质量**: 错误处理更加规范和一致

### 后续改进
这次改进为后续完整迁移到统一错误处理系统 (`unified_errors.ml`) 奠定了基础：
- 错误消息已标准化
- 错误分类已确立
- 可逐步替换为 Result 类型

## 风险评估

**🟢 低风险改进**
- 只修改了错误消息文本，未改变程序逻辑
- 保持了原有的异常处理机制
- 所有测试正常通过

## 相关 Issue

Fix #736 - 技术债务改进：继续推进 failwith 到统一错误处理系统的迁移

---

**类型**: 🔧 技术债务修复  
**优先级**: 中等  
**影响范围**: 错误处理和用户体验  
**向后兼容**: ✅ 完全兼容

🤖 Generated with [Claude Code](https://claude.ai/code)"""
    
    # 创建 PR
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls'
    
    pr_data = {
        'title': title,
        'body': body,
        'head': 'fix-736-failwith-migration',
        'base': 'main',
        'draft': False
    }
    
    response = requests.post(url, headers=headers, json=pr_data)
    
    if response.status_code == 201:
        pr = response.json()
        print(f"✅ PR 创建成功!")
        print(f"PR #{pr['number']}: {pr['title']}")
        print(f"URL: {pr['html_url']}")
        return pr['number']
    else:
        print(f"❌ PR 创建失败:")
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return None

if __name__ == '__main__':
    pr_number = create_pr()
    if pr_number:
        print(f"\n✨ PR #{pr_number} 已创建，解决了 Issue #736!")
        print("等待项目维护者审查和合并。")