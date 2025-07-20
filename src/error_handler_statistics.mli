(** 骆言编译器错误处理系统 - 统计模块接口
    重构自error_handler.ml，第五阶段系统一致性优化：长函数重构
    
    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

(** 全局错误统计 *)
val global_stats : Error_handler_types.error_statistics

(** 错误历史记录（只读访问） *)
val error_history : Error_handler_types.enhanced_error_info list ref

(** 历史记录最大大小 *)
val max_history_size : int ref

(** 更新错误统计 *)
val update_statistics : Error_handler_types.enhanced_error_info -> unit

(** 记录错误到历史 *)
val record_error : Error_handler_types.enhanced_error_info -> unit

(** 获取错误统计报告 *)
val get_error_report : unit -> string

(** 重置错误统计 *)
val reset_statistics : unit -> unit

(** 初始化错误统计系统 *)
val init_statistics : unit -> unit