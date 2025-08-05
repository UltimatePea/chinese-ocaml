(** 诗词艺术评估缓存管理模块接口
 *
 * 此模块提供统一的缓存管理接口，用于诗词艺术评估相关数据的缓存。
 * 支持多种缓存策略，包括LRU、TTL和无淘汰策略。
 *
 * @author Whisky, PR Worker
 * @issue #2177 Poetry接口完整性
 *)

(** {1 缓存数据类型} *)

type cache_key = string
(** 缓存键类型 *)

type cache_value = string
(** 缓存值类型 *)

type cache_entry = {
  value : cache_value;      (** 缓存值 *)
  created_at : float;       (** 创建时间戳 *)
  access_count : int;       (** 访问次数 *)
  last_access : float;      (** 最后访问时间 *)
}
(** 缓存条目，包含值和元数据 *)

type cache_policy = 
  | LRU of int              (** 最近最少使用策略，参数为最大容量 *)
  | TTL of float            (** 生存时间策略，参数为秒数 *)
  | NoEviction              (** 不淘汰策略 *)
(** 缓存淘汰策略 *)

(** {1 缓存存储} *)

val cache_storage : (string, cache_value) Hashtbl.t
(** 主缓存存储 *)

val cache_metadata : (string, cache_entry) Hashtbl.t
(** 缓存元数据存储 *)

val cache_policy_ref : cache_policy ref
(** 当前缓存策略引用 *)

(** {1 辅助函数} *)

val take : int -> 'a list -> 'a list
(** [take n lst] 取列表前n个元素 *)

(** {1 基础缓存操作} *)

val get_cached : string -> cache_value option
(** [get_cached key] 获取缓存值，更新访问统计 *)

val set_cached : string -> cache_value -> unit
(** [set_cached key value] 设置缓存值，应用缓存策略 *)

val remove_cached : string -> unit
(** [remove_cached key] 删除指定缓存项 *)

val clear_cache : unit -> unit
(** [clear_cache ()] 清空所有缓存 *)

(** {1 缓存策略管理} *)

val apply_cache_policy : unit -> unit
(** [apply_cache_policy ()] 应用当前缓存策略进行淘汰 *)

val evict_lru : int -> unit
(** [evict_lru count] 淘汰指定数量的最少使用项 *)

val evict_expired : float -> unit
(** [evict_expired ttl] 淘汰超过TTL的过期项 *)

val set_cache_policy : cache_policy -> unit
(** [set_cache_policy policy] 设置缓存策略 *)

val get_cache_policy : unit -> cache_policy
(** [get_cache_policy ()] 获取当前缓存策略 *)

(** {1 缓存统计与分析} *)

val get_cache_stats : unit -> (string * string) list
(** [get_cache_stats ()] 获取缓存统计信息 *)

val get_hot_entries : int -> (string * int) list
(** [get_hot_entries limit] 获取访问次数最多的条目 *)

(** {1 专门的艺术评估缓存} *)

val cache_evaluation_result : string -> cache_value -> unit
(** [cache_evaluation_result poem_text result] 缓存诗词评估结果 *)

val get_cached_evaluation : string -> cache_value option
(** [get_cached_evaluation poem_text] 获取缓存的诗词评估结果 *)

val cache_rhyme_analysis : string -> cache_value -> unit
(** [cache_rhyme_analysis poem_text rhyme_data] 缓存韵律分析结果 *)

val get_cached_rhyme_analysis : string -> cache_value option
(** [get_cached_rhyme_analysis poem_text] 获取缓存的韵律分析结果 *)

val cache_mood_analysis : string -> cache_value -> unit
(** [cache_mood_analysis poem_text mood_data] 缓存意境分析结果 *)

val get_cached_mood_analysis : string -> cache_value option
(** [get_cached_mood_analysis poem_text] 获取缓存的意境分析结果 *)

(** {1 缓存维护与优化} *)

val warm_up_cache : unit -> unit
(** [warm_up_cache ()] 预热缓存，加载常用数据 *)

val cleanup_cache : unit -> unit
(** [cleanup_cache ()] 执行缓存清理任务 *)

val optimize_cache_size : unit -> unit
(** [optimize_cache_size ()] 根据访问模式优化缓存大小 *)

(** {1 缓存导入导出} *)

val export_cache : unit -> string
(** [export_cache ()] 导出缓存数据为字符串 *)

val import_cache : string -> unit
(** [import_cache data] 从字符串导入缓存数据 *)