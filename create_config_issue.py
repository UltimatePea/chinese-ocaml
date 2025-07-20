#!/usr/bin/env python3
"""
创建配置模块重构issue
"""

import json
import time
import jwt
import requests
from pathlib import Path

# GitHub App 配置
APP_ID = "1595512"
INSTALLATION_ID = "75590650"
PRIVATE_KEY_PATH = "../claudeai-v1.pem"

def generate_jwt():
    """生成JWT token"""
    private_key_path = Path(__file__).parent / PRIVATE_KEY_PATH
    
    with open(private_key_path, 'r') as f:
        private_key = f.read()
    
    now = int(time.time())
    payload = {
        'iat': now,
        'exp': now + 600,  # 10分钟有效期
        'iss': APP_ID
    }
    
    return jwt.encode(payload, private_key, algorithm='RS256')

def get_installation_token():
    """获取installation token"""
    jwt_token = generate_jwt()
    
    headers = {
        'Authorization': f'Bearer {jwt_token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/app/installations/{INSTALLATION_ID}/access_tokens'
    
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    
    return response.json()['token']

def create_issue(title, body):
    """创建issue"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    data = {
        'title': title,
        'body': body,
        'labels': ['technical-debt', 'refactoring']
    }
    
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    
    return response.json()

def main():
    """主函数"""
    try:
        title = "技术债务改进：重构config.ml中的超长环境变量映射配置"
        
        body = """## 问题描述

经过代码质量分析，发现配置模块存在严重的技术债务问题：

### 🚨 主要问题

1. **超长代码结构**: `config.ml`和`config/unified_config.ml`中的`env_var_mappings`定义长达74行
2. **代码重复**: 相同的环境变量映射定义在多个文件中重复出现
3. **维护困难**: 添加新的环境变量配置需要修改多个地方
4. **可读性差**: 超长的映射列表影响代码可读性

### 📍 具体位置

- `src/config.ml`: 第55-128行
- `src/config/unified_config.ml`: 第55-128行

### 🎯 重构目标

将超长的环境变量映射配置重构为：

1. **模块化设计**: 创建专门的环境变量配置模块
2. **结构化定义**: 使用更清晰的数据结构定义配置映射
3. **消除重复**: 统一配置定义，避免代码冗余
4. **提高可维护性**: 简化新配置项的添加流程

### 💡 重构方案

#### 1. 创建新模块 `src/config/env_var_config.ml`
```ocaml
(** 环境变量配置定义模块 *)

type env_var_handler = string -> unit

type env_var_config = {
  name : string;
  handler : env_var_handler;
  description : string;
}

(** 配置项定义 *)
val config_definitions : env_var_config list

(** 批量处理环境变量 *)
val process_all_env_vars : unit -> unit
```

#### 2. 重构现有文件
- 简化 `config.ml` 中的 `env_var_mappings` 为模块调用
- 消除 `unified_config.ml` 中的重复定义
- 统一配置处理逻辑

### 🔄 实施步骤

1. ✅ **分析现状**: 识别重复代码和问题模式
2. 🔲 **创建新模块**: 实现 `env_var_config.ml`
3. 🔲 **重构主文件**: 简化 `config.ml` 的映射定义
4. 🔲 **消除重复**: 清理 `unified_config.ml` 中的冗余代码
5. 🔲 **测试验证**: 确保重构后功能完全一致
6. 🔲 **文档更新**: 更新相关配置文档

### 📊 预期收益

- **代码长度**: 从74行减少到~10行调用
- **维护性**: 新增配置项只需修改一个地方
- **可读性**: 清晰的模块结构和配置定义
- **重复消除**: 完全消除跨文件的代码重复

### ⚠️ 风险评估

**低风险重构**: 
- 纯代码组织优化，不改变功能逻辑
- 保持向后兼容性
- 通过测试验证确保正确性

### 🎯 成功标准

- [ ] 所有环境变量配置功能保持不变
- [ ] 代码重复完全消除
- [ ] 新配置项添加流程简化
- [ ] 所有现有测试通过
- [ ] 构建无警告无错误

---

**优先级**: 🔥 高 - 这是一个影响代码质量和维护性的重要技术债务

**类型**: 🔧 纯技术债务修复，无新功能添加"""
        
        print(f"正在创建issue...")
        result = create_issue(title, body)
        print(f"✅ Issue创建成功:")
        print(f"   🔗 URL: {result['html_url']}")
        print(f"   🏷️  编号: #{result['number']}")
        print(f"   📝 标题: {result['title']}")
        
        return result['number']
        
    except Exception as e:
        print(f"❌ 错误: {e}")
        return None

if __name__ == '__main__':
    issue_number = main()
    if issue_number:
        print(f"\n🎯 下一步: 为Issue #{issue_number}创建PR")
    else:
        exit(1)