(*
 * 统一缓存管理器接口 - 消除39个重复缓存实现
 * 
 * Author: Alpha, 主要工作代理  
 * Issue: #1605 - 统一缓存系统技术债务清理
 * 
 * 提供统一的缓存API，支持LRU、LFU、TTL等策略
 * 优化内存使用和查找性能，提供详细的监控统计
 *)

(** 缓存策略类型 *)
type ('k, 'v) cache_strategy =
  | LRU of int  (** 最近最少使用，参数为最大容量 *)
  | LFU of int  (** 最少使用频率，参数为最大容量 *)
  | TTL of float  (** 生存时间，参数为秒数 *)
  | Simple  (** 简单哈希表，无淘汰策略 *)

type ('k, 'v) cache_config = {
  initial_size : int;  (** 初始大小 *)
  max_size : int option;  (** 最大大小限制 *)
  strategy : ('k, 'v) cache_strategy;  (** 缓存策略 *)
  name : string;  (** 缓存名称，用于监控 *)
}
(** 缓存配置 *)

type ('k, 'v) cache_stats = {
  hits : int;  (** 命中次数 *)
  misses : int;  (** 未命中次数 *)
  evictions : int;  (** 淘汰次数 *)
  size : int;  (** 当前大小 *)
  hit_rate : float;  (** 命中率 *)
}
(** 缓存统计信息 *)

type ('k, 'v) cache
(** 缓存类型 *)

(** {1 缓存配置} *)

val default_config : ?name:string -> unit -> ('k, 'v) cache_config
(** 默认配置 - 适用于大多数场景 *)

val small_cache_config : ?name:string -> unit -> ('k, 'v) cache_config
(** 小型缓存配置 - 内存敏感场景 *)

val large_cache_config : ?name:string -> unit -> ('k, 'v) cache_config
(** 大型缓存配置 - 高性能场景 *)

val ttl_cache_config : ?name:string -> ?ttl:float -> unit -> ('k, 'v) cache_config
(** TTL缓存配置 - 时间敏感数据 *)

(** {1 核心操作} *)

val create : ('k, 'v) cache_config -> ('k, 'v) cache
(** 创建缓存 *)

val get : ('k, 'v) cache -> 'k -> 'v option
(** 获取缓存值 *)

val put : ('k, 'v) cache -> 'k -> 'v -> unit
(** 添加缓存值 *)

val mem : ('k, 'v) cache -> 'k -> bool
(** 检查缓存中是否存在key *)

val remove : ('k, 'v) cache -> 'k -> bool
(** 删除缓存条目 *)

val clear : ('k, 'v) cache -> unit
(** 清空缓存 *)

(** {1 监控与统计} *)

val stats : ('k, 'v) cache -> ('k, 'v) cache_stats
(** 获取缓存统计信息 *)

val size : ('k, 'v) cache -> int
(** 获取缓存大小 *)

val is_empty : ('k, 'v) cache -> bool
(** 检查缓存是否为空 *)

val debug_info : ('k, 'v) cache -> string
(** 获取调试信息 *)

(** {1 批量操作} *)

val get_batch : ('k, 'v) cache -> 'k list -> ('k * 'v) list
(** 批量获取 - 返回存在的键值对 *)

val put_batch : ('k, 'v) cache -> ('k * 'v) list -> unit
(** 批量添加 *)

val warm_up : ('k, 'v) cache -> ('k -> 'v option) -> 'k list -> unit
(** 预热缓存 - 使用loader函数加载指定keys *)

(** {1 兼容性与迁移} *)

val migrate_from_hashtbl : ('k, 'v) cache -> ('k, 'v) Hashtbl.t -> unit
(** 从现有Hashtbl迁移数据 *)

val create_hashtbl_compatible : ?size:int -> ?name:string -> unit -> ('k, 'v) cache
(** 创建与Hashtbl兼容的简单缓存 *)

(** {1 全局监控} *)

(** 全局监控功能暂时移除以避免弱类型问题 *)
