(** 骆言数据结构表达式求值模块接口 - Chinese Programming Language Data Structure Expression Evaluator Interface *)

open Ast
open Unified_errors
open Value_operations

(** 评估函数类型 *)
type eval_expr_func = (string * runtime_value) list -> expr -> runtime_value result

(** 记录表达式求值 *)
val eval_record_expr : (string * runtime_value) list -> (string * expr) list -> eval_expr_func -> runtime_value result

(** 字段访问表达式求值 *)
val eval_field_access : (string * runtime_value) list -> expr -> string -> eval_expr_func -> runtime_value result

(** 元组表达式求值 *)
val eval_tuple_expr : (string * runtime_value) list -> expr list -> eval_expr_func -> runtime_value result

(** 数组表达式求值 *)
val eval_array_expr : (string * runtime_value) list -> expr list -> eval_expr_func -> runtime_value result

(** 记录更新表达式求值 *)
val eval_record_update : (string * runtime_value) list -> expr -> (string * expr) list -> eval_expr_func -> runtime_value result

(** 数组访问表达式求值 *)
val eval_array_access : (string * runtime_value) list -> expr -> expr -> eval_expr_func -> runtime_value result

(** 数组更新表达式求值 *)
val eval_array_update : (string * runtime_value) list -> expr -> expr -> expr -> eval_expr_func -> runtime_value result

(** 列表表达式求值 *)
val eval_list_expr : (string * runtime_value) list -> expr list -> eval_expr_func -> runtime_value result

(** 数据结构表达式求值 - 记录、数组、元组 *)
val eval_data_structure_expr : (string * runtime_value) list -> expr -> eval_expr_func -> runtime_value result