(** Phase 1-B 错误处理标准化模块接口
    
    Author: Whisky, PR Worker
    定义统一的错误处理API，供整个编译器系统使用
*)

(** 标准化结果类型 *)
type ('a, 'e) result = Ok of 'a | Error of 'e

(** 标准化错误类型 *)
type standard_error = 
  | CompilerError of string * Compiler_errors.position option
  | RuntimeError of string
  | SemanticError of string  
  | SyntaxError of string * Compiler_errors.position option
  | TypeError of string
  | FileSystemError of string
  | NetworkError of string
  | ValidationError of string

(** 错误转换为中文消息 *)
val error_to_chinese_message : standard_error -> string

(** 安全执行函数 *)
val safe_execute : (unit -> 'a) -> ('a, standard_error) result
val safe_file_operation : (unit -> 'a) -> string -> ('a, standard_error) result
val safe_compiler_operation : (unit -> 'a) -> Compiler_errors.position option -> ('a, standard_error) result

(** Result类型的单子操作 *)
val (>>=) : ('a, 'e) result -> ('a -> ('b, 'e) result) -> ('b, 'e) result
val (>>|) : ('a, 'e) result -> ('a -> 'b) -> ('b, 'e) result

(** 组合多个Result操作 *)
val combine_results : ('a, 'e) result list -> ('a list, 'e) result

(** 默认错误处理 *)
val handle_error_with_default : default:'a -> error_handler:(standard_error -> unit) -> ('a, standard_error) result -> 'a

(** 记录错误到日志系统 *)
val log_error : standard_error -> unit

(** 验证函数 *)
val validate : bool -> standard_error -> (unit, standard_error) result
val validate_non_empty_string : string -> string -> (unit, standard_error) result
val validate_file_exists : string -> (unit, standard_error) result
val validate_all : (unit, standard_error) result list -> (unit, standard_error) result

(** 安全类型转换 *)
val safe_int_of_string : string -> (int, standard_error) result
val safe_float_of_string : string -> (float, standard_error) result

(** 错误恢复策略 *)
type 'a recovery_strategy = 
  | UseDefault of 'a
  | Retry of (unit -> ('a, standard_error) result)
  | Abort

val apply_recovery_strategy : 'a recovery_strategy -> standard_error -> ('a, standard_error) result

(** 标准化的实用函数 *)
val read_file_safe : string -> (string, standard_error) result
val parse_config_safe : string -> ((string * string) list, standard_error) result