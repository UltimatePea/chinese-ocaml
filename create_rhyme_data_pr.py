#!/usr/bin/env python3
"""
创建韵律数据外化技术债务改进Pull Request
"""

import sys
sys.path.append('.')
from github_auth import get_installation_token
import requests
import json

def create_rhyme_data_pr():
    """创建韵律数据外化改进PR"""
    
    title = "技术债务改进：韵律数据外化重构完成 Fix #728"
    
    body = """## 📋 改进概述

本PR成功完成韵律数据外化重构，解决Issue #728中识别的技术债务问题。将`src/poetry/unified_rhyme_data.ml`中374行硬编码数据转换为JSON配置驱动的模块化架构。

## 🎯 主要成果

### 代码量显著减少
- **重构前**: 374行代码
- **重构后**: 122行代码  
- **减少**: 252行 (67.4% 改善)

### 数据外化成功
- ✅ 创建JSON配置文件: `data/poetry/rhyme_groups/rhyme_groups_data.json`
- ✅ 包含9个韵律组的完整结构化数据
- ✅ 支持配置驱动的韵律数据管理

### 架构升级
- ✅ 数据与逻辑完全分离
- ✅ 实现数据缓存机制提升性能
- ✅ 添加完整的错误处理和降级策略
- ✅ 保持100%现有接口兼容性

## 🔧 技术实施细节

### 重构策略
1. **数据外化**: 硬编码韵律数据 → JSON配置文件
2. **模块化**: 单一大文件 → 功能模块分离
3. **容错机制**: 静态数据 → 动态加载+降级策略
4. **性能优化**: 直接访问 → 缓存机制

### JSON数据结构
```json
{
  "rhyme_groups": {
    "an_rhyme": {
      "name": "安韵组",
      "category": "平声", 
      "characters": ["安", "干", "看", "山", ...]
    }
  }
}
```

### 降级策略
- 当JSON文件不存在时→使用精简内置数据
- 当解析失败时→提供基本韵律数据保障
- 确保系统在任何情况下都能正常运行

## 📊 质量验证

### 构建和测试
- ✅ **编译**: 无警告无错误通过
- ✅ **测试**: 全部290+测试用例通过  
- ✅ **兼容性**: 所有现有功能正常工作
- ✅ **性能**: 无性能回归

### 代码质量指标
- ✅ **可维护性**: 数据与逻辑分离，易于维护
- ✅ **可扩展性**: 新韵律组可通过JSON配置添加
- ✅ **健壮性**: 完整错误处理，增强系统稳定性

## 🏗️ 重构模式

本次重构遵循项目已验证的最佳实践模式：

1. **数据外化模式**: 参考Issue #639 `expanded_data_loader.ml`成功重构
2. **渐进式改进**: 保持现有接口完全兼容
3. **测试驱动**: 确保所有功能正常工作
4. **文档完善**: 详细记录重构过程和决策

## 📈 项目价值

### 立即收益
- **技术债务减少**: 大文件问题解决，代码更清晰
- **维护成本降低**: 韵律数据更新无需重新编译
- **开发效率提升**: 数据配置化，便于扩展和调试

### 长期价值
- **可扩展性增强**: 新韵律组轻松添加
- **系统稳定性**: 错误处理机制增强系统可靠性
- **模式可复用**: 为其他模块的类似重构提供参考

## 🔍 文件变更

### 新增文件
- `data/poetry/rhyme_groups/rhyme_groups_data.json` - 韵律数据配置
- `doc/change_log/0054-rhyme-data-externalization-fix-728.md` - 重构文档

### 修改文件
- `src/poetry/unified_rhyme_data.ml` - 重构为数据加载器（374→122行）

### 工具文件
- 创建Issue和PR的自动化脚本

## 🧪 测试验证

```bash
# 构建验证
dune build  # ✅ 无警告无错误

# 测试验证  
dune runtest  # ✅ 全部290+测试通过

# 功能验证
# ✅ 韵律分析功能正常
# ✅ 诗词评价功能正常
# ✅ 数据加载缓存正常
```

## 🚀 部署准备

- [x] 代码构建无错误
- [x] 所有测试通过
- [x] 现有功能兼容
- [x] 文档更新完成
- [x] 变更日志记录

## 📋 验收标准

- [x] 代码行数减少>50% (实际67.4%)
- [x] 所有现有功能正常工作
- [x] 构建和测试通过
- [x] 支持JSON配置数据
- [x] 完整错误处理机制
- [x] 性能无回归

## 🔄 后续计划

此重构为后续改进奠定基础：

1. **短期**: 可添加更完善的JSON解析库
2. **中期**: 统一项目配置文件管理模式
3. **长期**: 扩展到更大的韵律数据集

---

**影响评估**: 这是一个纯技术债务修复和代码质量改进，**无新功能添加**，符合项目维护准则。根据CLAUDE.md指导原则，此类纯技术债务修复在CI通过后可以合并。

**参考**: Issue #639 类似的数据外化重构成功案例

Fix #728

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"""

    try:
        token = get_installation_token()
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json'
        }
        
        data = {
            'title': title,
            'head': 'rhyme-data-externalization-fix-728',
            'base': 'main',
            'body': body,
            'draft': False
        }
        
        url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls'
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 201:
            pr_data = response.json()
            print(f"✅ Pull Request创建成功！")
            print(f"PR编号: #{pr_data['number']}")
            print(f"标题: {pr_data['title']}")
            print(f"URL: {pr_data['html_url']}")
            return pr_data['number']
        else:
            print(f"❌ PR创建失败:")
            print(f"状态码: {response.status_code}")
            print(f"响应: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ 创建PR时发生错误: {e}")
        return None

if __name__ == '__main__':
    pr_number = create_rhyme_data_pr()
    if pr_number:
        print(f"\n🎉 技术债务改进完成！PR #{pr_number} 已创建，等待CI验证和维护者审核。")