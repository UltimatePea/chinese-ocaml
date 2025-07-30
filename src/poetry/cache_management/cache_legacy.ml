(** 缓存向后兼容层模块
    
    此模块提供与原始data_cache_manager.ml完全兼容的接口，
    确保现有代码无需修改即可使用新的模块化架构。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @replaces data_cache_manager.ml (compatibility layer) *)

open Cache_core_types

(** 兼容性接口 - 简化的get函数 *)
let legacy_get (key : string) : 'a option =
  match Cache_storage.retrieve key with CacheSuccess data -> Some data | _ -> None

(** 兼容性接口 - 简化的set函数 *)
let legacy_set (key : string) (data : 'a) : unit = ignore (Cache_storage.store key data ())

(** 兼容性接口 - 简化的clear函数 *)
let legacy_clear () : unit = ignore (Cache_advanced_ops.clear_all ())
