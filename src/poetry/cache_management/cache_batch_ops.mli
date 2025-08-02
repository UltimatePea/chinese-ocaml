(** 缓存批量操作模块接口
    
    此模块实现缓存的批量操作功能，包括批量存储、
    检索和删除等，提高批量数据处理的效率。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

(** {1 批量操作接口} *)

(** 批量存储数据
    @param items 存储项列表，格式为 (key, data, priority_opt, ttl_opt)
    @return 存储结果列表，格式为 (key, success) *)
val store_batch : (string * 'a * cache_priority option * float option) list -> 
  (string * bool) list

(** 批量检索数据
    @param keys 要检索的键列表
    @return 检索结果列表，格式为 (key, result) *)
val retrieve_batch : string list -> (string * 'a cache_result) list

(** 批量删除数据
    @param keys 要删除的键列表
    @return 删除结果列表，格式为 (key, success) *)
val delete_batch : string list -> (string * bool) list

(** 批量检查存在性
    @param keys 要检查的键列表
    @return 存在性检查结果列表，格式为 (key, exists) *)
val exists_batch : string list -> (string * bool) list

(** 批量更新TTL
    @param items TTL更新项列表，格式为 (key, ttl)
    @return 更新结果列表，格式为 (key, success) *)
val update_ttl_batch : (string * float) list -> (string * bool) list