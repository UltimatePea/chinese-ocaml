# 数组类型完整实现设计文档

## 概述

本文档描述了骆言编程语言中数组（Array）类型系统的完整实现。数组类型是一种可变的、固定长度的数据结构，所有元素具有相同类型，为程序提供高效的随机访问和原地修改能力。

## 设计目标

### 主要特性
1. **数组创建**: 使用中文语法创建固定长度的可变数组
2. **元素访问**: 通过索引语法访问数组元素
3. **元素更新**: 原地修改数组元素（可变语义）
4. **类型安全**: 完整的类型推断和类型检查
5. **边界检查**: 运行时边界检查防止越界访问
6. **错误处理**: 友好的中文错误消息

### AI优先设计考虑
- **类型统一**: 确保数组元素类型一致，避免类型错误
- **边界安全**: 自动边界检查，防止AI常见的越界错误
- **可变性**: 提供高效的原地更新操作
- **中文语法**: 符合骆言语言的中文特色

## 语法设计

### 数组创建语法
```luoyan
让 数字数组 = [|1; 2; 3; 4; 5|]
让 字符串数组 = [|"张三"; "李四"; "王五"|]
让 空数组 = [||]
```

### 元素访问语法
```luoyan
让 第一个 = 数字数组.(0)
让 最后一个 = 数字数组.(4)
```

### 元素更新语法
```luoyan
数字数组.(0) <- 10
字符串数组.(1) <- "赵六"
```

### 内置函数
```luoyan
让 长度 = 数组长度 数字数组
让 副本 = 复制数组 数字数组
让 新数组 = 创建数组 5 0  (* 创建长度为5的数组，初始值为0 *)
```

## 类型系统实现

### AST定义
数组相关的AST节点：
```ocaml
type expr =
  | ArrayExpr of expr list                         (* 数组字面量 *)
  | ArrayAccessExpr of expr * expr                 (* 数组访问 *)
  | ArrayUpdateExpr of expr * expr * expr          (* 数组更新 *)
```

### 类型表示
内部类型系统中的数组类型：
```ocaml
type typ =
  | ArrayType_T of typ                             (* 元素类型的数组 *)
```

### 运行时值
运行时数组值表示：
```ocaml
type runtime_value =
  | ArrayValue of runtime_value array              (* 可变数组 *)
```

## 类型推断实现

### 数组创建类型推断
对于非空数组：
1. 推断第一个元素的类型
2. 确保所有其他元素与第一个元素类型统一
3. 构造`ArrayType_T`类型

对于空数组：
1. 创建新的类型变量作为元素类型
2. 构造`ArrayType_T`类型

```ocaml
| ArrayExpr elements ->
  (match elements with
   | [] ->
     let elem_type = new_type_var () in
     (empty_subst, ArrayType_T elem_type)
   | first_elem :: rest_elems ->
     let (first_subst, first_type) = infer_type env first_elem in
     let env1 = apply_subst_to_env first_subst env in
     let infer_and_unify acc_subst elem =
       let current_env = apply_subst_to_env acc_subst env1 in
       let (elem_subst, elem_type) = infer_type current_env elem in
       let combined_subst = compose_subst acc_subst elem_subst in
       let unified_subst = unify (apply_subst combined_subst first_type)
                                (apply_subst combined_subst elem_type) in
       compose_subst combined_subst unified_subst
     in
     let final_subst = List.fold_left infer_and_unify first_subst rest_elems in
     let final_elem_type = apply_subst final_subst first_type in
     (final_subst, ArrayType_T final_elem_type))
```

### 数组访问类型推断
1. 推断数组表达式的类型
2. 推断索引表达式的类型
3. 确保索引类型为整数
4. 从数组类型中提取元素类型

```ocaml
| ArrayAccessExpr (array_expr, index_expr) ->
  let (subst1, array_type) = infer_type env array_expr in
  let env1 = apply_subst_to_env subst1 env in
  let (subst2, index_type) = infer_type env1 index_expr in
  let subst3 = unify (apply_subst subst2 index_type) IntType_T in
  let combined_subst = compose_subst (compose_subst subst1 subst2) subst3 in
  let elem_type = new_type_var () in
  let expected_array_type = ArrayType_T elem_type in
  let subst4 = unify (apply_subst combined_subst array_type) expected_array_type in
  let final_subst = compose_subst combined_subst subst4 in
  (final_subst, apply_subst final_subst elem_type)
```

### 数组更新类型推断
1. 推断数组、索引和值表达式的类型
2. 确保索引类型为整数
3. 确保值类型与数组元素类型匹配
4. 返回单元类型（副作用操作）

```ocaml
| ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
  let (subst1, array_type) = infer_type env array_expr in
  let env1 = apply_subst_to_env subst1 env in
  let (subst2, index_type) = infer_type env1 index_expr in
  let env2 = apply_subst_to_env subst2 env1 in
  let (subst3, value_type) = infer_type env2 value_expr in
  let subst4 = unify (apply_subst subst3 index_type) IntType_T in
  let combined_subst = compose_subst (compose_subst (compose_subst subst1 subst2) subst3) subst4 in
  let elem_type = new_type_var () in
  let expected_array_type = ArrayType_T elem_type in
  let subst5 = unify (apply_subst combined_subst array_type) expected_array_type in
  let subst6 = unify (apply_subst (compose_subst combined_subst subst5) value_type)
                     (apply_subst (compose_subst combined_subst subst5) elem_type) in
  let final_subst = compose_subst (compose_subst combined_subst subst5) subst6 in
  (final_subst, UnitType_T)
```

