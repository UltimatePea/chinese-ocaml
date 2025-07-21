#!/usr/bin/env python3
"""
创建韵律数据外化技术债务改进Issue
"""

import sys
sys.path.append('.')
from github_auth import get_installation_token
import requests
import json

def create_rhyme_data_issue():
    """创建韵律数据外化改进Issue"""
    
    title = "技术债务改进：韵律数据外化重构 - unified_rhyme_data.ml (374行)"
    
    body = """## 问题描述

根据技术债务分析，`src/poetry/unified_rhyme_data.ml` 文件包含374行代码，其中大量为硬编码的韵律数据，违反了数据与逻辑分离的原则。

## 当前状况

- **文件大小**: 374行代码
- **主要问题**: 包含11个硬编码的字符集数据（韵律数据）
- **数据类型**: 包含9个韵律字符集 + 2个其他字符集
- **维护难度**: 韵律数据更新需要修改源代码并重新编译

## 建议的重构方案

### 1. 数据外化
- 将硬编码的韵律数据迁移到 `data/poetry/` 目录下的JSON文件
- 创建以下JSON文件：
  - `rhyme_groups.json` - 主要韵律组数据
  - `character_sets.json` - 字符集数据

### 2. 模块重构
- 保留 `unified_rhyme_data.ml` 作为数据加载接口
- 创建数据加载逻辑，支持容错机制
- 参考 `expanded_data_loader.ml` 的成功重构模式

### 3. 预期效果
- **代码行数减少**: 预计减少200-250行
- **维护性提升**: 韵律数据可独立维护，无需重新编译
- **扩展性增强**: 新韵律组可通过JSON配置轻松添加

## 技术实施计划

### 阶段1：数据提取
1. 分析现有的11个字符集数据
2. 设计JSON数据结构
3. 创建对应的JSON文件

### 阶段2：模块重构
1. 重构 `unified_rhyme_data.ml` 为数据加载器
2. 实现JSON数据读取和解析
3. 添加容错机制和降级策略

### 阶段3：测试验证
1. 确保所有现有功能正常工作
2. 验证数据加载的正确性
3. 测试容错机制

## 成功案例参考

本项目最近成功完成了类似的重构：
- **Issue #639**: `expanded_data_loader.ml` 数据外化重构
- **模式**: 硬编码数据 → JSON文件 + 数据加载器
- **结果**: 代码更清晰，数据更易维护

## 优先级说明

- **级别**: 中等优先级技术债务
- **影响**: 改善代码可维护性和数据管理
- **风险**: 低（已有成功重构案例）

## 实施时间估算

- **总工时**: 1-2个工作日
- **风险评估**: 低风险（成熟的重构模式）
"""

    try:
        token = get_installation_token()
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json'
        }
        
        data = {
            'title': title,
            'body': body,
            'labels': ['技术债务', '重构', '数据外化', '诗词模块']
        }
        
        url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 201:
            issue_data = response.json()
            print(f"✅ Issue创建成功！")
            print(f"Issue编号: #{issue_data['number']}")
            print(f"标题: {issue_data['title']}")
            print(f"URL: {issue_data['html_url']}")
            return issue_data['number']
        else:
            print(f"❌ Issue创建失败:")
            print(f"状态码: {response.status_code}")
            print(f"响应: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ 创建Issue时发生错误: {e}")
        return None

if __name__ == '__main__':
    issue_number = create_rhyme_data_issue()
    if issue_number:
        print(f"\n🎯 下一步：创建对应的Pull Request来解决Issue #{issue_number}")