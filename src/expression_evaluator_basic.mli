(** 骆言基础表达式求值模块接口 - Chinese Programming Language Basic Expression Evaluator Interface *)

open Ast
open Value_operations

type eval_expr_func = runtime_env -> expr -> runtime_value
(** 评估函数类型 *)

val eval_literal : literal -> runtime_value
(** 字面量求值 *)

val eval_basic_expr : runtime_env -> eval_expr_func -> expr -> runtime_value
(** 基本表达式求值 - 字面量、变量、运算符 *)
