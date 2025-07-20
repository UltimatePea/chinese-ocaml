(** 骆言编译器统一错误处理系统 - 主模块（重构版）
    
    重构说明：原296行的巨大模块被拆分为多个专注的子模块：
    - Error_handler_types: 类型定义和基础函数
    - Error_handler_statistics: 错误统计和历史记录
    - Error_handler_recovery: 错误恢复策略
    - Error_handler_formatting: 错误格式化和日志
    - Error_handler_core: 核心错误处理逻辑
    
    @author 骆言技术债务清理团队
    @version 2.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

(* 重新导出类型定义 *)
include Error_handler_types

(* 重新导出统计功能 *)
module Statistics = Error_handler_statistics

(* 重新导出恢复策略 *)
module Recovery = Error_handler_recovery

(* 重新导出格式化功能 *)
module Formatting = Error_handler_formatting

(* 重新导出核心处理功能 *)
include Error_handler_core

(* 为了向后兼容，重新导出一些常用的统计函数 *)
let get_error_report = Statistics.get_error_report
let reset_statistics = Statistics.reset_statistics
let update_statistics = Statistics.update_statistics
let record_error = Statistics.record_error

(* 重新导出常用的恢复函数 *)
let attempt_recovery = Recovery.attempt_recovery
let determine_recovery_strategy = Recovery.determine_recovery_strategy

(* 重新导出格式化函数 *)
let format_enhanced_error = Formatting.format_enhanced_error
let log_error_to_file = Formatting.log_error_to_file
let colorize_error_message = Formatting.colorize_error_message