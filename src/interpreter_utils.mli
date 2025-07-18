(** 骆言解释器工具函数模块接口 - Chinese Programming Language Interpreter Utilities Interface *)

val find_closest_var : string -> string list -> string option
(** 找到最相似的变量名 *)

val lookup_var :
  (string * Value_operations.runtime_value) list -> string -> Value_operations.runtime_value
(** 在环境中查找变量（带错误恢复） *)

val bind_var :
  (string * Value_operations.runtime_value) list ->
  string ->
  Value_operations.runtime_value ->
  (string * Value_operations.runtime_value) list
(** 变量绑定 *)

val eval_literal : Ast.literal -> Value_operations.runtime_value
(** 求值字面量 *)

val expand_macro : Ast.macro_def -> Ast.expr list -> Ast.expr
(** 宏展开：将宏体中的参数替换为实际参数 *)
