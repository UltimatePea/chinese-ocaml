# 骆言 (LuoYan) 在线 IDE 文件清单

## 总览

此清单包含了骆言编程语言项目中所有应该在在线 IDE 中显示的源代码文件、测试文件和示例文件。

### 文件统计汇总

| 文件类型 | 数量 | 说明 |
|---------|------|------|
| .ly 文件 (骆言源码) | 102 | 骆言语言源代码文件 |
| .ml 文件 (测试) | 69 | OCaml 测试文件 |
| .expected 文件 | 10 | 预期输出文件 |
| .expected_error 文件 | 3 | 预期错误输出文件 |
| .c 文件 (相关) | 7 | 项目相关 C 代码文件 |
| **总计** | **191** | **所有相关文件** |

## 按目录分类的详细清单

### 1. 示例/ (35 个 .ly 文件)
**描述**: 骆言语言的各种示例程序，展示语言特性和用法

- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/advanced_features.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/async.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/factorial.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/fibonacci.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/hello.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/list_operations.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/macro_test.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/macros.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/module_test.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/pattern_matching.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/simple_wenyan.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/sorting_algorithms.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/stdlib.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/stdlib_demo.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/stdlib_migration_demo.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_builtin_functions.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_chinese_c.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_chinese_errors.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_math_functions.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_or_else.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_param_adaptation.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_polymorphism.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_simple_polymorphism.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_simple_types.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_spell_correction.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_type_inference.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_verbose_recovery.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/wenyan_demo.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/wenyan_style_demo.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/工作文件处理示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/数据处理示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/文件处理示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/智能文档生成器演示.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/简单文件处理示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/超简单示例.ly

### 2. 标准库/ (5 个 .ly 文件)
**描述**: 骆言语言的标准库实现

- /home/runner/work/chinese-ocaml/chinese-ocaml/标准库/基础.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/标准库/列表.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/标准库/字符串.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/标准库/数学.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/标准库/输入输出.ly

### 3. test/ (测试文件)
**描述**: 编译器和语言特性的测试文件

#### 3.1 古雅体测试 (.ly 文件, 10 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_complete.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_complex.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_condition.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_final.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_function_only.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_list.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_list_function.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_match.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_simple.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_ancient_style.ly

#### 3.2 测试输入文件 (test/test_files/, 16 个 .ly 文件)
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/arithmetic.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/conditionals.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_div_zero.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_lexer.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_runtime.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_syntax.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_type_mismatch.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_undefined_var.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/factorial.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/fibonacci.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/hello_world.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/list_operations.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/nested_functions.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/pattern_matching.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/records_c.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/records_update_c.ly

#### 3.3 预期输出文件 (test/test_files/, 13 个)
**期望输出文件 (.expected 文件, 10 个):**
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/arithmetic.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/conditionals.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/factorial.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/fibonacci.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/hello_world.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/list_operations.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/nested_functions.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/pattern_matching.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/records_c.expected
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/records_update_c.expected

**期望错误输出文件 (.expected_error 文件, 3 个):**
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_div_zero.expected_error
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_type_mismatch.expected_error
- /home/runner/work/chinese-ocaml/chinese-ocaml/test/test_files/error_undefined_var.expected_error

#### 3.4 测试实现文件 (.ml 文件, 69 个)
包含所有 OCaml 测试实现文件，用于验证编译器各个组件的正确性。

### 4. 自举/ (7 个 .ly 文件)
**描述**: 自举编译器相关文件

- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/完整自举编译器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/简单编译器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/自举编译器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/自举编译器_标准库版.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/自举编译器v2.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/骆言编译器_单文件.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/骆言编译器_超简化.ly

### 5. 骆言编译器/ (12 个 .ly 文件)
**描述**: 用骆言语言实现的编译器源码

#### 5.1 测试文件 (5 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/测试/C代码生成器测试.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/测试/测试运行器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/测试/词法分析器测试.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/测试/语义分析器测试.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/测试/语法分析器测试.ly

#### 5.2 源码文件 (7 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/编译器驱动程序.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/代码生成/C代码生成器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/基础工具/位置信息.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/基础工具/工具库.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/基础工具/抽象语法树.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/基础工具/错误处理.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/词法分析/词法分析器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/语义分析/类型系统.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/语义分析/语义分析器.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/骆言编译器/源码/语法分析/语法分析器.ly

### 6. 性能测试/ (6 个 .ly 文件)
**描述**: 性能基准测试文件

#### 6.1 微基准测试 (3 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/性能测试/micro/arithmetic_bench.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/性能测试/micro/function_call_bench.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/性能测试/micro/simple_bench.ly

#### 6.2 宏基准测试 (3 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/性能测试/macro/fib_bench.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/性能测试/macro/fibonacci_bench.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/性能测试/macro/simple_fibonacci_bench.ly

### 7. 根目录示例 (6 个 .ly 文件)
**描述**: 位于项目根目录的示例文件

- /home/runner/work/chinese-ocaml/chinese-ocaml/AI友好语法示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/AI友好语法工作示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/简单AI友好示例.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test_ancient_list_comprehensive.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test_long_ancient_list.ly
- /home/runner/work/chinese-ocaml/chinese-ocaml/test_problematic_list.ly

### 8. VSCode 扩展示例 (1 个 .ly 文件)
**描述**: VSCode 插件的测试示例

- /home/runner/work/chinese-ocaml/chinese-ocaml/vscode-luoyan/test-example.ly

### 9. C 代码文件 (7 个相关 .c 文件)
**描述**: 项目相关的 C 代码文件

#### 9.1 C 后端运行时 (2 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/C后端/runtime/luoyan_runtime.c
- /home/runner/work/chinese-ocaml/chinese-ocaml/C后端/test_simple.c

#### 9.2 自举编译器 C 版本 (4 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/experimental/骆言编译器_超简化.c
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/legacy/bootstrap_compiler.c
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/legacy/bootstrap_v2.c
- /home/runner/work/chinese-ocaml/chinese-ocaml/自举/legacy/full_bootstrap_compiler.c

#### 9.3 示例 C 代码 (1 个)
- /home/runner/work/chinese-ocaml/chinese-ocaml/示例/test_chinese_c.c

## 推荐的 IDE 文件组织结构

```
骆言语言在线IDE/
├── 示例/                     (35 个 .ly 文件)
│   ├── 基础示例/
│   ├── 高级特性/
│   └── 应用示例/
├── 标准库/                   (5 个 .ly 文件)
├── 测试文件/                 (39 个文件)
│   ├── 输入文件/              (26 个 .ly 文件)
│   ├── 预期输出/              (13 个 .expected* 文件)
│   └── 测试实现/              (69 个 .ml 文件)
├── 自举编译器/               (7 个 .ly 文件)
├── 性能测试/                 (6 个 .ly 文件)
├── C后端/                    (7 个 .c 文件)
└── 教程/                     (6 个根目录 .ly 文件)
```

## 建议的优先级

1. **高优先级**: 示例/、标准库/、教程文件 (46 个文件)
2. **中优先级**: 测试文件/输入文件、自举编译器/ (33 个文件)
3. **低优先级**: 测试实现、C代码、性能测试 (82 个文件)

这样的组织方式可以让用户从简单到复杂、从基础到高级逐步学习和使用骆言编程语言。