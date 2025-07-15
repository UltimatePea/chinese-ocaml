# 词法分析器重构设计 - Lexer Refactoring Design

## 概述
当前的 `lexer.ml` 文件过大（1218行），需要重构为多个模块以提高可维护性。

## 重构计划

### 1. 词元类型模块 (`token.ml`)
- `token` 类型定义
- `position` 类型定义  
- `positioned_token` 类型定义
- `show_token` 函数
- 词元显示和比较函数

### 2. 关键字模块 (`keywords.ml`)
- `keyword_table` 关键字映射表
- `reserved_words` 保留词表
- `find_keyword` 查找关键字函数
- `is_reserved_word` 检查保留词函数

### 3. 字符处理模块 (`char_utils.ml`)
- `is_chinese_char` 中文字符检查
- `is_letter_or_chinese` 字母或中文检查
- `is_digit` 数字检查
- `is_fullwidth_digit_utf8` 全宽数字检查
- `convert_fullwidth_digit` 全宽数字转换
- `is_identifier_char` 标识符字符检查
- `is_whitespace` 空白字符检查
- `is_delimiter` 分隔符检查

### 4. 核心词法分析器 (`lexer.ml`)
- `lexer_state` 状态类型
- `tokenize` 主要词法分析函数
- 错误处理和恢复逻辑
- 词法分析器状态管理

## 模块依赖关系
```
lexer.ml -> token.ml
lexer.ml -> keywords.ml  
lexer.ml -> char_utils.ml
keywords.ml -> token.ml
```

## 实施步骤
1. 创建 `token.ml` 模块并移动相关定义
2. 创建 `keywords.ml` 模块并移动关键字相关代码
3. 创建 `char_utils.ml` 模块并移动字符处理函数
4. 重构 `lexer.ml` 使用新模块
5. 更新 `dune` 文件包含新模块
6. 运行测试确保功能正常

## 预期效果
- 减少单个文件大小
- 提高代码可维护性
- 更好的模块化设计
- 便于单元测试和调试