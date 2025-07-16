(** 骆言解释器模式匹配模块接口 - Chinese Programming Language Interpreter Pattern Matcher Interface *)

(** 模式匹配 *)
val match_pattern : Ast.pattern -> Value_operations.runtime_value -> (string * Value_operations.runtime_value) list -> (string * Value_operations.runtime_value) list option

(** 执行模式匹配 *)
val execute_match : (string * Value_operations.runtime_value) list -> Value_operations.runtime_value -> Ast.match_branch list -> ((string * Value_operations.runtime_value) list -> Ast.expr -> Value_operations.runtime_value) -> Value_operations.runtime_value

(** 执行异常匹配 *)
val execute_exception_match : (string * Value_operations.runtime_value) list -> Value_operations.runtime_value -> Ast.match_branch list -> ((string * Value_operations.runtime_value) list -> Ast.expr -> Value_operations.runtime_value) -> Value_operations.runtime_value

(** 注册构造器函数 *)
val register_constructors : (string * Value_operations.runtime_value) list -> Ast.type_def -> (string * Value_operations.runtime_value) list