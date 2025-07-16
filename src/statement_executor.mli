(** 骆言解释器语句执行模块接口 - Chinese Programming Language Interpreter Statement Executor Interface *)

val execute_stmt :
  (string * Value_operations.runtime_value) list ->
  Ast.stmt ->
  (string * Value_operations.runtime_value) list * Value_operations.runtime_value
(** 执行语句 *)

val execute_program : Ast.stmt list -> (Value_operations.runtime_value, string) result
(** 执行程序 *)