## 类型统一实现

### 数组类型统一
数组类型的统一只需要统一元素类型：

```ocaml
| (ArrayType_T elem1, ArrayType_T elem2) ->
  unify elem1 elem2
```

## 运行时实现

### 数组创建评估
```ocaml
| ArrayExpr elements ->
  let values = List.map (eval_expr env) elements in
  ArrayValue (Array.of_list values)
```

### 数组访问评估
```ocaml
| ArrayAccessExpr (array_expr, index_expr) ->
  let array_val = eval_expr env array_expr in
  let index_val = eval_expr env index_expr in
  (match (array_val, index_val) with
   | (ArrayValue arr, IntValue idx) ->
     if idx >= 0 && idx < Array.length arr then
       arr.(idx)
     else
       raise (RuntimeError (Printf.sprintf "数组索引越界: %d" idx))
   | (ArrayValue _, _) -> raise (RuntimeError "数组索引必须是整数")
   | _ -> raise (RuntimeError "期望数组类型"))
```

### 数组更新评估
```ocaml
| ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
  let array_val = eval_expr env array_expr in
  let index_val = eval_expr env index_expr in
  let new_val = eval_expr env value_expr in
  (match (array_val, index_val) with
   | (ArrayValue arr, IntValue idx) ->
     if idx >= 0 && idx < Array.length arr then (
       arr.(idx) <- new_val;
       UnitValue
     ) else
       raise (RuntimeError (Printf.sprintf "数组索引越界: %d" idx))
   | (ArrayValue _, _) -> raise (RuntimeError "数组索引必须是整数")
   | _ -> raise (RuntimeError "期望数组类型"))
```

## 内置函数实现

### 数组长度
```ocaml
| "数组长度" ->
  (match args with
   | [ArrayValue arr] -> IntValue (Array.length arr)
   | _ -> raise (RuntimeError "数组长度函数期望一个数组参数"))
```

### 复制数组
```ocaml
| "复制数组" ->
  (match args with
   | [ArrayValue arr] -> ArrayValue (Array.copy arr)
   | _ -> raise (RuntimeError "复制数组函数期望一个数组参数"))
```

### 创建数组
```ocaml
| "创建数组" ->
  (match args with
   | [IntValue size; init_val] ->
     if size >= 0 then
       ArrayValue (Array.make size init_val)
     else
       raise (RuntimeError "数组大小必须非负")
   | _ -> raise (RuntimeError "创建数组函数期望大小和初始值参数"))
```

## 错误处理设计

### 类型错误
1. **元素类型不匹配**: 数组元素类型不统一时的错误
2. **索引类型错误**: 使用非整数索引时的错误
3. **类型统一失败**: 数组类型无法统一时的错误

### 运行时错误
1. **数组越界**: "数组索引越界: {索引}"
2. **索引类型错误**: "数组索引必须是整数"
3. **类型错误**: "期望数组类型"
4. **负数大小**: "数组大小必须非负"

## 测试覆盖

### 基础功能测试
- 数组字面量创建
- 元素访问和更新
- 内置函数（长度、复制、创建）

### 高级功能测试
- 嵌套数组处理
- 不同类型元素的数组

### 错误处理测试
- 数组越界访问和更新
- 负索引访问
- 非整数索引使用

## 性能考虑

### 内存效率
- 使用OCaml原生数组，内存连续
- 原地更新操作，避免复制开销

### 时间复杂度
- 元素访问: O(1)
- 元素更新: O(1)
- 数组创建: O(n) 其中n是元素数量
- 边界检查: O(1)

## 与函数式特性的平衡

### 可变性设计
数组提供可变性，与骆言语言的函数式特性形成补充：

1. **明确的可变操作**: 更新操作返回单元类型，明确副作用
2. **不可变选择**: 提供复制函数支持不可变风格
3. **类型安全**: 完整的类型检查防止类型错误

### 函数式操作支持
```luoyan
(* 不可变风格 *)
让 新数组 = 复制数组 原数组
新数组.(0) <- 新值

(* 函数式映射 *)
让 映射数组 = 函数 f arr ->
  让 结果 = 复制数组 arr 在
  (* 使用循环应用函数f到每个元素 *)
  结果
```

## 未来扩展方向

### 短期改进
1. **数组模式匹配**: 在模式匹配中支持数组解构
2. **数组切片**: 支持子数组操作
3. **多维数组**: 支持多维数组语法

### 长期规划
1. **并行数组操作**: 支持并行映射和归约
2. **类型化数组**: 支持固定长度类型信息
3. **数组视图**: 支持数组切片视图

## 结论

数组类型的完整实现为骆言语言提供了高效的可变数据结构。该实现：

1. **类型安全**: 完整的类型推断和边界检查
2. **性能高效**: O(1)访问和更新操作
3. **错误安全**: 运行时边界检查和友好错误消息
4. **平衡设计**: 在函数式语言中提供必要的可变性

数组类型的成功实现与记录类型一起，为骆言语言提供了完整的数据结构支持，满足了从函数式编程到高性能计算的各种需求。