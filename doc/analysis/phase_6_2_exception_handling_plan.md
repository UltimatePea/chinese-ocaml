# 🔧 Phase 6.2: 异常处理现代化实施计划

**实施日期**: 2025-07-27  
**负责代理**: Charlie, 规划代理  
**父issue**: #1480 Phase 6.0 技术债务系统性改进

## 📊 实际failwith使用分析

经过代码库扫描，发现以下需要现代化的failwith使用：

### 🎯 **高优先级模块**

#### 1. **Poetry模块** (4处failwith)
- `/src/poetry/poetry_rhyme_data.ml`:
  - Line 320: `failwith ("重复字符: " ^ str)`
  - Line 363: `failwith ("文件加载失败: " ^ msg)`
  - Line 364: `failwith "数据解析失败"`
  - Line 373: `failwith ("文件保存失败: " ^ msg)`

- `/src/poetry/poetry_data_loader.ml`:
  - Line 46: `failwith "Unmatched bracket"`

- `/src/poetry/artistic_data_loader.ml`:
  - Line 41: `failwith "Unmatched bracket"`

#### 2. **Token系统剩余** (2处failwith)
- `/src/token_unified.ml`:
  - Line 160: `failwith "Not a literal token"`
  - Line 169: `failwith "Not an identifier token"`

#### 3. **Builtin Error模块** (3处failwith)
- `/src/builtin_error.ml`:
  - Line 49: `failwith "param_error"`
  - Line 58: `failwith "param_error"`
  - Line 67: `failwith "param_error"`

### 🟡 **中优先级模块**

#### 4. **Legacy转换器** (1处failwith)
- `/src/lexer_token_converter.ml`:
  - Line 290: `failwith error_msg` (错误传播)

#### 5. **弃用函数** (3处故意failwith)
- `/src/unified_logger.ml:184`: 已弃用函数
- `/src/logging/log_legacy.ml:23`: 已弃用函数  
- `/src/utils/formatting/string_utils.ml:9`: 已弃用函数

#### 6. **测试基础设施** (1处failwith)
- `/src/performance/benchmark_core.ml:88`: 抽象方法placeholder

## 🎯 **实施策略**

### **阶段1**: Poetry模块现代化 (优先级P0)
Poetry模块的failwith使用影响诗词处理稳定性，需要立即处理。

#### **目标转换模式**:
```ocaml
(* 当前模式 *)
failwith ("重复字符: " ^ str)

(* 目标模式 *)
Error (PoetryError.DuplicateCharacter { char = str; context = "韵律数据加载" })
```

### **阶段2**: Token系统补完 (优先级P1)
Token系统中剩余的failwith需要迁移到统一错误处理。

#### **目标转换模式**:
```ocaml
(* 当前模式 *)
failwith "Not a literal token"

(* 目标模式 *)  
Error (TokenError.InvalidTokenType { expected = "Literal"; actual = token_type })
```

### **阶段3**: Builtin Error重构 (优先级P1)
参数验证逻辑需要现代化。

#### **目标转换模式**:
```ocaml
(* 当前模式 *)
match args with [ arg ] -> arg | _ -> failwith "param_error"

(* 目标模式 *)
match args with 
| [ arg ] -> Ok arg 
| _ -> Error (BuiltinError.InvalidParameterCount { expected = 1; actual = List.length args })
```

### **阶段4**: Legacy模块清理 (优先级P2)
处理转换器和弃用函数中的failwith。

## 📋 **具体实施步骤**

### **Step 1: Poetry错误类型定义**
1. 创建 `src/poetry/poetry_errors.ml`
2. 定义统一的Poetry错误类型
3. 实现错误消息格式化

### **Step 2: Poetry模块迁移**
1. 迁移 `poetry_rhyme_data.ml` 中的4处failwith
2. 迁移 `poetry_data_loader.ml` 中的1处failwith
3. 迁移 `artistic_data_loader.ml` 中的1处failwith
4. 更新所有调用方的错误处理

### **Step 3: Token模块补完**
1. 迁移 `token_unified.ml` 中的2处failwith
2. 使用现有的Token错误处理系统

### **Step 4: Builtin Error重构**
1. 重构参数验证逻辑
2. 使用Result类型返回
3. 更新调用方

### **Step 5: Legacy清理**
1. 保留弃用函数的failwith（这是预期行为）
2. 修复 `lexer_token_converter.ml` 的错误传播
3. 改进 `benchmark_core.ml` 的抽象方法设计

## ⚡ **验证和测试**

### **测试覆盖计划**
1. **单元测试**: 每个转换的模块都要有对应的错误处理测试
2. **集成测试**: 验证错误消息正确传播到调用方
3. **回归测试**: 确保现有功能行为不变

### **错误处理质量保证**
1. 错误消息要提供足够的上下文信息
2. 错误类型要便于调用方处理
3. 保持与现有错误处理系统的一致性

## 🚀 **预期收益**

### **稳定性提升**
- 消除Poetry模块的意外崩溃风险
- 提供更好的错误恢复机制
- 改善调试体验

### **代码质量改进**
- 统一错误处理模式
- 提高代码可预测性
- 减少技术债务

### **开发效率提升**
- 更清晰的错误信息
- 更容易的错误处理逻辑
- 更好的IDE支持

## 📊 **成功指标**

- ✅ 所有Poetry模块failwith迁移完成
- ✅ 所有Token系统failwith迁移完成  
- ✅ 所有测试通过
- ✅ 无功能回归
- ✅ 错误消息质量提升

---

**Author**: Charlie, 规划代理

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>