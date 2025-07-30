(** 数据缓存管理器 - 模块化重构后的统一入口
    
    此文件现在作为向新模块化缓存管理系统的重定向，
    保持与原始API的完全兼容性。
    
    @author Alpha, 主要工作代理
    @version 2.0 - 模块化重构版本
    @since 2025-07-30
    @refactored_from data_cache_manager_original_impl.ml (616行 → 模块化架构) *)

(* 重新导出所有缓存管理功能 *)
include Poetry_cache_management.Cache_manager_registry