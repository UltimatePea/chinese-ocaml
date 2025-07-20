(** 骆言统一日志系统 - 模块化重构后的兼容性包装器 
    
    这个文件在模块化重构后保持向后兼容性。
    实际实现已经拆分到 logging/ 子目录中的多个模块：
    - logging/log_core.ml - 核心日志功能
    - logging/log_messages.ml - 消息格式化
    - logging/log_output.ml - 用户输出
    - logging/log_legacy.ml - 兼容性支持
*)

(** 包含所有原始功能的兼容性模块 *)
include Luoyan_logging.Unified_logging_compat