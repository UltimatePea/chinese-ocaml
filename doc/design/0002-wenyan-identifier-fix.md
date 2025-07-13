# Wenyan标识符修复设计文档

## 问题描述

当前词法分析器在严格模式下会拒绝`IdentifierTokenSpecial`类型的标识符（如"数值"），要求使用引用形式「数值」。但这与wenyan风格语法冲突，例如：

```
设数值为42  // 应该允许
```

现在会报错：`内置标识符 '数值' 应该使用引用形式「数值」`

## 解决方案

### 方案1：修改词法分析器（推荐）

在词法分析器中，将`IdentifierTokenSpecial`转换为普通的`IdentifierToken`，而不是抛出错误。这样可以保持wenyan语法的自然性。

修改内容：
- 在`src/lexer.ml`的`next_token`函数中，将`IdentifierTokenSpecial`处理为普通标识符
- 保留引用语法「」的支持，但不强制要求

### 方案2：修改解析器

在解析器的`parse_wenyan_compound_identifier`函数中添加对`IdentifierTokenSpecial`的支持。

## 实施步骤

1. 修改`src/lexer.ml`中的token处理逻辑
2. 测试wenyan语法解析
3. 确保向后兼容性
4. 运行测试套件验证修复

## 预期效果

修复后，以下wenyan语法应该正常工作：
- `设数值为42`
- `吾有一数名曰数值其值42也在数值`
- 其他使用特殊标识符的wenyan构造

## 兼容性

该修复不会破坏现有功能：
- 引用语法「数值」仍然受支持
- 其他严格模式规则保持不变
- 现有测试应该继续通过