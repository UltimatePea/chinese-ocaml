#!/usr/bin/env python3
"""
创建诗词数据模块重构技术债务改进issue
"""

import json
import requests
from github_auth import get_installation_token

def create_issue():
    """创建技术债务改进issue"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    issue_title = "技术债务改进：诗词数据模块重构和数据外化 Fix #TechDebt-Poetry-Data"
    
    issue_body = """## 📋 问题描述

通过系统性技术债务分析，发现诗词数据模块存在严重的技术债务问题：

### 🔴 **超长文件问题**
- `hui_rhyme_data.ml` (339行)
- `feng_rhyme_data.ml` (329行)  
- `rhyme_data.ml` (312行)
- `yue_rhyme_data.ml` (230行)
- `yu_rhyme_data.ml` (216行)

### 🔴 **硬编码数据问题**
- 韵律字符数据硬编码在源码中
- 维护困难，数据更新需重新编译
- 可扩展性差，无法动态配置

## 🎯 **改进目标**

### 主要目标
1. **数据外化**：将诗词韵律数据移至JSON配置文件
2. **模块简化**：将超长模块拆分为合理大小
3. **统一接口**：建立统一的数据加载和访问机制
4. **性能优化**：实现高效的数据缓存策略

### 技术规格
- 数据文件迁移到 `data/poetry/` 目录
- 实现统一的JSON数据加载器
- 保持向后兼容的API接口
- 优化内存使用和访问性能

## 🚀 **实施计划**

### 第一阶段：数据外化重构
- [ ] 创建JSON数据文件结构
- [ ] 实现统一数据加载器模块
- [ ] 迁移灰韵组数据（最大文件优先）

### 第二阶段：模块简化
- [ ] 重构数据访问接口
- [ ] 简化各韵组模块代码
- [ ] 实现缓存机制

### 第三阶段：测试和优化
- [ ] 完善单元测试覆盖
- [ ] 性能基准测试
- [ ] 文档更新

## 🏆 **预期收益**

- **可维护性提升**：数据修改无需重新编译
- **扩展性增强**：便于添加新韵组数据
- **性能优化**：减少内存占用和启动时间
- **开发效率**：数据与代码分离，职责清晰

## 📊 **技术债务优先级**

**优先级**：🔴 高优先级  
**影响范围**：诗词编程核心功能  
**实施周期**：1-2周  
**风险评估**：低风险（向后兼容）

---

**问题类型**：技术债务改进  
**模块分类**：诗词数据管理  
**创建时间**：2025-07-20

🤖 此issue由AI技术债务分析系统自动创建
"""
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    data = {
        'title': issue_title,
        'body': issue_body,
        'labels': ['技术债务', '重构', '诗词功能', 'enhancement']
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        issue_data = response.json()
        print(f"✅ Issue创建成功！")
        print(f"Issue编号: #{issue_data['number']}")
        print(f"Issue URL: {issue_data['html_url']}")
        return issue_data['number']
    else:
        print(f"❌ Issue创建失败:")
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return None

if __name__ == '__main__':
    create_issue()