(** 骆言编译器统一错误处理系统接口 *)

(** 错误恢复策略类型 *)
type recovery_strategy =
  | SkipAndContinue  (** 跳过错误，继续处理 *)
  | SyncToNextStatement  (** 同步到下一语句边界 *)
  | TryAlternative of string  (** 尝试替代方案 *)
  | RequestUserInput  (** 请求用户输入 *)
  | Abort  (** 终止处理 *)

type error_context = {
  source_file : string;
  function_name : string;
  module_name : string;
  timestamp : float;
  call_stack : string list;
  user_data : (string * string) list;
}
(** 错误上下文信息 *)

type enhanced_error_info = {
  base_error : Compiler_errors.error_info;
  context : error_context;
  recovery_strategy : recovery_strategy;
  attempt_count : int;
  related_errors : enhanced_error_info list;
}
(** 增强的错误信息 *)

type error_statistics = {
  mutable total_errors : int;
  mutable warnings : int;
  mutable errors : int;
  mutable fatal_errors : int;
  mutable recovered_errors : int;
  mutable start_time : float;
}
(** 错误统计信息 *)

val create_context :
  ?source_file:string ->
  ?function_name:string ->
  ?module_name:string ->
  ?call_stack:string list ->
  ?user_data:(string * string) list ->
  unit ->
  error_context
(** 创建错误上下文 *)

val create_enhanced_error :
  ?recovery_strategy:recovery_strategy ->
  ?attempt_count:int ->
  ?related_errors:enhanced_error_info list ->
  Compiler_errors.error_info ->
  error_context ->
  enhanced_error_info
(** 创建增强的错误信息 *)

val determine_recovery_strategy : Compiler_errors.compiler_error -> recovery_strategy
(** 确定恢复策略 *)

val format_enhanced_error : enhanced_error_info -> string
(** 格式化增强的错误信息 *)

val colorize_error_message : Compiler_errors.error_severity -> string -> string
(** 为错误消息添加颜色 *)

val update_statistics : enhanced_error_info -> unit
(** 更新错误统计信息 *)

val record_error : enhanced_error_info -> unit
(** 记录错误到历史记录 *)

val handle_error : ?context:error_context -> Compiler_errors.error_info -> enhanced_error_info
(** 处理错误 *)

val attempt_recovery : enhanced_error_info -> bool
(** 尝试错误恢复 *)

val handle_multiple_errors :
  Compiler_errors.error_info list -> error_context -> enhanced_error_info list * bool
(** 处理多个错误 *)

val get_error_report : unit -> string
(** 获取错误报告 *)

val reset_statistics : unit -> unit
(** 重置错误统计 *)

(** 错误构建器模块 *)
module Create : sig
  val parse_error :
    ?context:error_context ->
    ?suggestions:string list ->
    string ->
    Compiler_errors.position ->
    enhanced_error_info

  val type_error :
    ?context:error_context ->
    ?suggestions:string list ->
    string ->
    Compiler_errors.position option ->
    enhanced_error_info

  val runtime_error :
    ?context:error_context -> ?suggestions:string list -> string -> enhanced_error_info

  val internal_error :
    ?context:error_context -> ?suggestions:string list -> string -> enhanced_error_info
end

val is_recoverable : enhanced_error_info -> bool
(** 判断错误是否可恢复 *)

val is_fatal : enhanced_error_info -> bool
(** 判断错误是否为致命错误 *)

val log_error_to_file : enhanced_error_info -> unit
(** 将错误记录到文件 *)

val init_error_handling : unit -> unit
(** 初始化错误处理系统 *)
