(** 骆言统一错误处理系统接口 - Chinese Programming Language Unified Error Handling System Interface 
    Phase 17 统一化扩展版本 *)

(** 统一错误类型 *)
type unified_error =
  | ParseError of string * int * int  (* 解析错误：消息，行，列 *)
  | RuntimeError of string            (* 运行时错误：消息 *)
  | TypeError of string               (* 类型错误：消息 *)
  | LexError of string * Compiler_errors.position (* 词法错误：消息，位置 *)
  | CompilerError of string           (* 编译器错误：消息 *)
  | SystemError of string             (* 系统错误：消息 *)

(** 统一错误结果类型 *)
type 'a unified_result = ('a, unified_error) result

(** 向后兼容的辅助函数 *)
val result_to_value : ('a, exn) result -> 'a
(** 将Result转换为值，在出错时抛出异常 *)

val create_eval_position : int -> Compiler_errors.position
(** 创建位置信息 *)

(** Phase 17 新增：统一错误处理接口 *)

val unified_error_to_string : unified_error -> string
(** 将统一错误转换为字符串 *)

val unified_error_to_exception : unified_error -> exn
(** 将统一错误转换为传统异常（向后兼容） *)

val safe_execute : (unit -> 'a) -> 'a unified_result
(** 安全执行函数，返回Result而不是抛出异常 *)

val result_to_unified_result : ('a, exn) result -> 'a unified_result
(** 将Result转换为统一错误Result *)

val (>>=) : 'a unified_result -> ('a -> 'b unified_result) -> 'b unified_result
(** 链式错误处理 - monadic bind *)

val map_error : (unified_error -> unified_error) -> 'a unified_result -> 'a unified_result
(** 错误映射 *)

val with_default : 'a -> 'a unified_result -> 'a
(** 默认值处理 *)

val log_error : unified_error -> unit
(** 记录错误到日志（如果启用） *)
