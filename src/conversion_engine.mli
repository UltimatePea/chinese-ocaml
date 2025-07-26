(** 统一Token转换引擎 - Phase 6.2 重构接口文件
    
    这是Token系统Phase 6.2重构的核心引擎接口，整合所有转换逻辑到统一架构中。
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 统一转换引擎
    @since 2025-07-25
    @fixes Issue #1340 *)

(** 统一错误处理机制 *)
type token_error =
  | ConversionError of string * string  (** 转换错误: (source, target) *)
  | CompatibilityError of string  (** 兼容性错误 *)
  | ValidationError of string  (** 验证错误 *)
  | SystemError of string  (** 系统级错误 *)

type 'a token_result = Success of 'a | Error of token_error

val handle_error : token_error -> unit
(** 错误处理函数 *)

val error_to_string : token_error -> string
(** 错误转字符串 *)

(** 转换策略类型 *)
type conversion_strategy =
  | Classical  (** 古典诗词转换 *)
  | Modern  (** 现代中文转换 *)
  | Lexer  (** 词法器转换 *)
  | Auto  (** 自动选择策略 *)

type simple_converter_function = string -> string option
(** 简化的转换器函数类型 *)

(** 转换器注册表模块 *)
module ConverterRegistry : sig
  val register_classical_converter : simple_converter_function -> unit
  (** 注册转换器函数 *)

  val register_modern_converter : simple_converter_function -> unit
  val register_lexer_converter : simple_converter_function -> unit

  val get_converters : conversion_strategy -> simple_converter_function list
  (** 获取注册的转换器列表 *)
end

val convert_token :
  strategy:conversion_strategy -> source:string -> target_format:string -> string token_result
(** 简化的转换函数 *)

val batch_convert :
  strategy:conversion_strategy ->
  tokens:string list ->
  target_format:string ->
  string list token_result
(** 批量转换函数 *)

(** 性能优化的快速路径转换模块 *)
module FastPath : sig
  val convert_common_token : string -> string option
  (** 常用token的快速转换 *)
end

(** 转换引擎核心模块 *)
module Core : sig
  val initialize_converters : unit -> unit
  (** 初始化转换器 *)

  val convert_with_fallback : string -> string token_result
  (** 带回退机制的主转换接口 *)
end

(** 向后兼容性接口 *)
module BackwardCompatibility : sig
  val convert_token : string -> string option
  (** 兼容旧API的转换函数 *)

  val convert_token_exn : string -> string
  (** 抛出异常的转换函数 *)

  val convert_token_list : string list -> string list
  (** 批量转换并过滤失败项 *)
end

(** 统计信息模块 *)
module Statistics : sig
  val get_engine_stats : unit -> string
  (** 获取引擎统计信息 *)
end
