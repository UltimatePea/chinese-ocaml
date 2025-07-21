#!/usr/bin/env python3
"""
创建环境优化和开发工具改进issue
"""

import json
import requests
from github_auth import get_installation_token

def create_issue():
    """创建GitHub issue"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    title = "技术债务改进：环境优化和开发工具增强 Fix #730"
    
    body = """## 📋 问题描述

根据最新的技术债务分析报告（2025-07-20），骆言项目整体代码质量优秀，但存在一些环境配置和开发工具优化机会。本issue旨在处理最高优先级的技术债务，提升开发体验和项目维护效率。

## 🎯 优化目标

### 优先级1：立即执行（今日内）

#### 1. 环境清理和优化
- **构建产物清理**：当前`_build/`目录占用440MB空间
- **临时文件管理**：规范化日志文件和调试输出
- **Git忽略规则**：完善`.gitignore`文件

#### 2. 开发工具增强
- **质量检查脚本**：创建一键代码质量检查工具
- **快速测试命令**：建立高效的测试运行机制
- **构建优化**：改进编译时间和输出管理

### 优先级2：短期改进（1-2周）

#### 3. 测试覆盖率提升
- **当前状态**：30.3%覆盖率
- **目标状态**：50%+覆盖率
- **重点模块**：core_types.ml, lexer_utils.ml, parser_utils.ml

#### 4. 性能监控基础
- **诗词处理性能基准**
- **词法分析性能监控**
- **关键路径时间测量**

## 🛠️ 技术实施方案

### 环境清理
```bash
# 构建产物清理
dune clean
rm -rf _build/

# 临时文件清理
rm -f claude.log build_output.log ascii_check_results.txt
find . -name "*.tmp" -delete
find . -name "*~" -delete
```

### 开发工具脚本
```bash
# scripts/quality_check.sh
#!/bin/bash
dune build
dune test
dune exec -- luoyan --version
echo "✅ 质量检查完成"

# scripts/quick_test.sh
#!/bin/bash
dune exec test/test_minimal.exe
dune exec test/test_simple_token_mapper.exe
echo "✅ 核心测试通过"
```

### .gitignore增强
```
# 构建产物
_build/
*.install

# 临时文件
*.log
*.tmp
*~
.DS_Store

# IDE文件
.vscode/
*.swp
*.swo

# 调试输出
ascii_check_results.txt
build_output.log
```

## 📊 质量指标

### 当前状态
- 源文件：290个 (.ml)
- 接口文件：274个 (.mli)
- 测试覆盖率：30.3%
- 构建产物：440MB
- 构建状态：✅ 零警告零错误

### 目标状态
- 测试覆盖率：50%+
- 构建产物：<50MB
- 开发工具：完整的质量检查套件
- 性能监控：建立基准测试

## 🎨 艺术性考虑

遵循骆言项目的核心价值观：

1. **保持诗词编程特色**：所有改进不影响项目的中文编程美学
2. **自举编译器优先**：重点关注自举编译器的开发体验
3. **中文思维导向**：开发工具的输出和文档保持中文风格

## ✅ 验收标准

### 基础环境优化
- [ ] `_build/`目录清理完成，释放440MB空间
- [ ] 临时文件清理规则建立
- [ ] `.gitignore`规则完善

### 开发工具增强
- [ ] `scripts/quality_check.sh`脚本创建并测试
- [ ] `scripts/quick_test.sh`快速测试工具
- [ ] 构建时间优化，提升开发效率

### 测试基础建立
- [ ] 核心模块测试用例增加
- [ ] 测试覆盖率监控机制
- [ ] 性能基准测试框架

## 📈 预期收益

1. **开发效率提升**：40%的构建和测试时间优化
2. **代码质量保障**：自动化质量检查覆盖
3. **维护成本降低**：规范化的环境管理
4. **测试信心增强**：更高的代码覆盖率

## 🚀 实施时间线

- **第1天**：环境清理和基础工具脚本
- **第2-3天**：测试覆盖率基础建立
- **第1周**：性能监控框架搭建
- **第2周**：质量检查自动化完善

---

**标签**: 技术债务, 开发工具, 测试优化, 性能监控, 环境配置

此issue专注于高优先级技术债务，通过环境优化和开发工具增强，为骆言项目的持续发展奠定更加坚实的技术基础。
"""
    
    data = {
        'title': title,
        'body': body,
        'labels': ['技术债务', '开发工具', '测试优化', '性能监控']
    }
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    
    issue_data = response.json()
    print(f"✅ Issue #{issue_data['number']} 创建成功!")
    print(f"标题: {issue_data['title']}")
    print(f"URL: {issue_data['html_url']}")
    
    return issue_data['number']

def main():
    try:
        issue_number = create_issue()
        print(f"\n🎯 下一步：创建PR来解决Issue #{issue_number}")
        return 0
    except Exception as e:
        print(f"❌ 创建issue失败: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    exit(main())