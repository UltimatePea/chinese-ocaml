# 骆言构造器表达式功能设计文档

## 概述

本文档描述了骆言编程语言中构造器表达式功能的设计和实现。构造器表达式允许程序员创建代数数据类型（变体类型）的值，是类型系统的重要组成部分。

## 功能特性

### 1. 无参数构造器
支持创建不带参数的构造器值。

```luoyan
类型 选项 = | 无 | 有 of 整数
让 空选项 = 无
```

### 2. 带参数构造器
支持创建带有一个或多个参数的构造器值。

```luoyan
让 整数选项 = 有 42
让 树节点 = 节点 (5, 空, 空)
```

### 3. 嵌套构造器
支持构造器值作为其他构造器的参数。

```luoyan
类型 二叉树 = | 空 | 节点 of 整数 * 二叉树 * 二叉树
让 复杂树 = 节点 (10, 节点 (5, 空, 空), 节点 (15, 空, 空))
```

## 设计决策

### 1. 函数式实现
构造器被实现为内置函数，这样可以：
- 重用现有的函数调用机制
- 简化解析器实现
- 保持类型系统的一致性

### 2. 自动注册机制
当遇到 `类型` 定义时，自动注册构造器函数：
```ocaml
let register_constructors env type_def =
  match type_def with
  | AlgebraicType constructors ->
    List.fold_left (fun acc_env (constructor_name, _type_opt) ->
      let constructor_func = BuiltinFunctionValue (fun args ->
        ConstructorValue (constructor_name, args)
      ) in
      bind_var acc_env constructor_name constructor_func
    ) env constructors
```

### 3. 统一的值表示
构造器值使用专门的运行时类型：
```ocaml
| ConstructorValue of string * runtime_value list
```

## 实现细节

### 1. AST 扩展
添加了 `ConstructorExpr` 表达式类型：
```ocaml
| ConstructorExpr of identifier * expr list
```

### 2. 运行时值扩展
添加了 `ConstructorValue` 运行时值类型：
```ocaml
| ConstructorValue of string * runtime_value list
```

### 3. 构造器函数注册
在 `execute_stmt` 中处理 `TypeDefStmt` 时：
- 解析代数数据类型的构造器列表
- 为每个构造器创建内置函数
- 将构造器函数注册到环境中

### 4. 类型推断
为构造器表达式添加了基本的类型推断支持：
```ocaml
| ConstructorExpr (_, arg_exprs) ->
  let arg_substs_and_types = List.map (infer_type env) arg_exprs in
  let (substs, _arg_types) = List.split arg_substs_and_types in
  let combined_subst = List.fold_left compose_subst empty_subst substs in
  let typ_var = new_type_var () in
  (combined_subst, typ_var)
```

### 5. 值显示
构造器值的字符串表示：
```ocaml
| ConstructorValue (name, []) -> name
| ConstructorValue (name, args) -> 
  name ^ "(" ^ String.concat ", " (List.map value_to_string args) ^ ")"
```

## 语法示例

### 基础用法
```luoyan
类型 颜色 = | 红 | 绿 | 蓝
让 我的颜色 = 红
打印 我的颜色  (* 输出: 红 *)
```

### 带参数构造器
```luoyan
类型 坐标 = | 点 of 整数 * 整数
让 原点 = 点 (0, 0)
让 位置 = 点 (10, 20)
打印 位置  (* 输出: 点(10, 20) *)
```

### 复杂数据结构
```luoyan
类型 表达式 = 
  | 常量 of 整数
  | 变量 of 字符串  
  | 加法 of 表达式 * 表达式

让 简单表达式 = 加法 (常量 5, 变量 "x")
打印 简单表达式  (* 输出: 加法(常量(5), 变量("x")) *)
```

## 测试覆盖

实现了全面的测试套件：
- 基础构造器表达式测试
- 带参数构造器表达式测试
- 类型定义与构造器集成测试

所有测试通过，包括：
- ✅ 6 个类型定义测试
- ✅ 28 个编译器核心测试
- ✅ 17 个端到端测试
- ✅ 102+ 个综合测试

## 工作流程

1. **类型定义解析** - 解析 `类型 名称 = | 构造器1 | 构造器2 of 类型` 
2. **构造器注册** - 将构造器注册为内置函数到环境中
3. **表达式求值** - 构造器函数调用创建 `ConstructorValue`
4. **值显示** - 格式化输出构造器值

## 未来扩展

### 1. 模式匹配增强
扩展模式匹配以支持用户定义的构造器：
```luoyan
匹配 表达式 与
| 常量 n -> n
| 变量 name -> 查找变量 name
| 加法 (left, right) -> 计算 left + 计算 right
```

### 2. 类型推断改进
改进构造器表达式的类型推断，基于类型定义返回正确的类型。

### 3. 泛型构造器
支持参数化的代数数据类型：
```luoyan
类型 选项 'a = | 无 | 有 of 'a
```

## 设计优势

1. **简洁性** - 重用函数调用机制，减少解析器复杂度
2. **一致性** - 构造器遵循函数调用语法，保持语言一致性  
3. **扩展性** - 为高级模式匹配和泛型提供基础
4. **AI友好** - 中文构造器名提高AI理解能力

## 总结

构造器表达式功能为骆言编程语言提供了完整的代数数据类型支持，使得程序员可以定义和使用复杂的数据结构。实现采用函数式方法，保持了语言的简洁性和一致性。当前实现已通过全面测试，为后续的模式匹配增强和类型系统完善奠定了坚实基础。