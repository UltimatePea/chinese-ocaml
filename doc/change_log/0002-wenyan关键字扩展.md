# Wenyan关键字扩展 (2025-07-12)

## 概述

扩展骆言编程语言的词法分析器，增加更多wenyan-lang风格的经典中文关键字，为未来实现完整的文言编程语法奠定基础。

## 新增关键字

### 函数定义相关
- `术` (MethodKeywordWenyan) - 方法/技术
- `欲行` (WantExecuteKeyword) - 欲执行
- `必先得` (MustFirstGetKeyword) - 必须先获得

### 循环控制相关
- `為是` (ForThisKeyword) - 为此/对于
- `遍` (TimesKeyword) - 遍数/次数
- `云云` (EndCloudKeyword) - 结束标记

### 条件判断相关
- `若` (IfWenyanKeyword) - 如果(文言风格)
- `者` (ThenWenyanKeyword) - 语气助词

### 比较运算相关
- `大于` (GreaterThanWenyan) - 大于
- `小于` (LessThanWenyan) - 小于

### 语法助词
- `之` (OfParticle) - 的/之(所有格助词)

## 技术实现

1. **词法分析器扩展**: 在`src/lexer.ml`中添加了新的token类型
2. **关键字映射**: 更新了`keyword_table`以支持新的中文关键字
3. **测试覆盖**: 添加了专门的测试用例验证新关键字的识别

## 向后兼容性

✅ 完全保持与现有代码的兼容性
✅ 新关键字不与现有标识符冲突
✅ 现有测试全部通过 (125/125)

## 下一步计划

1. **语法解析器扩展**: 实现这些关键字的语法解析逻辑
2. **代码生成**: 为新语法添加代码生成支持
3. **示例程序**: 创建更多wenyan风格的示例程序
4. **文档完善**: 编写详细的wenyan语法使用指南

## 影响的文件

- `src/lexer.ml` - 添加新token类型和关键字映射
- `test/test_wenyan_syntax.ml` - 添加扩展关键字测试
- `examples/wenyan_demo.yu` - 创建演示文件
- `doc/design/0002-wenyan语法迁移分析.md` - 设计文档

## 测试结果

- 新增测试: `wenyan扩展关键字词法分析`
- 总测试数: 125 (从124增加)
- 通过率: 100%

这个改进让骆言编程语言向着更加中国化、文言化的方向迈进了重要一步。