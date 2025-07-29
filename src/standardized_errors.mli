(** 骆言标准化错误处理模块接口 - 减少异常类型碎片化 *)

(** 核心标准化异常类型 - 从56种减少到5种核心类型 *)

(** 标准运行时错误 - 用于运行时产生的错误 *)
exception StandardRuntimeError of string

(** 标准语法错误 - 用于语法分析阶段的错误 *)
exception StandardSyntaxError of string * Compiler_errors.position option

(** 标准类型错误 - 用于类型检查阶段的错误 *)
exception StandardTypeError of string * Compiler_errors.position option

(** 标准词法错误 - 用于词法分析阶段的错误 *)
exception StandardLexError of string * Compiler_errors.position option

(** 标准系统错误 - 用于系统级和内部错误 *)
exception StandardSystemError of string

(** 错误映射函数
    将现有的各种异常类型映射到标准类型
    @param exn 原始异常
    @return 标准化后的异常 *)
val standardize_exception : exn -> exn

(** 安全执行函数
    捕获所有异常并标准化为Result类型
    @param f 要执行的函数
    @return Ok(结果) 或 Error(标准化错误) *)
val safe_execute_standardized : (unit -> 'a) -> ('a, Error_types.unified_error) result

(** 统一错误抛出函数 - 替代分散的failwith调用 *)

val fail_runtime : string -> 'a
(** 抛出标准运行时错误
    @param msg 错误消息
    @raise StandardRuntimeError *)

val fail_syntax : ?pos:Compiler_errors.position -> string -> 'a
(** 抛出标准语法错误
    @param pos 可选的位置信息
    @param msg 错误消息
    @raise StandardSyntaxError *)

val fail_type : ?pos:Compiler_errors.position -> string -> 'a
(** 抛出标准类型错误
    @param pos 可选的位置信息
    @param msg 错误消息
    @raise StandardTypeError *)

val fail_lex : ?pos:Compiler_errors.position -> string -> 'a
(** 抛出标准词法错误
    @param pos 可选的位置信息
    @param msg 错误消息
    @raise StandardLexError *)

val fail_system : string -> 'a
(** 抛出标准系统错误
    @param msg 错误消息
    @raise StandardSystemError *)

(** 向后兼容的异常转换
    根据错误名称将错误消息转换为相应的标准异常
    @param error_name 错误类型名称
    @param msg 错误消息
    @return 标准化异常 *)
val convert_legacy_exception : string -> string -> exn

(** 批量错误重构助手
    用于将文件中的多种异常统一化
    @param error_name 错误类型名称
    @param msg 错误消息
    @return 标准化异常 *)
val refactor_error_calls : string -> string -> exn

(** 错误统计助手
    用于监控标准化进展 *)
val count_standardized_errors : unit -> unit

(** 兼容性包装模块 - 允许渐进式迁移 *)
module Compatibility : sig
  (** 包装旧的failwith调用
      @param msg 错误消息
      @raise StandardRuntimeError *)
  val failwith : string -> 'a

  (** 包装旧的invalid_arg调用
      @param msg 错误消息
      @raise StandardRuntimeError *)
  val invalid_arg : string -> 'a

  (** 包装旧的raise调用
      @param exn 原始异常
      @raise 标准化异常 *)
  val raise_with_standardization : exn -> 'a
end