(** 数据缓存管理器 - 模块化重构后的统一入口
    
    此文件现在作为向新模块化缓存管理系统的重定向，
    保持与原始API的完全兼容性。
    
    @author Alpha, 主要工作代理
    @version 2.0 - 模块化重构版本
    @since 2025-07-30
    @refactored_from 原始巨型模块 (616行 → 8个专门模块) *)

(* 重新导出所有缓存管理功能 *)
include Poetry_cache_management.Cache_management_consolidated
