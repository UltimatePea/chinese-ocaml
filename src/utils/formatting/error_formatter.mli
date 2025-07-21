(** 骆言统一错误格式化工具模块接口 - Unified Error Formatting Interface *)

(** 错误类型定义 *)
type error_severity = 
  | Fatal    (** 致命错误 *)
  | Error    (** 错误 *)
  | Warning  (** 警告 *)
  | Info     (** 信息 *)

(** 位置信息类型 *)
type position_info = {
  filename: string;
  line: int;
  column: int option;
}

(** 错误消息格式化工具 *)
module Message : sig
  (** 格式化基本错误消息 *)
  val format_error : error_severity -> string -> string

  (** 格式化带位置的错误消息 *)
  val format_error_with_position : error_severity -> string -> position_info -> string

  (** 格式化词法错误 *)
  val format_lexical_error : string -> string -> string

  (** 格式化语法错误 *)
  val format_parse_error : string -> string -> string

  (** 格式化语义错误 *)
  val format_semantic_error : string -> string -> string

  (** 格式化类型错误 *)
  val format_type_error : string -> string -> string

  (** 格式化运行时错误 *)
  val format_runtime_error : string -> string -> string
end

(** 错误恢复建议工具 *)
module Recovery : sig
  (** 生成错误恢复建议 *)
  val suggest_recovery : string -> string list

  (** 格式化恢复建议 *)
  val format_suggestions : string list -> string

  (** 组合错误消息和建议 *)
  val combine_error_and_suggestions : string -> string list -> string
end

(** 错误统计和报告工具 *)
module Statistics : sig
  (** 错误统计信息 *)
  type error_stats = {
    fatal_count: int;
    error_count: int;
    warning_count: int;
    info_count: int;
  }

  (** 格式化错误统计报告 *)
  val format_error_summary : error_stats -> string

  (** 判断是否有阻塞性错误 *)
  val has_blocking_errors : error_stats -> bool
end

(** 用户友好的错误消息工具 *)
module UserFriendly : sig
  (** 将技术错误消息转换为用户友好的描述 *)
  val make_user_friendly : string -> string

  (** 添加解决方案提示 *)
  val add_solution_hint : string -> string -> string

  (** 格式化详细错误报告 *)
  val format_detailed_report : string -> position_info option -> string list -> string
end