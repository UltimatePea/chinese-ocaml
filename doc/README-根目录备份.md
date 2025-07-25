# 骆言 (Luoyan) - 中文编程语言

骆言是一个完全中文化的编程语言编译器，模仿OCaml的语法和语义，但使用中文关键字和语法结构。项目旨在为中文用户提供一个熟悉、易用的函数式编程语言。

## 🌟 核心特性

### 🈶 中文语法支持
- **中文关键字**: 让、递归、函数、如果、那么、否则、匹配、与等
- **中文标识符**: 支持中文变量名和函数名
- **UTF-8编码**: 完整的Unicode字符支持

### 🔧 基础语言特性
- **变量绑定**: `让 x = 表达式`
- **递归函数**: `递归 让 f = 函数 x -> 表达式`
- **条件表达式**: `如果 条件 那么 expr1 否则 expr2`
- **函数定义**: `函数 x y -> 表达式`
- **函数调用**: `f(x, y)`

### 🚀 高级语言特性
- **模式匹配**: `匹配 expr 与 | 模式 -> 表达式`
- **列表操作**: 支持列表字面量、模式匹配和操作
- **类型系统**: 静态类型检查，支持基础类型和复合类型
- **错误处理**: 词法、语法、语义和运行时错误处理
- **模块系统**: 支持模块定义和导入
- **宏系统**: 支持宏定义和代码生成
- **异步编程**: 支持异步表达式和并发编程

### ⚡ 运算符支持
- **算术运算符**: `+`, `-`, `*`, `/`, `%` (取模运算)
- **比较运算符**: `==`, `<>`, `<`, `<=`, `>`, `>=`
- **逻辑运算符**: `并且`, `或者`, `非`
- **列表运算符**: `@` (连接), `::` (构造)

### 📊 数据结构
- **列表**: `[1; 2; 3]`
- **元组**: `(x, y, z)`
- **模式匹配**: 支持列表解构、通配符、变量绑定

## 📚 文档

完整的技术文档请访问 [文档索引](doc/index.md)，包括：
- 语言设计文档
- AI友好特性说明
- 编译器架构
- 开发日志

## 📁 项目结构

```
chinese-ocaml/
├── 源码/                    # 源代码
│   ├── lexer.ml           # 词法分析器
│   ├── parser.ml          # 语法分析器
│   ├── ast.ml             # 抽象语法树
│   ├── semantic.ml        # 语义分析
│   ├── types.ml           # 类型系统
│   ├── codegen.ml         # 代码生成器
│   └── main.ml            # 主程序
├── 示例/              # 示例程序
│   ├── hello.ly           # Hello World
│   ├── factorial.ly       # 阶乘计算
│   ├── pattern_matching.ly # 模式匹配
│   ├── fibonacci.ly       # 斐波那契数列
│   ├── list_operations.ly # 列表操作
│   ├── advanced_features.ly # 高级特性
│   ├── stdlib.ly          # 标准库模块
│   ├── macros.ly          # 宏系统示例
│   └── async.ly           # 异步编程示例
├── 测试/                  # 测试用例
│   └── test_yyocamlc.ml   # 综合测试
└── dune-project           # 项目配置
```

## 💡 示例程序

### 基础示例
```ocaml
(* Hello World *)
让 消息 = "你好，骆言！"
打印 消息
```

### 递归函数
```ocaml
(* 阶乘计算 *)
递归 让 阶乘 = 函数 n ->
  如果 n <= 1 那么
    1
  否则
    n * 阶乘 (n - 1)

让 结果 = 阶乘 5
```

### 模式匹配
```ocaml
(* 列表处理 *)
递归 让 列表长度 = 函数 lst ->
  匹配 lst 与
  | [] -> 0
  | [head; ...tail] -> 1 + 列表长度 tail
```

### 高级特性
```ocaml
(* 高阶函数 *)
递归 让 映射 = 函数 f lst ->
  匹配 lst 与
  | [] -> []
  | [head; ...tail] -> [f head; ...映射 f tail]

让 平方列表 = 映射 (函数 x -> x * x) [1; 2; 3; 4; 5]
```

### 模块系统
```ocaml
(* 模块定义 *)
模块 数学 = {
  导出: [("阶乘", 函数类型 (整数类型, 整数类型))];
  语句: [
    递归 让 阶乘 = 函数 n ->
      如果 n <= 1 那么 1 否则 n * 阶乘 (n - 1)
  ];
}

(* 模块导入 *)
导入 数学: [阶乘];
让 结果 = 阶乘 5
```

### 宏系统
```ocaml
(* 宏定义 *)
宏 循环 (次数: 表达式) (体: 语句) = {
  递归 让 循环辅助 = 函数 n ->
    如果 n <= 0 那么 () 否则 体; 循环辅助 (n - 1)
  在 循环辅助 次数 中
}

(* 宏使用 *)
循环 3 {
  打印 "Hello, 骆言!"
}
```

### 异步编程
```ocaml
(* 异步函数 *)
异步 函数 异步计算 = 函数 n ->
  让 延迟 = 函数 ms ->
    如果 ms <= 0 那么 () 否则 延迟 (ms - 1)
  在
    延迟 1000;
    n * n

(* 并发执行 *)
让 任务 = 生成 异步计算 5;
让 结果 = 等待 任务
```

## 🛠️ 编译和运行

### 构建项目
```bash
dune build
```

### 运行编译器
```bash
dune exec yyocamlc -- 示例/hello.ly
```

### 运行测试
```bash
dune runtest
```

## 🔬 技术实现

### 词法分析
- 使用`uutf`库处理UTF-8编码
- 支持中文关键字识别
- 完整的运算符和分隔符支持

### 语法分析
- 递归下降解析器
- 运算符优先级处理
- 错误恢复机制

### 语义分析
- 类型检查
- 作用域分析
- 错误诊断

### 代码生成
- 解释器实现
- 递归函数支持
- 模式匹配求值

## 🧪 测试覆盖

项目包含全面的测试用例：
- **词法分析测试**: 中文关键字、运算符、标识符
- **语法分析测试**: 表达式、语句、函数定义
- **类型系统测试**: 类型检查、类型推导
- **语义分析测试**: 作用域、错误检测
- **代码生成测试**: 表达式求值、函数调用
- **集成测试**: 完整程序编译和运行

## 📈 开发状态

### ✅ 已完成功能
- 基础语法解析
- 中文关键字支持
- 递归函数
- 模式匹配
- 类型系统
- 错误处理
- 测试框架
- 取模运算符
- 列表模式匹配
- 高级示例程序
- 模块系统基础
- 宏系统基础
- 异步编程基础

### 🔄 待开发功能
- 模块系统完整实现
- 标准库
- 优化编译
- 调试支持
- 包管理器
- 宏系统完整实现
- 异步运行时

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支
3. 编写测试用例
4. 提交代码
5. 创建Pull Request

## 📄 许可证

MIT License

## 📞 联系方式

项目维护者: [维护者信息]
项目地址: [GitHub链接]

---

**骆言** - 让编程更贴近中文用户的语言！

