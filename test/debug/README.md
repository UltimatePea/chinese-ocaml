# 调试文件目录

此目录包含用于调试和测试编译器各个组件的辅助文件。

## 文件说明

### 词法分析器调试文件
- `debug_lexer.ml` - 通用词法分析器调试工具

### 语法分析器调试文件
- `debug_wenyan.ml` - 文言文语法调试工具

### 功能测试调试文件
- `debug_array.ml` - 数组功能调试工具
- `debug_fullwidth.ml` - 全角字符调试工具

### 综合调试文件
- `simple_debug.ml` - 简单调试工具

### 已清理的文件
为了提高项目可维护性，以下文件已在技术债务清理中移除：
- ~~`debug_lexer_176.ml`~~ - Issue #176 特定调试（已解决）
- ~~`debug_lexer_tokens.ml`~~ - 与debug_lexer.ml功能重复
- ~~`debug_tokens.ml`~~ - 与debug_lexer.ml功能重复
- ~~`debug_ast_structure.ml`~~ - 基础AST调试（可用现有工具）
- ~~`debug_parsing_issue.ml`~~ - 特定问题调试（已过时）
- ~~`debug_pattern_ast.ml`~~ - 基础模式匹配调试
- ~~`debug_pattern_matching.ml`~~ - 与上面重复
- ~~`debug_array_test.ml`~~ - 与debug_array.ml重复
- ~~`test_debug_arrays.ml`~~ - 与debug_array.ml重复
- ~~`debug_function_call.ml`~~ - 简单函数调用测试
- ~~`debug2.ml`~~ - 与simple_debug.ml功能重复

## 使用方法

这些文件可以用来：
1. 测试特定的编译器组件
2. 重现和调试问题
3. 验证新功能的正确性
4. 探索编译器的行为

## 编译和运行

大多数调试文件可以通过以下方式编译和运行：

```bash
# 编译单个调试文件
ocamlc -I ../../src -o debug_test debug_lexer.ml

# 或者使用 dune
dune exec -- ocamlc -I ../../src -o debug_test debug_lexer.ml
```

## 维护说明

- 这些文件仅用于调试和测试目的
- 不应包含在正式的构建流程中
- 过时的调试文件应及时清理
- 新的调试文件应遵循命名约定：`debug_<组件名>.ml`

## 注意事项

- 这些文件可能引用旧版本的 API
- 运行前请确保与当前代码库版本兼容
- 部分文件可能需要特定的输入或环境才能正确运行