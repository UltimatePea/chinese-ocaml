(** 骆言控制流表达式求值模块接口 - Chinese Programming Language Control Flow Expression Evaluator Interface *)

open Ast
open Value_operations

type eval_expr_func = runtime_env -> expr -> runtime_value
(** 评估函数类型 *)

val eval_control_flow_expr : runtime_env -> eval_expr_func -> expr -> runtime_value
(** 控制流表达式求值 - 函数调用、条件、匹配 *)
