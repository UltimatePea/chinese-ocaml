# 骆言编程语言说明书

[![CI/CD Pipeline](https://github.com/UltimatePea/chinese-ocaml/actions/workflows/ci.yml/badge.svg)](https://github.com/UltimatePea/chinese-ocaml/actions/workflows/ci.yml)

夫骆言者，乃新时代中文编程之语言也。融函数式编程之雅致，承中华文化之深蕴，基于OCaml强固类型体系，提供纯正中文语法体验。

<!-- 修复Issue #87进行中：移除现代风格支持，只保留古雅风格 -->

## 功能特色

### 🎯 核心特性
- **纯中文语法**：举凡关键字、函数名，皆用中文，合乎中文思维之道
- **强类型系统**：承OCaml类型推导之妙，提供类型安全之保障
- **函数式编程**：支持高阶函数、模式匹配、递归等函数式之特性
- **古雅体语法**：独有文言文风格语法选项，彰显中华文化之韵味

### 🤖 智能辅助特性
- **自然语言函数定义**：支持近乎自然语言之函数声明方式
- **智能错误恢复**：自动修正常见语法错误，提供智慧建议
- **AI代码生成辅助**：内置AI辅助功能，助生成代码模板
- **模式学习系统**：学习代码模式，提供上下文相关之建议

## 入门指南

### 在线体验

[![在GitHub Codespaces中打开](https://github.com/codespaces/badge.svg)](https://codespaces.new/UltimatePea/chinese-ocaml)

无需本地安装，可直接于浏览器中体验骆言编程：
- 点击上方徽章即可启动在线开发环境
- 预配置了所有依赖和工具
- 支持完整的编译和测试功能
- 适合快速学习和原型开发

### 本地安装

```bash
# 克隆仓库
git clone https://github.com/UltimatePea/chinese-ocaml.git
cd chinese-ocaml

# 安装依赖
opam install . --deps-only

# 构建项目
dune build
```

### 初试程序

创建文件 `你好.ly`：

```luoyan
让 「问候」 = "你好，世界！"
打印 「问候」
```

运行程序：

```bash
dune exec yyocamlc -- 你好.ly
```

## 语法示例

### 变量定义

```luoyan
让 「姓名」 = "李白"
让 「年龄」 = 30
让 「是学生」 = 假
```

### 函数定义

现代风格：
```luoyan
让 「加法」 = 函数 「甲」 -> 函数 「乙」 -> 「甲」 + 「乙」
```

古雅体风格：
```luoyan
夫「加法」者受 甲 乙 焉算法乃
  答 甲 加 乙
也
```

### 条件判断

```luoyan
如果 「年龄」 >= 18 那么
  打印 "成年人"
否则
  打印 "未成年人"
```

### 模式匹配

现代风格：
```luoyan
匹配 「数字」 与
| 0 -> "零"
| 1 -> "一"
| _ -> "其他"
```

古雅体风格：
```luoyan
观「数字」之性
若 0 则 答 『零』
若 1 则 答 『一』
余者则 答 『其他』
观毕
```

### 列表操作

```luoyan
让 「数组」 = 列开始 1 其一 2 其二 3 其三 列结束

递归 让 「求和」 = 函数 「lst」 ->
  观「lst」之性
  若 空空如也 则 答 0
  若 有首有尾 首名为「头」 尾名为「尾」 则
    答 「头」 + 「求和」 「尾」
  观毕
```

## 项目结构

```
chinese-ocaml/
├── src/              # 编译器源代码
│   ├── lexer.ml     # 词法分析器
│   ├── parser.ml    # 语法分析器
│   ├── ast.ml       # 抽象语法树
│   ├── semantic.ml  # 语义分析
│   └── codegen.ml   # 代码生成
├── 标准库/           # 标准库实现
├── 示例/             # 示例程序
├── test/            # 测试用例
└── doc/             # 文档
```

## 开发指南

### 运行测试

```bash
# 运行所有测试
dune runtest

# 运行特定测试
dune exec test/test_e2e.exe
```

### 构建文档

```bash
dune build @doc
```

### 代码格式化

```bash
dune build @fmt --auto-promote
```

## 标准库

骆言提供丰富之标准库支持：

- **基础**：基本类型和操作
- **列表**：列表操作函数  
- **字符串**：字符串处理
- **数学**：数学函数
- **输入输出**：I/O操作

## 发展路线

- [x] 基础语法实现
- [x] 古雅体语法支持  
- [x] AI辅助功能
- [x] 模块系统
- [ ] 完整之标准库
- [ ] 包管理器
- [ ] IDE支持
- [ ] 自举编译器

## 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

## 已知问题

- Issue #75: 词法分析器处理全宽Unicode字符时可能出现问题
- Issue #77: 古雅体模式匹配语法在某些情况下解析失败

## 许可证

本项目采用MIT许可证。详见 [LICENSE](LICENSE) 文件。

## 致谢

感谢所有贡献者之努力，让中文编程变得更加优雅和强大。

---

*骆言 - 让编程说中文*# 触发CI重新运行
