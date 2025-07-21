#!/usr/bin/env python3
"""
创建第三阶段failwith迁移PR
"""

import requests
import json
from github_auth import get_installation_token

def create_pull_request():
    """创建PR"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    title = "技术债务改进：第三阶段 failwith 错误处理统一化迁移 - 完成剩余模块 Fix #742"
    
    body = """## 概述

完成第三阶段 failwith 错误处理统一化迁移，将项目中剩余的 failwith 调用替换为统一的错误处理系统。

## 修复详情

### 🔧 修复的文件和问题

#### 1. `src/parser_ancient.ml` (行132)
**问题**: 使用原始 failwith 进行内部错误处理
```ocaml
| _ -> failwith "编译器错误：内部错误：序数模运算结果超出范围"
```

**修复**: 使用统一错误处理系统
```ocaml
| _ -> (
    (* 这种情况不应该发生，因为 n mod 3 只能是 0, 1, 2 *)
    let error = SystemError2 (InternalError "序数模运算结果超出范围", None) in
    let error_msg = unified_error_to_string error in
    Printf.eprintf "警告：%s\\n" error_msg;
    AncientItsFirstKeyword (* 使用默认值 *)
  )
```

#### 2. `src/types_errors.ml` (行106)
**问题**: `handle_error_map` 函数中使用 failwith
```ocaml
| Error msg -> failwith msg
```

**修复**: 使用本地定义的异常类型
```ocaml
| Error msg -> 
    (* 记录错误并抛出本地异常 *)
    raise (TypeError msg)
```

## 🎯 改进效果

1. **统一错误处理**: 所有错误处理现在使用项目的统一错误系统
2. **更好的错误恢复**: 提供默认值避免程序崩溃
3. **改进的错误记录**: 使用标准化的错误消息格式
4. **保持一致性**: 与项目现有的错误处理模式保持一致

## ✅ 测试验证

- [x] 所有单元测试通过
- [x] 集成测试通过
- [x] 构建成功无警告
- [x] 错误处理功能正常
- [x] 诗词编程功能不受影响

## 📊 技术债务改进

根据2025年7月21日的技术债务分析报告，此修复解决了：
- **剩余 failwith 问题**: 完成最后的 failwith 迁移
- **错误处理一致性**: 统一项目错误处理策略
- **代码质量提升**: 提高错误恢复能力

## 🔍 代码审查重点

1. **错误处理逻辑**: 确认新的错误处理保持原有语义
2. **默认值策略**: 在 parser_ancient.ml 中使用默认值的合理性
3. **异常类型**: types_errors.ml 中异常类型的正确性

## 📝 后续计划

此PR完成后，项目将彻底消除 failwith 调用，为后续的自举编译器开发奠定更坚实的基础。

---

Fix #742

🤖 Generated with [Claude Code](https://claude.ai/code)"""

    pr_data = {
        'title': title,
        'body': body,
        'head': 'feature/failwith-migration-phase3-final',
        'base': 'main'
    }
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/pulls'
    response = requests.post(url, headers=headers, json=pr_data)
    
    if response.status_code == 201:
        pr = response.json()
        print(f"✅ Pull Request #{pr['number']} 创建成功!")
        print(f"标题: {pr['title']}")
        print(f"URL: {pr['html_url']}")
        return pr['number']
    else:
        print(f"❌ 创建PR失败:")
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return None

if __name__ == '__main__':
    pr_number = create_pull_request()
    if pr_number:
        print(f"\n📋 PR #{pr_number} 已创建，等待审查")