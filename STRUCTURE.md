# 骆言编程语言项目结构

这个文档描述了骆言编程语言项目的目录结构和组织方式。

## 核心目录结构

```
chinese-ocaml/
├── src/                    # 主编译器源代码
│   ├── main.ml            # 编译器主程序
│   ├── lexer.ml           # 词法分析器
│   ├── parser.ml          # 语法分析器
│   ├── semantic.ml        # 语义分析器
│   ├── codegen.ml         # 代码生成器
│   ├── c_codegen.ml       # C后端代码生成器
│   └── ast.ml             # 抽象语法树定义
├── test/                   # 测试文件
│   ├── test_*.ml          # OCaml测试模块
│   ├── test_files/        # 测试用的源代码文件
│   ├── bootstrap/         # 自举相关测试
│   └── temp_files/        # 临时测试文件
├── examples/               # 示例程序
│   └── *.luoyan           # 骆言语言示例
├── doc/                    # 项目文档
│   ├── design/            # 设计文档
│   ├── change_log/        # 变更日志
│   └── notes/             # 开发笔记
├── bootstrap/              # 自举编译器
│   ├── legacy/            # C语言编写的早期编译器
│   └── experimental/      # 骆言语言编写的自举编译器
├── 骆言编译器/             # 结构化的骆言编译器实现
├── c_backend/              # C语言后端支持
│   ├── runtime/           # 运行时库
│   └── tests/             # C后端测试
├── benchmarks/             # 性能基准测试
└── temp/                   # 临时文件和遗留产物
```

## 目录详细说明

### `/src/` - 主编译器
正式的编译器实现，使用OCaml编写：
- 完整的词法、语法、语义分析
- 代码生成和C后端支持
- 模块化设计便于扩展

### `/test/` - 测试系统
全面的测试覆盖：
- 单元测试和集成测试
- 端到端功能验证
- 性能和错误恢复测试

### `/examples/` - 示例程序
展示语言特性的示例代码：
- 基础语法演示
- 高级特性展示
- 实际应用案例

### `/doc/` - 文档系统
完整的项目文档：
- 设计规范和架构文档
- 开发日志和变更记录
- 使用指南和API文档

### `/bootstrap/` - 自举支持
展示语言自举能力：
- C语言编写的引导编译器
- 骆言语言编写的自举编译器

### `/benchmarks/` - 性能测试
性能评估和优化：
- 微基准测试
- 应用级性能测试
- 与其他语言的对比

## 构建和使用

1. **构建编译器**: `dune build`
2. **运行测试**: `dune runtest`
3. **编译程序**: `dune exec yyocamlc -- file.luoyan`
4. **生成C代码**: `dune exec yyocamlc -- -c file.luoyan`

## 贡献指南

- 新功能开发参考 `/doc/design/` 中的设计文档
- 添加测试到 `/test/` 目录
- 示例代码放在 `/examples/` 目录
- 文档更新遵循现有的编号和分类体系

## 相关文档

- [AGENTS.md](AGENTS.md) - 协作开发指南
- [CLAUDE.md](CLAUDE.md) - Claude Code配置
- [README.md](README.md) - 项目概述