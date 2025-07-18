(** 骆言C代码生成器操作表达式模块 - C Code Generator Operations Module *)

open Ast
open C_codegen_context
open Error_utils

(** 初始化模块日志器 *)
let log_info = Logger_utils.init_info_logger "CCodegenOperations"

(** 生成二元运算表达式代码 *)
let gen_binary_op gen_expr_fn ctx op e1 e2 =
  let e1_code = gen_expr_fn ctx e1 in
  let e2_code = gen_expr_fn ctx e2 in
  match op with
  | Add -> Printf.sprintf "luoyan_add(%s, %s)" e1_code e2_code
  | Sub -> Printf.sprintf "luoyan_subtract(%s, %s)" e1_code e2_code
  | Mul -> Printf.sprintf "luoyan_multiply(%s, %s)" e1_code e2_code
  | Div -> Printf.sprintf "luoyan_divide(%s, %s)" e1_code e2_code
  | Mod -> Printf.sprintf "luoyan_modulo(%s, %s)" e1_code e2_code
  | Eq -> Printf.sprintf "luoyan_equal(%s, %s)" e1_code e2_code
  | Neq -> Printf.sprintf "luoyan_not_equal(%s, %s)" e1_code e2_code
  | Lt -> Printf.sprintf "luoyan_less_than(%s, %s)" e1_code e2_code
  | Gt -> Printf.sprintf "luoyan_greater_than(%s, %s)" e1_code e2_code
  | Le -> Printf.sprintf "luoyan_less_equal(%s, %s)" e1_code e2_code
  | Ge -> Printf.sprintf "luoyan_greater_equal(%s, %s)" e1_code e2_code
  | And -> Printf.sprintf "luoyan_logical_and(%s, %s)" e1_code e2_code
  | Or -> Printf.sprintf "luoyan_logical_or(%s, %s)" e1_code e2_code
  | Concat -> Printf.sprintf "luoyan_concat(%s, %s)" e1_code e2_code

(** 生成一元运算表达式代码 *)
let gen_unary_op gen_expr_fn ctx op e =
  let e_code = gen_expr_fn ctx e in
  match op with
  | Neg -> Printf.sprintf "luoyan_subtract(luoyan_int(0), %s)" e_code
  | Not -> Printf.sprintf "luoyan_logical_not(%s)" e_code

(** 生成算术和逻辑运算表达式代码 *)
let gen_operations gen_expr_fn ctx expr =
  match expr with
  | BinaryOpExpr (e1, op, e2) -> gen_binary_op gen_expr_fn ctx op e1 e2
  | UnaryOpExpr (op, e) -> gen_unary_op gen_expr_fn ctx op e
  | _ -> fail_unsupported_expression_with_function "gen_operations" Operations

(** 生成引用表达式代码 *)
let gen_ref_expr gen_expr_fn ctx expr =
  let expr_code = gen_expr_fn ctx expr in
  Printf.sprintf "luoyan_ref(%s)" expr_code

(** 生成解引用表达式代码 *)
let gen_deref_expr gen_expr_fn ctx expr =
  let expr_code = gen_expr_fn ctx expr in
  Printf.sprintf "luoyan_deref(%s)" expr_code

(** 生成赋值表达式代码 *)
let gen_assign_expr gen_expr_fn ctx ref_expr value_expr =
  let ref_code = gen_expr_fn ctx ref_expr in
  let value_code = gen_expr_fn ctx value_expr in
  Printf.sprintf "luoyan_assign(%s, %s)" ref_code value_code

(** 生成内存和引用操作表达式代码 *)
let gen_memory_operations gen_expr_fn ctx expr =
  match expr with
  | RefExpr expr -> gen_ref_expr gen_expr_fn ctx expr
  | DerefExpr expr -> gen_deref_expr gen_expr_fn ctx expr
  | AssignExpr (ref_expr, value_expr) -> gen_assign_expr gen_expr_fn ctx ref_expr value_expr
  | _ -> fail_unsupported_expression_with_function "gen_memory_operations" MemoryOperations