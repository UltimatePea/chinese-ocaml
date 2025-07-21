(** 骆言编译器错误处理系统 - 核心处理模块接口 重构自error_handler.ml，第五阶段系统一致性优化：长函数重构

    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

val handle_error :
  ?context:Error_handler_types.error_context ->
  Compiler_errors.error_info ->
  Error_handler_types.enhanced_error_info
(** 主要的错误处理函数 *)

(** 便捷的错误创建函数 *)
module Create : sig
  val parse_error :
    ?context:Error_handler_types.error_context ->
    ?suggestions:string list ->
    string ->
    Compiler_errors.position ->
    Error_handler_types.enhanced_error_info
  (** 创建解析错误 *)

  val type_error :
    ?context:Error_handler_types.error_context ->
    ?suggestions:string list ->
    string ->
    Compiler_errors.position option ->
    Error_handler_types.enhanced_error_info
  (** 创建类型错误 *)

  val runtime_error :
    ?context:Error_handler_types.error_context ->
    ?suggestions:string list ->
    string ->
    Error_handler_types.enhanced_error_info
  (** 创建运行时错误 *)

  val internal_error :
    ?context:Error_handler_types.error_context ->
    ?suggestions:string list ->
    string ->
    Error_handler_types.enhanced_error_info
  (** 创建内部错误 *)
end

val handle_multiple_errors :
  Compiler_errors.error_info list ->
  Error_handler_types.error_context ->
  Error_handler_types.enhanced_error_info list * bool
(** 批量错误处理 *)

val init_error_handling : unit -> unit
(** 初始化错误处理系统 *)
