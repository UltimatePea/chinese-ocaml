# 骆言编译器测试质量标准

Author: Alpha, 主工作代理  
Date: 2025-07-29  
Version: 1.0

## 概述

本文档定义骆言编译器项目的测试质量标准，确保测试用例提供真实价值并有效保护代码质量。

## 测试优先级分级

### 优先级1: 核心业务逻辑模块 🔴

这些模块直接影响编译器功能正确性，必须有全面深入的测试：

- `interpreter.ml` - 解释器核心执行逻辑
- `semantic_analyzer.ml` - 语义分析和类型检查
- `parser.ml` - 语法解析器
- `lexer.ml` - 词法分析器
- `ast.ml` - 抽象语法树操作
- `types.ml` - 类型系统核心

**测试要求**:
- ✅ 必须包含正常业务场景测试
- ✅ 必须包含边界条件测试
- ✅ 必须包含错误处理测试
- ✅ 必须包含中文语法特定测试
- ✅ 覆盖率目标: 80%+
- ✅ 必须有集成测试验证

### 优先级2: 数据处理模块 🟡

这些模块处理重要数据结构和算法，需要重点测试：

- `poetry_analyzer.ml` - 诗词分析逻辑
- `rhyme_core.ml` - 韵律处理核心
- `unicode_utils.ml` - Unicode字符处理
- `builtin_functions.ml` - 内置函数实现

**测试要求**:
- ✅ 必须测试核心算法正确性
- ✅ 必须包含数据边界测试
- ✅ 必须包含Unicode兼容性测试
- ✅ 覆盖率目标: 60%+
- ✅ 关键路径必须有单元测试

### 优先级3: 工具和格式化模块 🟢

这些模块提供辅助功能，基础测试即可：

- `formatter_*.ml` - 各类格式化器
- `logger.ml` - 日志系统
- `config.ml` - 配置管理
- `utils.ml` - 通用工具函数

**测试要求**:
- ✅ 基础功能验证即可
- ✅ 主要API调用测试
- ✅ 覆盖率目标: 30%+
- ✅ 重点测试公共接口

## 测试质量标准

### 有效测试的特征

#### ✅ 好的测试示例
```ocaml
(* 测试复杂业务逻辑 *)
let test_semantic_type_inference () =
  let ast = Binary(Add, IntLit(5), IntLit(3)) in
  let result = analyze_expression ast empty_env in
  check (result "type") "加法表达式类型推断" IntType result.expr_type;
  check (result "value") "加法表达式求值" (Some 8) result.computed_value

(* 测试边界条件 *)
let test_division_by_zero () =
  let ast = Binary(Div, IntLit(10), IntLit(0)) in
  check_raises "除零异常" (fun () -> evaluate_expression ast empty_env)

(* 测试中文语法特定功能 *)
let test_chinese_variable_binding () =
  let code = "让 「计数器」 = 42" in
  let ast = parse_statement code in
  let env = execute_statement ast empty_env in
  check int "中文变量绑定" 42 (lookup_variable env "计数器")
```

#### ❌ 低价值测试示例
```ocaml
(* 过于简单的字符串拼接测试 *)
let test_format_identifier () =
  check string "标识符格式化" "「test」" (format_identifier "test")
  (* 这种测试价值有限，因为只验证简单字符串拼接 *)
```

### 测试覆盖要求

#### 功能覆盖
- **正常路径**: 所有主要功能的预期使用场景
- **边界条件**: 空值、最大值、最小值、极端情况
- **错误处理**: 非法输入、系统错误、资源不足
- **中文特性**: Unicode处理、中文语法、古文模式

#### 代码覆盖
- **优先级1模块**: 目标80%+行覆盖率
- **优先级2模块**: 目标60%+行覆盖率  
- **优先级3模块**: 目标30%+行覆盖率
- **关键路径**: 100%覆盖所有核心执行路径

## 测试组织规范

### 目录结构
```
test/
├── unit/           # 单元测试
│   ├── core/       # 核心模块测试
│   ├── poetry/     # 诗词功能测试
│   └── utils/      # 工具函数测试
├── integration/    # 集成测试
├── performance/    # 性能测试
└── fixtures/       # 测试数据
```

### 文件命名约定
- 单元测试: `test_[module_name]_[test_purpose].ml`
- 集成测试: `integration_[feature_name].ml`
- 性能测试: `perf_[module_name].ml`

### 测试用例命名
- 功能测试: `test_[function_name]_[scenario]`
- 边界测试: `test_[function_name]_boundary_[condition]`
- 错误测试: `test_[function_name]_error_[error_type]`

## 代码审查检查点

### PR提交要求
- [ ] 说明新增测试的业务价值
- [ ] 提供覆盖率变化报告
- [ ] 确保所有新测试通过
- [ ] 确认测试覆盖核心业务路径

### 审查重点
1. **测试价值评估**: 测试是否验证重要业务逻辑？
2. **覆盖完整性**: 是否覆盖正常、边界、错误场景？
3. **中文兼容性**: 是否测试中文和Unicode处理？
4. **维护成本**: 测试是否易于理解和维护？

## 测试工具和基础设施

### 测试框架
- **单元测试**: Alcotest框架
- **覆盖率**: bisect_ppx工具
- **性能测试**: OCaml benchmarking工具

### CI/CD集成
- 所有测试必须在CI中通过
- 覆盖率报告自动生成
- 性能回归检测
- 中文字符处理验证

## 质量指标

### 项目级别指标
- **整体覆盖率**: 目标50%+ (当前: ~22%)
- **核心模块覆盖率**: 目标80%+
- **测试通过率**: 必须100%
- **CI成功率**: 目标95%+

### 模块级别指标
- **单元测试数量**: 每个公共函数至少1个测试
- **集成测试**: 每个主要功能至少1个端到端测试
- **性能测试**: 关键算法必须有性能基准

## 实施计划

### 阶段1: 核心模块测试建设 (2周)
- [ ] interpreter.ml 深度测试
- [ ] semantic_analyzer.ml 全面测试
- [ ] ast.ml 和 types.ml 核心测试

### 阶段2: 数据处理模块 (2周)  
- [ ] poetry_analyzer.ml 诗词逻辑测试
- [ ] rhyme_core.ml 韵律算法测试
- [ ] unicode_utils.ml Unicode处理测试

### 阶段3: 测试基础设施完善 (1周)
- [ ] 自动化覆盖率报告
- [ ] 性能回归检测
- [ ] 测试文档和示例

## 总结

本标准旨在确保骆言编译器的测试体系：
1. **重点突出**: 优先保护核心业务逻辑
2. **质量优先**: 注重测试实际价值而非数量
3. **持续改进**: 建立可持续的质量改进机制
4. **中文特色**: 重视中文编程语言的特殊需求

遵循这些标准将帮助我们构建可靠、高质量的骆言编译器。

---
*本文档将根据项目发展持续更新。如有建议请提交Issue讨论。*