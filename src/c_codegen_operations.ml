(** 骆言C代码生成器操作表达式模块 - C Code Generator Operations Module *)

open Ast
open Error_utils
open Constants


(** C函数模板映射表 - 优化版本，使用常量定义避免硬编码 *)
let binary_op_func_map = function
  | Add -> RuntimeFunctions.add
  | Sub -> RuntimeFunctions.subtract
  | Mul -> RuntimeFunctions.multiply
  | Div -> RuntimeFunctions.divide
  | Mod -> RuntimeFunctions.modulo
  | Eq -> RuntimeFunctions.equal
  | Neq -> RuntimeFunctions.not_equal
  | Lt -> RuntimeFunctions.less_than
  | Gt -> RuntimeFunctions.greater_than
  | Le -> RuntimeFunctions.less_equal
  | Ge -> RuntimeFunctions.greater_equal
  | And -> RuntimeFunctions.logical_and
  | Or -> RuntimeFunctions.logical_or
  | Concat -> RuntimeFunctions.concat

(** 生成二元运算表达式代码 - 优化版本，使用模板系统 *)
let gen_binary_op gen_expr_fn ctx op e1 e2 =
  let e1_code = gen_expr_fn ctx e1 in
  let e2_code = gen_expr_fn ctx e2 in
  let func_name = binary_op_func_map op in
  Printf.sprintf "%s(%s, %s)" func_name e1_code e2_code

(** 一元运算符模板系统 - 使用常量定义避免硬编码 *)
let unary_op_template = function
  | Neg -> (RuntimeFunctions.subtract, Some RuntimeFunctions.int_zero)
  | Not -> (RuntimeFunctions.logical_not, None)

(** 生成一元运算表达式代码 - 优化版本 *)
let gen_unary_op gen_expr_fn ctx op e =
  let e_code = gen_expr_fn ctx e in
  match unary_op_template op with
  | func_name, Some prefix_arg -> Printf.sprintf "%s(%s, %s)" func_name prefix_arg e_code
  | func_name, None -> Printf.sprintf "%s(%s)" func_name e_code

(** 生成算术和逻辑运算表达式代码 *)
let gen_operations gen_expr_fn ctx expr =
  match expr with
  | BinaryOpExpr (e1, op, e2) -> gen_binary_op gen_expr_fn ctx op e1 e2
  | UnaryOpExpr (op, e) -> gen_unary_op gen_expr_fn ctx op e
  | _ -> fail_unsupported_expression_with_function "gen_operations" Operations

(** 通用单参数函数代码生成器 *)
let gen_single_arg_func gen_expr_fn ctx func_name expr =
  let expr_code = gen_expr_fn ctx expr in
  Printf.sprintf "%s(%s)" func_name expr_code

(** 通用双参数函数代码生成器 *)
let gen_double_arg_func gen_expr_fn ctx func_name expr1 expr2 =
  let expr1_code = gen_expr_fn ctx expr1 in
  let expr2_code = gen_expr_fn ctx expr2 in
  Printf.sprintf "%s(%s, %s)" func_name expr1_code expr2_code

(** 生成引用表达式代码 - 优化版本，使用常量定义避免硬编码 *)
let gen_ref_expr gen_expr_fn ctx expr = gen_single_arg_func gen_expr_fn ctx RuntimeFunctions.ref_create expr

(** 生成解引用表达式代码 - 优化版本，使用常量定义避免硬编码 *)
let gen_deref_expr gen_expr_fn ctx expr = gen_single_arg_func gen_expr_fn ctx RuntimeFunctions.deref expr

(** 生成赋值表达式代码 - 优化版本，使用常量定义避免硬编码 *)
let gen_assign_expr gen_expr_fn ctx ref_expr value_expr =
  gen_double_arg_func gen_expr_fn ctx RuntimeFunctions.assign ref_expr value_expr

(** 生成内存和引用操作表达式代码 *)
let gen_memory_operations gen_expr_fn ctx expr =
  match expr with
  | RefExpr expr -> gen_ref_expr gen_expr_fn ctx expr
  | DerefExpr expr -> gen_deref_expr gen_expr_fn ctx expr
  | AssignExpr (ref_expr, value_expr) -> gen_assign_expr gen_expr_fn ctx ref_expr value_expr
  | _ -> fail_unsupported_expression_with_function "gen_memory_operations" MemoryOperations
