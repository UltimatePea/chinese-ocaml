(** 骆言C代码生成器操作表达式模块 - C Code Generator Operations Module *)

open Ast
open C_codegen_context
open Error_utils

(** 初始化模块日志器 *)
let[@warning "-32"] log_info = Logger_utils.init_info_logger "CCodegenOperations"

(** C函数模板映射表 - 优化版本，避免重复的Printf.sprintf调用 *)
let binary_op_func_map = function
  | Add -> "luoyan_add"
  | Sub -> "luoyan_subtract"
  | Mul -> "luoyan_multiply"
  | Div -> "luoyan_divide"
  | Mod -> "luoyan_modulo"
  | Eq -> "luoyan_equal"
  | Neq -> "luoyan_not_equal"
  | Lt -> "luoyan_less_than"
  | Gt -> "luoyan_greater_than"
  | Le -> "luoyan_less_equal"
  | Ge -> "luoyan_greater_equal"
  | And -> "luoyan_logical_and"
  | Or -> "luoyan_logical_or"
  | Concat -> "luoyan_concat"

(** 生成二元运算表达式代码 - 优化版本，使用模板系统 *)
let gen_binary_op gen_expr_fn ctx op e1 e2 =
  let e1_code = gen_expr_fn ctx e1 in
  let e2_code = gen_expr_fn ctx e2 in
  let func_name = binary_op_func_map op in
  Printf.sprintf "%s(%s, %s)" func_name e1_code e2_code

(** 一元运算符模板系统 *)
let unary_op_template = function
  | Neg -> ("luoyan_subtract", Some "luoyan_int(0)")
  | Not -> ("luoyan_logical_not", None)

(** 生成一元运算表达式代码 - 优化版本 *)
let gen_unary_op gen_expr_fn ctx op e =
  let e_code = gen_expr_fn ctx e in
  match unary_op_template op with
  | (func_name, Some prefix_arg) -> Printf.sprintf "%s(%s, %s)" func_name prefix_arg e_code
  | (func_name, None) -> Printf.sprintf "%s(%s)" func_name e_code

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

(** 生成引用表达式代码 - 优化版本 *)
let gen_ref_expr gen_expr_fn ctx expr =
  gen_single_arg_func gen_expr_fn ctx "luoyan_ref" expr

(** 生成解引用表达式代码 - 优化版本 *)
let gen_deref_expr gen_expr_fn ctx expr =
  gen_single_arg_func gen_expr_fn ctx "luoyan_deref" expr

(** 生成赋值表达式代码 - 优化版本 *)
let gen_assign_expr gen_expr_fn ctx ref_expr value_expr =
  gen_double_arg_func gen_expr_fn ctx "luoyan_assign" ref_expr value_expr

(** 生成内存和引用操作表达式代码 *)
let gen_memory_operations gen_expr_fn ctx expr =
  match expr with
  | RefExpr expr -> gen_ref_expr gen_expr_fn ctx expr
  | DerefExpr expr -> gen_deref_expr gen_expr_fn ctx expr
  | AssignExpr (ref_expr, value_expr) -> gen_assign_expr gen_expr_fn ctx ref_expr value_expr
  | _ -> fail_unsupported_expression_with_function "gen_memory_operations" MemoryOperations