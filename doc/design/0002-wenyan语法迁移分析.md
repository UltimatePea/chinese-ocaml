# Wenyan语法迁移分析

## 概述

分析文言编程语言(wenyan-lang)的语法特征，评估将其核心特性迁移到骆言编程语言中的可行性。

## Wenyan-lang核心语法特征

### 1. 变量声明
**Wenyan方式:**
```
吾有一數。曰三。名之曰「甲」。
```
**当前骆言实现:**
```
吾有一数名曰数值其值42也
```

### 2. 循环结构
**Wenyan方式:**
```
為是「甲」遍。
    # 重复执行甲次
云云。
```
**需要在骆言中实现**

### 3. 条件语句
**Wenyan方式:**
```
若「甲」大于「乙」者。
    # 条件为真时执行
也。
```

### 4. 函数定义
**Wenyan方式:**
```
吾有一术。名之曰「快排」。欲行是术。必先得「陣列」一列。
是术曰。
    # 函数体
云云。
```

## 当前骆言语法状态

### 已实现的wenyan风格特征:
- ✅ `吾有` (HaveKeyword) - 变量声明
- ✅ `一` (OneKeyword) - 数量词
- ✅ `名曰` (NameKeyword) - 命名
- ✅ `其值` (ValueKeyword) - 赋值
- ✅ `也` (AlsoKeyword) - 结束助词
- ✅ `乃` (ThenGetKeyword) - 连接词
- ✅ `曰` (CallKeyword) - 称为/说
- ✅ `为` (AsForKeyword) - 关于/对于
- ✅ `数` (NumberKeyword) - 数字类型

### 需要添加的wenyan特征:

#### 1. 循环关键字
- `為是` (for-this) - 循环开始
- `遍` (times) - 次数
- `云云` (end) - 结束标记

#### 2. 条件关键字
- `若` (if) - 如果 (类似现有的`如果`)
- `者` (particle) - 语气助词
- `大于` / `小于` (comparisons) - 比较运算符的中文形式

#### 3. 函数关键字
- `术` (method/technique) - 函数/方法
- `欲行` (want-to-execute) - 执行
- `必先得` (must-first-get) - 必须先获得参数

#### 4. 经典助词
- `之` (possessive particle)
- `者` (topic marker)
- `云云` (etc./end marker)

## 迁移策略

### 阶段1: 扩展词法分析器
1. 添加wenyan风格关键字到lexer.ml
2. 更新关键字映射表
3. 确保向后兼容性

### 阶段2: 扩展语法分析器
1. 实现wenyan风格循环语法
2. 扩展条件语句支持wenyan风格
3. 添加wenyan风格函数定义语法

### 阶段3: 代码生成支持
1. 确保新语法能正确生成代码
2. 维护与现有代码生成器的兼容性

### 阶段4: 测试和文档
1. 为所有新语法添加测试用例
2. 更新用户文档
3. 提供迁移指南

## 设计原则

1. **兼容性优先**: 确保现有代码仍然有效
2. **渐进迁移**: 允许混合使用新旧语法
3. **语义一致**: wenyan语法应与现有语义保持一致
4. **文档化**: 为每个新特性提供清晰的中文文档

## 技术考虑

### 词法冲突处理
- 确保新关键字不与现有标识符冲突
- 实现最长匹配优先原则
- 提供清晰的错误消息

### 语法歧义处理
- 定义优先级规则
- 处理可能的语法歧义
- 确保解析的确定性

## 实施计划

1. **立即开始**: 词法分析器扩展 (本次commit)
2. **下一阶段**: 语法解析器扩展
3. **后续工作**: 代码生成和测试完善

这将使骆言成为更加中国化和文言化的编程语言，同时保持现代编程语言的实用性。