(** 统一缓存管理接口 - P0专项整合
    
    整合cache_manager和managers/cache_manager的重复功能，
    提供统一的缓存管理接口。
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 缓存配置和策略} *)

(** 缓存策略类型 *)
type cache_strategy = LRU  (** 最近最少使用 *) | FIFO  (** 先进先出 *) | LFU  (** 最少使用频率 *)

type cache_config = {
  max_size : int;  (** 最大缓存项目数 *)
  strategy : cache_strategy;  (** 缓存策略 *)
  ttl_seconds : int option;  (** 生存时间（秒），None表示永不过期 *)
  enable_statistics : bool;  (** 启用统计信息收集 *)
  auto_cleanup : bool;  (** 自动清理过期项 *)
}
(** 缓存配置 *)

val default_cache_config : cache_config
(** 默认缓存配置 *)

(** {1 缓存键和值类型} *)

type cache_key = string
(** 缓存键类型 *)

type cache_value =
  | JsonValue of Yojson.Safe.t  (** JSON数据 *)
  | StringValue of string  (** 字符串数据 *)
  | StringListValue of string list  (** 字符串列表 *)
  | BytesValue of bytes  (** 字节数据 *)
  | CustomValue of string * bytes  (** 自定义数据：(类型标识, 序列化数据) *)

(** {1 缓存统计信息} *)

type cache_stats = {
  hits : int;  (** 命中次数 *)
  misses : int;  (** 未命中次数 *)
  hit_rate : float;  (** 命中率 *)
  total_requests : int;  (** 总请求次数 *)
  current_size : int;  (** 当前缓存项目数 *)
  evictions : int;  (** 驱逐次数 *)
  expired_count : int;  (** 过期项目数 *)
  memory_usage_bytes : int;  (** 内存使用量（估算） *)
}

(** {1 核心缓存接口} *)

val create_cache : ?config:cache_config -> string -> unit
(** 创建命名缓存实例
    @param config 缓存配置（可选）
    @param name 缓存名称 *)

val get : cache_name:string -> cache_key -> cache_value option
(** 获取缓存值
    @param cache_name 缓存名称
    @param key 缓存键
    @return 缓存值（如果存在） *)

val set : cache_name:string -> cache_key -> cache_value -> unit
(** 设置缓存值
    @param cache_name 缓存名称
    @param key 缓存键
    @param value 缓存值 *)

val remove : cache_name:string -> cache_key -> bool
(** 删除缓存项
    @param cache_name 缓存名称
    @param key 缓存键
    @return 是否删除成功 *)

val exists : cache_name:string -> cache_key -> bool
(** 检查缓存项是否存在
    @param cache_name 缓存名称
    @param key 缓存键
    @return 是否存在 *)

(** {1 批量操作} *)

val set_multiple : cache_name:string -> (cache_key * cache_value) list -> unit
(** 批量设置缓存值 *)

val get_multiple : cache_name:string -> cache_key list -> (cache_key * cache_value option) list
(** 批量获取缓存值 *)

val remove_multiple : cache_name:string -> cache_key list -> int
(** 批量删除缓存项
    @return 实际删除的项目数 *)

(** {1 缓存管理} *)

val clear : cache_name:string -> unit
(** 清空指定缓存 *)

val clear_all : unit -> unit
(** 清空所有缓存 *)

val resize : cache_name:string -> int -> unit
(** 调整缓存大小
    @param cache_name 缓存名称
    @param new_size 新的最大大小 *)

val set_ttl : cache_name:string -> int option -> unit
(** 设置生存时间
    @param cache_name 缓存名称
    @param ttl_seconds 生存时间（秒），None表示永不过期 *)

(** {1 缓存维护} *)

val cleanup_expired : cache_name:string -> int
(** 清理过期项
    @param cache_name 缓存名称
    @return 清理的项目数 *)

val cleanup_all_expired : unit -> int
(** 清理所有缓存的过期项
    @return 清理的项目数 *)

val force_evict : cache_name:string -> int -> int
(** 强制驱逐指定数量的项目
    @param cache_name 缓存名称
    @param count 要驱逐的项目数
    @return 实际驱逐的项目数 *)

