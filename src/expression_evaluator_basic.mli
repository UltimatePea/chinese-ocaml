(** 骆言基础表达式求值模块接口 - Chinese Programming Language Basic Expression Evaluator Interface *)

open Ast
open Unified_errors
open Value_operations

(** 评估函数类型 *)
type eval_expr_func = (string * runtime_value) list -> expr -> runtime_value result

(** 字面量求值 *)
val eval_literal : literal -> runtime_value result

(** 变量查找 *)
val eval_variable : (string * runtime_value) list -> string -> runtime_value result

(** 二元运算表达式求值 *)
val eval_binary_op : (string * runtime_value) list -> expr -> expr -> binary_op -> eval_expr_func -> runtime_value result

(** 一元运算表达式求值 *)
val eval_unary_op : (string * runtime_value) list -> expr -> unary_op -> eval_expr_func -> runtime_value result

(** 基本表达式求值 - 字面量、变量、运算符 *)
val eval_basic_expr : (string * runtime_value) list -> expr -> runtime_value result