(** 缓存管理器模块接口
    
    负责统一数据管理器的缓存功能，包括LRU缓存实现、
    缓存策略管理和性能统计。
    
    @author Charlie, 规划代理 - 负责架构重构
    @author Whisky, PR Worker - 负责接口修复
    @refactored_from data_manager.ml QueryCache module
    @fix_issue #1727 *)

open Poetry_data_core.Data_types

(** {1 缓存条目类型} *)

type cache_entry = {
  data : unified_data_item list;  (** 缓存的数据 *)
  timestamp : float;  (** 创建时间戳 *)
  access_count : int;  (** 访问次数 *)
}
(** 缓存条目 - 包含数据、时间戳和访问计数 *)

(** {1 核心缓存功能} *)

(** 从缓存中获取数据
    @param criteria 查询条件
    @return 缓存的数据(如果存在且未过期) *)
val get : query_criteria -> unified_data_item list option

(** 向缓存中存储数据
    @param criteria 查询条件
    @param data 要缓存的数据 *)
val put : query_criteria -> unified_data_item list -> unit

(** {1 缓存管理功能} *)

(** 清理过期的缓存条目 *)
val cleanup_expired_entries : unit -> unit

(** 清空所有缓存 *)
val clear_cache : unit -> unit

(** 预热缓存 - 为常用查询预加载数据
    @param criteria_list 要预热的查询条件列表
    @param data_loader 数据加载函数 *)
val warmup_cache : query_criteria list -> (query_criteria -> unified_data_item list data_result) -> unit

(** {1 配置和统计功能} *)

(** 更新缓存配置
    @param new_config 新的缓存配置 *)
val update_cache_config : cache_strategy -> unit

(** 获取当前缓存配置 *)
val get_cache_config : unit -> cache_strategy

(** 获取缓存统计信息 *)
val get_cache_statistics : unit -> cache_statistics

(** 重置缓存统计 *)
val reset_cache_statistics : unit -> unit

(** 获取详细的缓存信息用于调试 *)
val get_cache_debug_info : unit -> string