(** {1 统计和监控} *)

val get_stats : cache_name:string -> cache_stats
(** 获取缓存统计信息 *)

val get_all_stats : unit -> (string * cache_stats) list
(** 获取所有缓存的统计信息 *)

val reset_stats : cache_name:string -> unit
(** 重置统计信息 *)

val print_stats : cache_name:string -> unit
(** 打印缓存统计信息 *)

val print_all_stats : unit -> unit
(** 打印所有缓存统计信息 *)

(** {1 缓存配置管理} *)

val get_config : cache_name:string -> cache_config
(** 获取缓存配置 *)

val update_config : cache_name:string -> cache_config -> unit
(** 更新缓存配置 *)

val list_caches : unit -> string list
(** 列出所有缓存名称 *)

(** {1 专用缓存接口} *)

(** Poetry数据专用缓存 *)
module PoetryCache : sig
  val get_rhyme_data : cache_key -> (string * string * string) list option
  val set_rhyme_data : cache_key -> (string * string * string) list -> unit
  val get_tone_data : cache_key -> string list option
  val set_tone_data : cache_key -> string list -> unit
  val get_word_class_data : cache_key -> string list option
  val set_word_class_data : cache_key -> string list -> unit
end

(** JSON数据专用缓存 *)
module JsonCache : sig
  val get_json : cache_key -> Yojson.Safe.t option
  val set_json : cache_key -> Yojson.Safe.t -> unit
  val get_parsed_file : string -> Yojson.Safe.t option
  val set_parsed_file : string -> Yojson.Safe.t -> unit
end

(** 文件内容专用缓存 *)
module FileCache : sig
  val get_file_content : string -> string option
  val set_file_content : string -> string -> unit
  val get_file_lines : string -> string list option
  val set_file_lines : string -> string list -> unit
end

(** {1 高级功能} *)

val warm_cache : cache_name:string -> (cache_key * cache_value) list -> unit
(** 预热缓存，批量加载数据 *)

val export_cache : cache_name:string -> string -> unit
(** 导出缓存到文件
    @param cache_name 缓存名称
    @param file_path 导出文件路径 *)

val import_cache : cache_name:string -> string -> unit
(** 从文件导入缓存
    @param cache_name 缓存名称
    @param file_path 导入文件路径 *)

val migrate_cache : old_name:string -> new_name:string -> unit
(** 迁移缓存数据
    @param old_name 旧缓存名称
    @param new_name 新缓存名称 *)

(** {1 性能优化} *)

val enable_background_cleanup : bool -> unit
(** 启用后台清理线程 *)

val set_cleanup_interval : int -> unit
(** 设置自动清理间隔（秒） *)

val optimize_cache : cache_name:string -> unit
(** 优化缓存结构，整理内存 *)

val get_memory_usage : cache_name:string -> int
(** 获取缓存内存使用量（字节） *)

val get_total_memory_usage : unit -> int
(** 获取所有缓存的总内存使用量 *)

(** {1 兼容性接口} *)

(** 兼容原cache_manager模块 *)
module CacheManagerCompat : sig
  val get : cache_key -> 'a option
  val set : cache_key -> 'a -> unit
  val clear : unit -> unit
  val stats : unit -> int * int * float
end

(** 兼容managers/cache_manager模块 *)
module ManagersCacheCompat : sig
  val cache_get : string -> string option
  val cache_set : string -> string -> unit
  val cache_clear : unit -> unit
  val cache_size : unit -> int
end

(** {1 调试和工具} *)

val validate_cache_integrity : cache_name:string -> bool * string list
(** 验证缓存完整性
    @return (验证结果, 错误列表) *)

val benchmark_cache_performance : cache_name:string -> int -> float * float
(** 基准测试缓存性能
    @param cache_name 缓存名称
    @param operations 操作次数
    @return (平均读取时间ms, 平均写入时间ms) *)

val debug_cache_content : cache_name:string -> unit
(** 调试输出缓存内容 *)

val get_cache_health_report : cache_name:string -> string
(** 获取缓存健康报告 *)
