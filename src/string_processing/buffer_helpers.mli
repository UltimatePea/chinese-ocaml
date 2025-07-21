(** Buffer累积辅助模块

    本模块提供Buffer操作的便利函数， 简化报告生成和字符串累积操作。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 Buffer格式化操作} *)

val add_formatted_string : Buffer.t -> (unit -> string) -> unit
(** [add_formatted_string buffer format_fn] 安全地向Buffer添加格式化字符串
    @param buffer 目标缓冲区
    @param format_fn 格式化函数，返回要添加的字符串 *)

(** {1 批量添加操作} *)

val add_stats_batch : Buffer.t -> (string * string * int) list -> unit
(** [add_stats_batch buffer stats_list] 批量添加统计信息到缓冲区
    @param buffer 目标缓冲区
    @param stats_list 统计信息列表，每项为 (图标, 类别, 数量) *)

(** {1 错误信息处理} *)

val add_error_with_context : Buffer.t -> string -> string option -> unit
(** [add_error_with_context buffer error_msg context_opt] 添加带上下文的错误信息到缓冲区
    @param buffer 目标缓冲区
    @param error_msg 错误消息
    @param context_opt 可选的上下文信息 *)
