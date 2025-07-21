#!/usr/bin/env python3
"""
创建 failwith 迁移第二阶段的 GitHub Issue
继续推进 failwith 到统一错误处理系统的迁移
"""

import requests
import json
from github_auth import get_installation_token

def create_failwith_migration_issue():
    """创建 failwith 迁移第二阶段的 issue"""
    
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    issue_title = "技术债务改进：继续推进 failwith 到统一错误处理系统的迁移 - 第二阶段"
    
    issue_body = """## 概述

继续推进 failwith 错误处理到统一错误处理系统的迁移，提升系统的稳定性和错误处理的一致性。这是继 Issue #736 和 PR #737 之后的第二阶段改进。

## 背景

第一阶段（#736, #737）已经完成了核心模块中的 failwith 错误消息格式统一化。现在需要继续推进，将更多的 failwith 调用迁移到 `unified_errors.ml` 的统一错误处理系统。

## 需要处理的 failwith 调用

根据最新的代码分析，发现了以下需要改进的 failwith 使用：

### 📋 核心模块中的 failwith（51处）

#### 测试文件中的改进（优先级：中等）
- **test/test_*.ml** - 测试错误处理可以保持现状，但建议标准化错误消息格式

#### 核心功能模块（优先级：高）
1. **词法分析器相关**
   - `src/lexer_*.ml` - 词法错误应使用统一格式
   - `src/unicode/` - Unicode处理错误

2. **解析器相关**  
   - `src/parser_*.ml` - 语法解析错误
   - `src/ast_*.ml` - AST构建错误

3. **代码生成器**
   - `src/codegen_*.ml` - 代码生成错误
   - `src/runtime_*.ml` - 运行时错误

4. **诗词分析模块**
   - `src/poetry/` - 诗词格式验证错误
   - `src/refactoring_analyzer_*.ml` - 重构分析错误

## 改进策略

### 🎯 第二阶段目标
1. **错误分类标准化**: 建立明确的错误类型分类体系
2. **逐步迁移**: 优先处理核心功能模块
3. **向后兼容**: 确保不破坏现有功能
4. **测试覆盖**: 确保错误处理的测试覆盖率

### 📝 具体实施步骤

#### 阶段 2.1：错误分类体系完善
- [ ] 完善 `unified_errors.ml` 的错误类型定义
- [ ] 添加更具体的错误子类型
- [ ] 标准化错误消息格式

#### 阶段 2.2：核心模块迁移
- [ ] **词法分析器模块** (`src/lexer_*.ml`)
  - 迁移字符处理错误
  - 迁移Token解析错误
  - 统一Unicode错误处理
  
- [ ] **解析器模块** (`src/parser_*.ml`)
  - 迁移语法解析错误
  - 迁移表达式解析错误
  - 统一AST构建错误

- [ ] **代码生成模块** (`src/codegen_*.ml`)
  - 迁移类型转换错误
  - 迁移代码生成错误
  - 统一运行时错误

#### 阶段 2.3：专业模块迁移
- [ ] **诗词分析模块** (`src/poetry/`)
  - 迁移格式验证错误  
  - 迁移韵律分析错误
  - 统一艺术性评价错误

- [ ] **重构分析模块** (`src/refactoring_analyzer_*.ml`)
  - 迁移代码分析错误
  - 迁移重构建议错误

### 🔧 技术实施方案

#### 错误类型扩展
```ocaml
(* unified_errors.ml 扩展 *)
type error_category = 
  | LexicalError of lexical_error_type
  | ParseError of parse_error_type  
  | RuntimeError of runtime_error_type
  | PoetryError of poetry_error_type
  | SystemError of system_error_type
  | InternalError of internal_error_type

type lexical_error_type =
  | InvalidCharacter of string
  | UnterminatedString 
  | InvalidNumber of string
  | UnicodeError of string

type parse_error_type =
  | SyntaxError of string
  | UnexpectedToken of string
  | MissingExpression
  | InvalidExpression of string
```

#### 迁移模式
```ocaml
(* 改进前 *)
failwith "Invalid character"

(* 改进后 *)
Error (UnifiedError.create 
  ~category:(LexicalError (InvalidCharacter char))
  ~message:"词法错误：无效字符"
  ~location:pos
  ~suggestion:"请使用支持的中文字符"
)
```

## 验证标准

### ✅ 成功标准
1. **功能完整性**: 所有现有功能正常工作
2. **错误一致性**: 错误消息格式统一且清晰
3. **测试通过**: 所有测试用例通过
4. **性能保持**: 错误处理不影响性能
5. **向后兼容**: 不破坏现有API

### 🧪 测试要求
- [ ] 单元测试覆盖所有新的错误类型
- [ ] 集成测试验证错误传播
- [ ] 性能测试确保无regression
- [ ] 用户体验测试验证错误消息质量

## 风险评估

### 🟡 中等风险因素
- **代码量大**: 涉及多个核心模块
- **测试覆盖**: 需要确保全面的测试覆盖
- **兼容性**: 确保不破坏现有功能

### 🛡️ 风险缓解措施
- **分阶段实施**: 逐模块迁移，降低风险
- **充分测试**: 每个模块迁移后都要充分测试
- **代码审查**: 确保代码质量和一致性
- **回滚计划**: 如有问题可快速回滚

## 预期收益

### 🚀 直接收益
- **统一体验**: 用户获得一致的错误处理体验
- **更好调试**: 开发者更容易定位和修复问题
- **代码质量**: 提升整体代码质量和可维护性
- **系统稳定**: 更健壮的错误处理机制

### 📈 长期价值
- **技术债务**: 显著减少技术债务
- **开发效率**: 提升后续开发和维护效率
- **用户满意**: 提升用户使用体验
- **项目形象**: 展现项目的专业性和完整性

## 实施时间表

### 🗓️ 预计时间线
- **阶段2.1** (错误分类完善): 1-2天
- **阶段2.2** (核心模块迁移): 3-5天  
- **阶段2.3** (专业模块迁移): 2-3天
- **测试和优化**: 1-2天

**总计**: 约 7-12天

## 相关资源

- **第一阶段**: Issue #736, PR #737
- **统一错误处理**: `src/unified_errors.ml`
- **错误处理文档**: `doc/design/error-handling.md`
- **测试指南**: `doc/testing/error-handling-tests.md`

---

**类型**: 🔧 技术债务改进  
**优先级**: 高  
**预期工作量**: 中等  
**影响范围**: 核心功能模块  
**相关模块**: 词法分析器、解析器、代码生成器、诗词分析  

**标签**: `技术债务`, `错误处理`, `代码质量`, `重构`, `统一化`
"""

    data = {
        'title': issue_title,
        'body': issue_body,
        'labels': ['技术债务', '错误处理', '代码质量', '重构']
    }
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        issue = response.json()
        print(f"✅ Issue 创建成功!")
        print(f"Issue #{issue['number']}: {issue['title']}")
        print(f"URL: {issue['html_url']}")
        return issue['number']
    else:
        print(f"❌ Issue 创建失败:")
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return None

if __name__ == '__main__':
    create_failwith_migration_issue()