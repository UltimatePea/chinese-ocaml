#!/usr/bin/env python3
"""
创建技术债务改进issue - 基于长函数分析报告
"""

import json
import sys
from github_auth import get_installation_token
import requests

def create_tech_debt_issue():
    """创建技术债务改进的issue"""
    
    issue_title = "技术债务改进：长函数重构和数据外化优化"
    
    issue_body = """## 问题描述

基于最新的长函数分析报告，骆言项目整体代码质量良好，但仍有一些改进机会，特别是在函数长度和数据组织方面。

## 分析结果摘要

### ✅ 优秀表现
- **零函数超过150行** - 表明项目函数长度控制优秀
- 整体代码质量良好，符合现代OCaml开发最佳实践

### ⚠️ 需要改进的地方
- **5个函数在100-150行范围** - 需要高优先级重构
- **11个大型数据结构函数** - 需要数据外化考虑

## 具体改进项目

### 第一优先级：数据外化（最高优先级）

#### 🎯 目标函数
1. **`ping_sheng_chars`** (135行) - `src/poetry/data/tone_data/ping_sheng_data.ml`
2. **`shang_sheng_chars`** (101行) - `src/poetry/data/tone_data/shang_sheng_data.ml`
3. **`char_definitions`** (133行) - `src/unicode/unicode_types.ml`

#### 🔧 实施方案
- 将字符列表迁移到 `data/poetry/` 目录下的JSON文件
- 创建统一的数据加载器接口
- 实现缓存机制提高性能
- 保持向后兼容性

### 第二优先级：测试函数分解

#### 🎯 目标函数
- **`test_chinese_best_practices`** (144行) - `src/chinese_best_practices_backup.ml`

#### 🔧 实施方案
- 分解为独立的测试函数
- 每个测试函数专注单一功能
- 改善错误诊断能力

### 第三优先级：JSON解析器优化

#### 🎯 目标函数
- `poetry_data_loader.ml` 中的解析逻辑 (113行)

#### 🔧 实施方案
- 提取JSON解析为独立函数
- 分离错误处理逻辑
- 改善异常处理

## 实施路线图

### 第一阶段：数据外化（1-2周）
1. 分析现有数据结构
2. 设计JSON schema
3. 实现数据迁移工具
4. 创建加载器接口
5. 性能测试验证

### 第二阶段：函数分解（1周）
1. 重构测试函数
2. 分解Unicode定义
3. 优化JSON解析器
4. 代码审查

### 第三阶段：性能优化（1周）
1. 实现缓存机制
2. 算法复杂度优化
3. 内存使用优化
4. 性能基准测试

## 成功指标

### 📊 量化指标
- 函数平均长度减少20%
- 数据加载性能提升15%
- 代码复杂度降低30%
- 测试覆盖率维持95%以上

### 🎯 质量指标
- 代码可读性显著提升
- 模块边界更加清晰
- 错误处理更加规范
- 文档完整性改善

## 风险评估和缓解

### 🔴 高风险项
- **数据外化**: 可能影响现有依赖
  - **缓解**: 保持向后兼容，渐进式迁移
- **大型重构**: 可能引入新bug
  - **缓解**: 充分的测试覆盖，分阶段实施

## 相关文档

- [长函数分析报告](doc/analysis/)
- [技术债务综合评估报告](doc/analysis/骆言项目技术债务综合评估报告_2025-07-20.md)
- [项目结构文档](STRUCTURE.md)

## 标签

- `tech-debt` - 技术债务
- `refactoring` - 重构
- `performance` - 性能优化
- `maintainability` - 可维护性

---

**创建时间**: 2025-07-21  
**优先级**: 中等  
**预估工作量**: 4-5周  
**影响范围**: 数据加载、函数组织、代码可维护性
"""

    try:
        token = get_installation_token()
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json'
        }
        
        url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
        
        issue_data = {
            'title': issue_title,
            'body': issue_body,
            'labels': ['tech-debt', 'refactoring', 'performance', 'maintainability']
        }
        
        response = requests.post(url, headers=headers, json=issue_data)
        response.raise_for_status()
        
        issue = response.json()
        print(f"✅ Issue 创建成功!")
        print(f"Issue 编号: #{issue['number']}")
        print(f"Issue 标题: {issue['title']}")
        print(f"Issue URL: {issue['html_url']}")
        
        return issue['number']
        
    except Exception as e:
        print(f"❌ 创建Issue失败: {e}")
        return None

if __name__ == '__main__':
    issue_number = create_tech_debt_issue()
    if issue_number:
        print(f"\n🎉 技术债务改进Issue #{issue_number} 创建完成！")
    else:
        print("\n💥 Issue创建失败，请检查网络连接和认证配置")
        sys.exit(1)