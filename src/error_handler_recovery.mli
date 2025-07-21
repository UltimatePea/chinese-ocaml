(** 骆言编译器错误处理系统 - 错误恢复策略模块接口 重构自error_handler.ml，第五阶段系统一致性优化：长函数重构

    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

val determine_recovery_strategy :
  Compiler_errors.compiler_error -> Error_handler_types.recovery_strategy
(** 根据配置确定恢复策略 *)

val attempt_recovery : Error_handler_types.enhanced_error_info -> bool
(** 错误恢复执行 *)

val should_continue_processing : unit -> bool
(** 检查是否应该继续处理错误 *)
