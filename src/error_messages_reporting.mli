(** 错误消息报告模块接口 - Error Message Reporting Module Interface *)

val generate_intelligent_error_report : Error_messages_analysis.error_analysis -> string
(** 生成智能错误报告 基于错误分析结果生成用户友好的错误报告，包含上下文信息、智能建议和修复提示
    @param analysis 错误分析结果
    @return 格式化的错误报告字符串 *)

val generate_error_suggestions : string -> string -> string
(** 生成AI友好的错误建议 根据错误类型生成简洁的修复建议
    @param error_type 错误类型
    @param context 错误上下文（当前未使用，为未来扩展保留）
    @return 针对性的错误建议字符串 *)
