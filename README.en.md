# Luoyan (骆言) - Chinese Programming Language

[![CI/CD Pipeline](https://github.com/UltimatePea/chinese-ocaml/actions/workflows/ci.yml/badge.svg)](https://github.com/UltimatePea/chinese-ocaml/actions/workflows/ci.yml)

Luoyan is a modern Chinese programming language that combines the elegance of functional programming with the profound heritage of Chinese culture. Built on OCaml's powerful type system, it provides a fully Chinese syntax experience.

[中文版](README.md)

## Features

### 🎯 Core Features
- **Pure Chinese Syntax**: All keywords and function names use Chinese, following Chinese thinking patterns
- **Strong Type System**: Based on OCaml's type inference, providing type safety
- **Functional Programming**: Supports higher-order functions, pattern matching, recursion, and other functional features
- **Classical Chinese Style**: Unique classical Chinese (wenyan) syntax options, embodying Chinese cultural aesthetics

### 🤖 AI-Friendly Features
- **Natural Language Function Definitions**: Support for function declarations closer to natural language
- **Intelligent Error Recovery**: Automatically corrects common syntax errors with smart suggestions
- **AI Code Generation Assistant**: Built-in AI assistance for generating code templates
- **Pattern Learning System**: Learns code patterns to provide context-aware suggestions

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/UltimatePea/chinese-ocaml.git
cd chinese-ocaml

# Install dependencies
opam install . --deps-only

# Build the project
dune build
```

### Your First Program

Create a file `hello.ly`:

```luoyan
让 「问候」 = "你好，世界！"
打印 「问候」
```

Run the program:

```bash
dune exec yyocamlc -- hello.ly
```

## Syntax Examples

### Variable Definition

```luoyan
让 「姓名」 = "李白"
让 「年龄」 = 30
让 「是学生」 = 假
```

### Function Definition

Modern style:
```luoyan
让 「加法」 = 函数 「甲」 -> 函数 「乙」 -> 「甲」 + 「乙」
```

Classical style:
```luoyan
夫「加法」者受 甲 乙 焉算法乃
  答 甲 加 乙
也
```

### Conditionals

```luoyan
如果 「年龄」 >= 18 那么
  打印 "成年人"
否则
  打印 "未成年人"
```

### Pattern Matching

Modern style:
```luoyan
匹配 「数字」 与
| 0 -> "零"
| 1 -> "一"
| _ -> "其他"
```

Classical style:
```luoyan
观「数字」之性
若 0 则 答 『零』
若 1 则 答 『一』
余者则 答 『其他』
观毕
```

### List Operations

```luoyan
让 「数组」 = 列开始 1 其一 2 其二 3 其三 列结束

递归 让 「求和」 = 函数 「lst」 ->
  观「lst」之性
  若 空空如也 则 答 0
  若 有首有尾 首名为「头」 尾名为「尾」 则
    答 「头」 + 「求和」 「尾」
  观毕
```

## Project Structure

```
chinese-ocaml/
├── src/              # Compiler source code
│   ├── lexer.ml     # Lexical analyzer
│   ├── parser.ml    # Parser
│   ├── ast.ml       # Abstract syntax tree
│   ├── semantic.ml  # Semantic analysis
│   └── codegen.ml   # Code generation
├── 标准库/           # Standard library
├── 示例/             # Example programs
├── test/            # Test cases
└── doc/             # Documentation
```

## Development Guide

### Running Tests

```bash
# Run all tests
dune runtest

# Run specific test
dune exec test/test_e2e.exe
```

### Building Documentation

```bash
dune build @doc
```

### Code Formatting

```bash
dune build @fmt --auto-promote
```

## Standard Library

Luoyan provides a rich standard library:

- **基础 (Basics)**: Basic types and operations
- **列表 (Lists)**: List manipulation functions
- **字符串 (Strings)**: String processing
- **数学 (Math)**: Mathematical functions
- **输入输出 (I/O)**: Input/output operations

## Roadmap

- [x] Basic syntax implementation
- [x] Classical Chinese syntax support
- [x] AI assistance features
- [x] Module system
- [ ] Complete standard library
- [ ] Package manager
- [ ] IDE support
- [ ] Self-hosting compiler

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Known Issues

- Issue #75: Lexer may have issues with full-width Unicode characters
- Issue #77: Classical pattern matching syntax fails to parse in certain cases

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

Thanks to all contributors for making Chinese programming more elegant and powerful.

---

*Luoyan - Programming in Chinese*