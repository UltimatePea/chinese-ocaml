(** 错误创建函数接口 - 骆言编译器 *)

open Compiler_errors_types

(** 创建错误信息 *)
val make_error_info : ?severity:error_severity -> ?context:string option -> ?suggestions:string list -> compiler_error -> error_info

(** 位置信息创建辅助函数 *)
val make_position : ?filename:string -> int -> int -> position

(** 常用错误创建函数 *)
val lex_error : ?suggestions:string list -> string -> position -> 'a error_result
val parse_error : ?suggestions:string list -> string -> position -> 'a error_result
val syntax_error : ?suggestions:string list -> string -> position -> 'a error_result
val poetry_parse_error : ?suggestions:string list -> string -> position option -> 'a error_result
val type_error : ?suggestions:string list -> string -> position option -> 'a error_result
val semantic_error : ?suggestions:string list -> string -> position option -> 'a error_result
val codegen_error : ?suggestions:string list -> ?context:string -> string -> 'a error_result
val unimplemented_feature : ?suggestions:string list -> ?context:string -> string -> 'a error_result
val internal_error : ?suggestions:string list -> string -> 'a error_result
val runtime_error : ?suggestions:string list -> string -> position option -> 'a error_result
val exception_raised : ?suggestions:string list -> string -> position option -> 'a error_result
val io_error : ?suggestions:string list -> string -> string -> 'a error_result

(** 常用错误消息的便捷函数 *)
val unsupported_keyword_error : ?suggestions:string list -> string -> position -> 'a error_result
val unsupported_feature_error : ?suggestions:string list -> ?context:string -> string -> position -> 'a error_result
val invalid_character_error : ?suggestions:string list -> char -> position -> 'a error_result
val unexpected_state_error : ?suggestions:string list -> string -> string -> 'a error_result

(** 替换failwith的便捷函数 *)
val failwith_to_error : ?suggestions:string list -> ?context:string option -> string -> 'a error_result

(** 模式匹配错误处理 *)
val match_error : ?suggestions:string list -> ?context:string option -> string -> 'a error_result