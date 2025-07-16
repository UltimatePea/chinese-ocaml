(** 骆言类型系统错误处理模块接口 - Type System Error Handling Interface *)

open Core_types

(** 类型错误异常 *)
exception TypeError of string

(** 解析错误异常 *)
exception ParseError of string * int * int

(** 代码生成错误异常 *)
exception CodegenError of string * string

(** 语义分析错误异常 *)
exception SemanticError of string * string

(** 错误创建函数 *)
val type_error : string -> exn
val parse_error : string -> int -> int -> exn
val codegen_error : string -> string -> exn
val semantic_error : string -> string -> exn

(** 特定错误创建函数 *)
val type_mismatch_error : typ -> typ -> exn
val undefined_var_error : string -> exn
val duplicate_definition_error : string -> exn
val type_inference_error : string -> exn
val unification_error : typ -> typ -> exn
val occurs_check_error : string -> typ -> exn
val arity_mismatch_error : int -> int -> exn
val unsupported_operation_error : string -> typ -> exn
val field_not_found_error : string -> typ -> exn
val overload_resolution_error : string -> typ list -> exn

(** 错误消息格式化 *)
val format_error_message : exn -> string

(** 错误处理包装函数 *)
val handle_error : ('a -> 'b) -> 'a -> ('b, string) result

(** 错误处理映射函数 *)
val handle_error_map : ('a -> 'b) -> 'a -> 'b

(** 安全执行函数 *)
val safe_execute : ('a -> 'b) -> 'a -> 'b -> 'b