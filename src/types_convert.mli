(** 骆言类型系统 - 类型转换模块接口 *)

open Ast
open Core_types

(** 从基础类型转换 *)
val from_base_type : base_type -> typ

(** 从类型表达式转换为类型 *)
val type_expr_to_typ : type_expr -> typ

(** 从字面量推断类型 *)
val literal_type : literal -> typ

(** 从二元运算符推断类型 *)
val binary_op_type : binary_op -> typ * typ * typ

(** 从一元运算符推断类型 *)
val unary_op_type : unary_op -> typ * typ

(** 从模式中提取变量绑定 *)
val extract_pattern_bindings : pattern -> (string * type_scheme) list

(** 模块类型转换为类型表示 *)
val convert_module_type_to_typ : module_type -> typ

(** 类型表达式转换为内部类型表示 *)
val convert_type_expr_to_typ : type_expr -> typ

(** 类型转换为中文字符串（用于错误消息） *)
val type_to_chinese_string : typ -> string