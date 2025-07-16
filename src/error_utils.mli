(** 统一错误处理工具模块接口 *)

(** 标准化错误消息格式 *)
val format_undefined_variable : string -> string
val format_module_not_found : string -> string
val format_member_not_found : string -> string -> string
val format_scope_error : string -> string
val format_syntax_error : string -> Lexer.position -> string
val format_lexer_error : string -> Lexer.position -> string
val format_type_error : string -> string
val format_runtime_error : string -> string

(** 错误恢复辅助函数 *)
val safe_operation : operation:(unit -> 'a) -> fallback:'a -> 'a
val with_error_context : string -> (unit -> 'a) -> 'a

(** 输入验证辅助函数 *)
val validate_non_empty_string : string -> string -> string
val validate_non_empty_list : string -> 'a list -> 'a list

(** 模块访问错误处理 *)
val safe_module_lookup : Value_operations.runtime_env -> string -> string -> Value_operations.runtime_value

(** 作用域操作错误处理 *)
val safe_scope_operation : string -> (unit -> 'a) -> 'a

(** 位置信息辅助函数 *)
val make_position : int -> int -> string -> Lexer.position
val default_position : Lexer.position

(** 错误报告格式化 *)
val format_error_report : string -> string -> string list -> string

(** 错误统计和报告 *)
type error_stats = {
  mutable lexer_errors : int;
  mutable syntax_errors : int;
  mutable semantic_errors : int;
  mutable runtime_errors : int;
  mutable total_errors : int;
}

val record_lexer_error : unit -> unit
val record_syntax_error : unit -> unit
val record_semantic_error : unit -> unit
val record_runtime_error : unit -> unit
val get_error_stats : unit -> error_stats
val reset_error_stats : unit -> unit
val print_error_summary : unit -> unit