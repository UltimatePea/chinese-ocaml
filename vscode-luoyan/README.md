# 骆言语言 VSCode 扩展

为骆言(Luoyan)中文编程语言提供的 Visual Studio Code 扩展，支持语法高亮、智能提示、代码片段等功能。

## 功能特性

### ✅ 已实现功能

- **语法高亮**: 完整的骆言语法高亮支持
  - 关键字高亮（现代语法、古雅体、文言文风格）
  - 字符串、数字、注释高亮
  - 运算符和标点符号高亮
  - 引用标识符（「标识符」）高亮

- **语言配置**: 
  - 自动括号闭合（包括中文括号）
  - 代码折叠支持
  - 智能缩进
  - 注释切换

- **代码片段**: 常用代码模板
  - 变量定义
  - 函数定义（现代语法和古雅体）
  - 条件判断
  - 模式匹配
  - Hello World模板

- **基础命令**:
  - 编译骆言文件 (`Ctrl+Shift+C`)
  - 运行骆言文件 (`Ctrl+Shift+R`)

- **悬停提示**: 关键字说明和文档

### 🚧 计划功能

- [ ] Language Server Protocol (LSP) 集成
- [ ] 智能代码补全
- [ ] 错误检查和诊断
- [ ] 跳转到定义
- [ ] 查找引用
- [ ] 重构支持
- [ ] 调试支持

## 安装

### 从源码安装

1. 克隆项目仓库：
```bash
git clone https://github.com/UltimatePea/chinese-ocaml.git
cd chinese-ocaml/vscode-luoyan
```

2. 安装依赖：
```bash
npm install
```

3. 编译扩展：
```bash
npm run compile
```

4. 打包扩展：
```bash
npm run package
```

5. 在 VSCode 中安装生成的 `.vsix` 文件

## 使用方法

### 文件扩展名

扩展支持以下文件扩展名：
- `.ly` - 标准骆言文件
- `.luoyan` - 完整扩展名
- `.骆言` - 中文扩展名

### 快捷键

- `Ctrl+Shift+C` (macOS: `Cmd+Shift+C`) - 编译当前文件
- `Ctrl+Shift+R` (macOS: `Cmd+Shift+R`) - 运行当前文件

### 代码片段

输入以下前缀并按 `Tab` 键：

- `设` - 变量定义
- `函数` - 现代函数定义
- `夫` - 古雅体函数定义
- `如果` - 条件判断
- `若` - 古雅体条件
- `观` - 模式匹配
- `打印` - 打印语句
- `hello` - Hello World程序
- `递归` - 递归函数模板

## 语法示例

### 现代语法
```luoyan
设 数字 为 42
设 问候 为 "你好，世界！"

函数 阶乘 数值 ->
  如果 数值 等于 0 那么
    1
  否则
    数值 * 阶乘 (数值 - 1)

打印 (阶乘 5)
```

### 古雅体语法
```luoyan
夫 阶乘 者 受 数值 焉 算法 乃
  若 数值 得 0 则
    答 1
  余者
    答 数值 乘 阶乘 得 数值 减 1
是谓

设 结果 为 阶乘 5
打印 结果
```

## 配置选项

在 VSCode 设置中可以配置以下选项：

- `luoyan.enableSyntaxHighlighting` - 启用语法高亮（默认：true）
- `luoyan.enableAutoClosing` - 启用自动闭合括号（默认：true）
- `luoyan.enableCodeFolding` - 启用代码折叠（默认：true）
- `luoyan.indentSize` - 缩进大小（默认：2）

## 贡献

欢迎贡献代码和建议！请参考：

1. [骆言项目主页](https://github.com/UltimatePea/chinese-ocaml)
2. [Issue 跟踪](https://github.com/UltimatePea/chinese-ocaml/issues)
3. [贡献指南](https://github.com/UltimatePea/chinese-ocaml/blob/main/CONTRIBUTING.md)

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 更新日志

### 0.1.0 (初始版本)

- ✅ 基础语法高亮支持
- ✅ 语言配置和自动闭合
- ✅ 代码片段库
- ✅ 基础编译和运行命令
- ✅ 关键字悬停提示

---

**骆言** - 为AI时代设计的中文编程语言