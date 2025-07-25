# 词法分析器令牌重构方案

Author: Charlie, Planner Agent

## 问题分析

`lexer_tokens.ml` 文件存在以下问题：
- 文件过长（260行）
- 单一大型token类型包含238个变体
- 循环复杂度高达238
- 缺乏模块化组织

## 重构目标

- 将单一大型token类型分解为多个功能模块
- 每个模块负责特定类别的token
- 保持API兼容性
- 提高代码可维护性

## 模块划分方案

### 1. 基础类型模块 (`lexer_tokens_literals.ml`)
- 字面量类型：IntToken, FloatToken, ChineseNumberToken, StringToken, BoolToken
- 标识符类型：QuotedIdentifierToken, IdentifierTokenSpecial

### 2. 核心关键字模块 (`lexer_tokens_core.ml`)
- 基础语言关键字：LetKeyword, RecKeyword, InKeyword, FunKeyword等
- 控制流关键字：IfKeyword, ThenKeyword, ElseKeyword, MatchKeyword等
- 类型系统关键字：TypeKeyword, PrivateKeyword, AsKeyword等

### 3. 模块系统关键字 (`lexer_tokens_modules.ml`)
- 模块关键字：ModuleKeyword, ModuleTypeKeyword, SigKeyword等
- 宏系统关键字：MacroKeyword, ExpandKeyword

### 4. 文言文风格关键字 (`lexer_tokens_wenyan.ml`)
- wenyan风格关键字：HaveKeyword, OneKeyword, NameKeyword等
- wenyan扩展关键字：WantExecuteKeyword, MustFirstGetKeyword等

### 5. 古雅体关键字 (`lexer_tokens_ancient.ml`)
- 古雅体关键字：AncientDefineKeyword, AncientEndKeyword等
- 古雅体记录类型关键词：AncientRecordStartKeyword等

### 6. 诗词音韵关键字 (`lexer_tokens_poetry.ml`)
- 古典诗词音韵相关关键字：RhymeKeyword, ToneKeyword等
- 诗词格律关键字：PoetryKeyword, RegulatedVerseKeyword等

### 7. 运算符模块 (`lexer_tokens_operators.ml`)
- 算术运算符：Plus, Minus, Multiply等
- 比较运算符：Equal, NotEqual, Less等
- 特殊运算符：Arrow, DoubleArrow, Dot等

### 8. 分隔符模块 (`lexer_tokens_delimiters.ml`)
- 英文分隔符：LeftParen, RightParen, LeftBracket等
- 中文分隔符：ChineseLeftParen, ChineseRightParen等

### 9. 主模块 (`lexer_tokens.ml`)
- 统一的token类型定义
- 位置信息类型
- 异常定义
- 导出所有子模块的内容

## 实现策略

1. 创建各个子模块文件，定义各自的token变体
2. 在主模块中组合所有子模块的类型
3. 确保现有代码继续使用统一的token类型
4. 逐步测试确保兼容性

## 兼容性保证

- 保持原有的`token`类型名称和变体名称不变
- 保持原有的导出接口不变
- 确保现有使用该模块的代码无需修改

## 测试计划

- 编译测试：确保重构后代码能正常编译
- 功能测试：运行现有测试用例确保功能不变
- 性能测试：确保重构不影响词法分析性能