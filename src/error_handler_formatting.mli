(** 骆言编译器错误处理系统 - 格式化和日志模块接口 重构自error_handler.ml，第五阶段系统一致性优化：长函数重构

    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

val format_enhanced_error : Error_handler_types.enhanced_error_info -> string
(** 格式化增强错误信息 *)

val colorize_error_message : Compiler_errors.error_severity -> string -> string
(** 彩色输出支持 *)

val log_error_to_file : Error_handler_types.enhanced_error_info -> unit
(** 错误日志记录到文件 *)
