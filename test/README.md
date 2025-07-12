# 骆言编译器测试套件

## 概述

本测试套件为骆言编译器提供了完整的端到端测试覆盖，包括：

1. **单元测试** (`test_yyocamlc.ml`) - 测试各个编译器组件
2. **端到端测试** (`test_e2e.ml`) - 测试完整的编译和执行流程
3. **文件测试** (`test_file_runner.ml`) - 测试实际源代码文件

## 测试结构

```
test/
├── test_yyocamlc.ml          # 单元测试
├── test_e2e.ml               # 端到端测试
├── test_file_runner.ml       # 文件测试运行器
├── test_all.ml               # 完整测试套件
├── dune                      # 测试配置
├── README.md                 # 本文档
└── test_files/               # 测试文件目录
    ├── hello_world.ly        # Hello World 程序
    ├── hello_world.expected  # 期望输出
    ├── arithmetic.ly         # 算术运算程序
    ├── arithmetic.expected   # 期望输出
    ├── factorial.ly          # 阶乘计算程序
    ├── factorial.expected    # 期望输出
    ├── fibonacci.ly          # 斐波那契数列程序
    ├── fibonacci.expected    # 期望输出
    ├── conditionals.ly       # 条件语句程序
    ├── conditionals.expected # 期望输出
    ├── pattern_matching.ly   # 模式匹配程序
    ├── pattern_matching.expected # 期望输出
    ├── list_operations.ly    # 列表操作程序
    ├── list_operations.expected # 期望输出
    ├── nested_functions.ly   # 嵌套函数程序
    ├── nested_functions.expected # 期望输出
    ├── error_lexer.ly        # 词法错误测试
    ├── error_syntax.ly       # 语法错误测试
    └── error_runtime.ly      # 运行时错误测试
```

## 运行测试

### 运行所有测试
```bash
dune runtest --force
```

### 运行特定测试
```bash
# 单元测试
dune exec -- test_yyocamlc

# 端到端测试
dune exec -- test_e2e

# 文件测试
dune exec -- test_file_runner
```

### 运行测试并显示详细输出
```bash
dune runtest --force --verbose
```

## 测试类型

### 1. 单元测试 (`test_yyocamlc.ml`)

测试各个编译器组件的功能：

- **词法分析器测试**
  - 基本词法分析
  - 中文关键字识别
  - 数字字面量
  - 字符串字面量
  - 运算符识别

- **语法分析器测试**
  - 基本表达式解析
  - 变量声明解析
  - 函数定义解析
  - 条件表达式解析
  - 递归函数定义解析
  - 模式匹配解析

- **代码生成测试**
  - 基本表达式求值
  - 变量查找
  - 条件表达式求值
  - 函数调用
  - 内置函数
  - 递归函数
  - 模式匹配
  - 取模运算
  - 列表模式匹配
  - 复杂递归函数

- **错误处理测试**
  - 词法错误处理
  - 语法错误处理
  - 运行时错误处理

- **集成测试**
  - 完整程序编译和执行
  - 阶乘计算程序

### 2. 端到端测试 (`test_e2e.ml`)

测试完整的编译和执行流程：

- **基础功能**
  - Hello World
  - 基本算术
  - 条件语句
  - 模式匹配

- **函数和递归**
  - 阶乘计算
  - 斐波那契数列
  - 嵌套函数

- **数据结构**
  - 列表操作
  - 排序算法

- **错误处理**
  - 词法错误
  - 语法错误
  - 运行时错误

- **系统功能**
  - 文件编译
  - 交互式模式

- **性能和边界**
  - 大数计算
  - 深度递归
  - 边界条件

### 3. 文件测试 (`test_file_runner.ml`)

测试实际的源代码文件：

- **基础功能测试**
  - 所有基础文件编译和执行
  - 文件编译功能

- **错误处理测试**
  - 各种错误情况的处理

- **复杂程序测试**
  - 复杂算法实现
  - 性能测试
  - 边界条件测试

## 测试文件说明

### 成功测试文件

1. **hello_world.ly** - 基本的 Hello World 程序
2. **arithmetic.ly** - 基本算术运算
3. **factorial.ly** - 递归阶乘计算
4. **fibonacci.ly** - 斐波那契数列计算
5. **conditionals.ly** - 条件语句测试
6. **pattern_matching.ly** - 模式匹配测试
7. **list_operations.ly** - 列表操作测试
8. **nested_functions.ly** - 嵌套函数测试

### 错误测试文件

1. **error_lexer.ly** - 包含词法错误的程序
2. **error_syntax.ly** - 包含语法错误的程序
3. **error_runtime.ly** - 包含运行时错误的程序

## 期望输出格式

每个测试文件都有一个对应的 `.expected` 文件，包含期望的输出。输出格式为纯文本，包含所有打印语句的输出。

## 添加新测试

### 添加新的测试文件

1. 在 `test/test_files/` 目录下创建 `.ly` 文件
2. 创建对应的 `.expected` 文件
3. 在 `test_file_runner.ml` 中添加测试用例

### 添加新的单元测试

1. 在相应的测试文件中添加测试函数
2. 在测试套件中注册新的测试用例

### 添加新的端到端测试

1. 在 `test_e2e.ml` 中添加测试函数
2. 在测试套件中注册新的测试用例

## 测试覆盖率

本测试套件覆盖了以下方面：

- ✅ 词法分析
- ✅ 语法分析
- ✅ 语义分析
- ✅ 代码生成
- ✅ 错误处理
- ✅ 文件编译
- ✅ 交互式模式
- ✅ 性能测试
- ✅ 边界条件测试

## 注意事项

1. 所有测试都应该能够独立运行
2. 测试文件应该包含有意义的注释
3. 错误测试应该验证正确的错误处理
4. 性能测试应该考虑实际使用场景
5. 边界条件测试应该覆盖极端情况

## 故障排除

如果测试失败，请检查：

1. 编译器是否正确编译
2. 测试文件是否存在
3. 期望输出文件是否正确
4. 文件权限是否正确
5. 依赖库是否正确安装