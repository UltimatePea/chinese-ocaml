(** 缓存策略管理模块接口
    
    此模块实现各种缓存策略（LRU, LFU, FIFO, TTL等）
    的逻辑和驱逐算法。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

(** {1 策略查询} *)

(** 根据键获取对应的缓存策略
    @param key 缓存键
    @return 对应的缓存策略 *)
val get_strategy_for_key : string -> cache_strategy

(** {1 驱逐策略} *)

(** 根据策略判断是否应该驱逐条目
    @param entry 缓存条目
    @param strategy 缓存策略
    @return 是否应该驱逐 *)
val should_evict_entry : cache_entry -> cache_strategy -> bool

(** 根据策略找到驱逐的受害者
    @param strategy 缓存策略
    @return 要驱逐的条目键（如果存在） *)
val find_victim_for_eviction : cache_strategy -> string option

(** 检查是否需要驱逐
    @return 是否需要进行驱逐操作 *)
val need_eviction : unit -> bool

(** {1 清理操作} *)

(** 清理过期条目
    @param max_age 最大存活时间（可选）
    @return 清理的条目数量 *)
val expire_stale_entries : ?max_age:float option -> unit -> int