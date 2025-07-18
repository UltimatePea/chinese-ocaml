(** 骆言数据结构表达式求值模块接口 - Chinese Programming Language Data Structure Expression Evaluator Interface *)

open Ast
open Value_operations

type eval_expr_func = runtime_env -> expr -> runtime_value
(** 评估函数类型 *)

val eval_data_structure_expr : runtime_env -> eval_expr_func -> expr -> runtime_value
(** 数据结构表达式求值 - 记录、数组、元组 *)
