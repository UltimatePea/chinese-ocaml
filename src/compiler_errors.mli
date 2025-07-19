(** 统一错误处理系统 - 骆言编译器 (重构版本)

    此模块提供了编译器的统一错误处理系统，通过模块化设计实现了错误类型定义、
    错误信息格式化、错误收集和处理配置等功能。 
    
    模块结构:
    - Compiler_errors_types: 核心错误类型定义
    - Compiler_errors_creation: 错误创建函数
    - Compiler_errors_formatter: 错误格式化和显示
    *)

(* 重新导出所有子模块的类型和函数 *)

(** 核心类型定义 *)
include module type of Compiler_errors_types

(** 错误创建函数 *)
include module type of Compiler_errors_creation

(** 错误格式化函数 *)
include module type of Compiler_errors_formatter

(** 错误处理和异常转换函数 *)
val raise_compiler_error : error_info -> 'a
val extract_error_info : 'a error_result -> error_info
val wrap_legacy_exception : (unit -> 'a error_result) -> 'a error_result
val safe_execute : (unit -> 'a) -> 'a error_result

(** 错误收集器函数 *)
val create_error_collector : unit -> error_collector
val add_error : error_collector -> error_info -> unit
val has_errors : error_collector -> bool
val get_errors : error_collector -> error_info list
val get_error_count : error_collector -> int

(** 错误处理配置 *)
val get_error_config : unit -> error_handling_config
val set_error_config : error_handling_config -> unit
val should_continue : error_collector -> bool

(** 错误处理工具函数 *)
val map_error : ('a -> 'b) -> 'a error_result -> 'b error_result
val bind_error : ('a -> 'b error_result) -> 'a error_result -> 'b error_result
val ( >>= ) : 'a error_result -> ('a -> 'b error_result) -> 'b error_result
val ( >>| ) : 'a error_result -> ('a -> 'b) -> 'b error_result

(** 便捷工具函数 *)
val option_to_error : ?suggestions:string list -> string -> 'a option -> 'a error_result
val chain_errors : ('a -> 'a error_result) list -> 'a -> 'a error_result
val collect_error_results : 'a error_result list -> 'a list error_result

(** 安全操作函数 *)
val safe_option_get : ?error_msg:string -> 'a option -> 'a error_result
val safe_list_head : ?error_msg:string -> 'a list -> 'a error_result
val safe_list_nth : ?error_msg:string -> 'a list -> int -> 'a error_result
val safe_int_of_string : ?error_msg:string -> string -> int error_result
val safe_float_of_string : ?error_msg:string -> string -> float error_result

(** 验证函数 *)
val validate_non_empty_string : ?error_msg:string -> string -> string error_result
val validate_positive_int : ?error_msg:string -> int -> int error_result

(** 操作符重载 *)
val ( let* ) : 'a error_result -> ('a -> 'b error_result) -> 'b error_result
val ( let+ ) : 'a error_result -> ('a -> 'b) -> 'b error_result
val ( >>? ) : 'a error_result -> ('a -> 'b error_result) -> 'b error_result