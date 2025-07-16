(** 骆言解释器工具函数模块接口 - Chinese Programming Language Interpreter Utilities Interface *)

(** 找到最相似的变量名 *)
val find_closest_var : string -> string list -> string option

(** 在环境中查找变量（带错误恢复） *)
val lookup_var : (string * Value_operations.runtime_value) list -> string -> Value_operations.runtime_value

(** 变量绑定 *)
val bind_var : (string * Value_operations.runtime_value) list -> string -> Value_operations.runtime_value -> (string * Value_operations.runtime_value) list

(** 空环境 *)
val empty_env : (string * Value_operations.runtime_value) list

(** 求值字面量 *)
val eval_literal : Ast.literal -> Value_operations.runtime_value

(** 宏展开：将宏体中的参数替换为实际参数 *)
val expand_macro : Ast.macro_def -> Ast.expr list -> Ast.expr