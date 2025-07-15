(** 统一错误处理系统接口 - 骆言编译器 *)

open Lexer

(** 编译器错误类型 *)
type compiler_error = 
  | ParseError of string * position
  | TypeError of string * position
  | CodegenError of string * string
  | UnimplementedFeature of string * string
  | InternalError of string
  | RuntimeError of string

(** 错误严重级别 *)
type error_severity = Warning | Error | Fatal

(** 错误信息记录 *)
type error_info = {
  error: compiler_error;
  severity: error_severity;
  context: string option;
  suggestions: string list;
}

(** 错误处理结果 *)
type 'a error_result = Ok of 'a | Error of error_info

(** 错误信息创建和格式化 *)
val make_error_info : ?severity:error_severity -> ?context:string option -> ?suggestions:string list -> compiler_error -> error_info
val format_error_message : compiler_error -> string
val format_error_info : error_info -> string
val print_error_info : error_info -> unit

(** 常用错误创建函数 *)
val parse_error : ?suggestions:string list -> string -> position -> 'a error_result
val type_error : ?suggestions:string list -> string -> position -> 'a error_result
val codegen_error : ?suggestions:string list -> ?context:string -> string -> 'a error_result
val unimplemented_feature : ?suggestions:string list -> ?context:string -> string -> 'a error_result
val internal_error : ?suggestions:string list -> string -> 'a error_result
val runtime_error : ?suggestions:string list -> string -> 'a error_result

(** 错误处理工具函数 *)
val map_error : ('a -> 'b) -> 'a error_result -> 'b error_result
val bind_error : ('a -> 'b error_result) -> 'a error_result -> 'b error_result
val ( >>= ) : 'a error_result -> ('a -> 'b error_result) -> 'b error_result
val ( >>| ) : 'a error_result -> ('a -> 'b) -> 'b error_result

(** 错误收集器 *)
type error_collector

val create_error_collector : unit -> error_collector
val add_error : error_collector -> error_info -> unit
val has_errors : error_collector -> bool
val get_errors : error_collector -> error_info list
val get_error_count : error_collector -> int

(** 错误处理策略配置 *)
type error_handling_config = {
  continue_on_error: bool;
  max_errors: int;
  show_suggestions: bool;
  colored_output: bool;
}

val default_error_config : error_handling_config
val set_error_config : error_handling_config -> unit
val should_continue : error_collector -> bool