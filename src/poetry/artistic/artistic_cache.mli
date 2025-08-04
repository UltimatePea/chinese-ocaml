(** 诗词艺术评估缓存管理模块接口
 *
 * 此模块提供诗词艺术评估过程中的缓存管理功能，包括评估结果缓存、
 * 韵律分析缓存、意境分析缓存等专门的缓存操作。
 *
 * 主要功能：
 * - 通用缓存操作（获取、设置、删除、清空）
 * - 缓存策略管理（LRU、TTL、NoEviction）
 * - 缓存统计与监控
 * - 专门的艺术评估缓存
 * - 缓存预热与维护
 * - 缓存导出导入
 *
 * @author Whisky, PR Worker
 *)

(** {1 缓存类型定义} *)

(** 缓存键类型 *)
type cache_key = string

(** 缓存值类型 *)
type cache_value = string

(** 缓存条目信息 *)
type cache_entry = {
  value : cache_value;      (** 缓存值 *)
  created_at : float;       (** 创建时间 *)
  access_count : int;       (** 访问次数 *)
  last_access : float;      (** 最后访问时间 *)
}

(** 缓存策略 *)
type cache_policy = 
  | LRU of int     (** 最近最少使用策略，参数为最大容量 *)
  | TTL of float   (** 生存时间策略，参数为秒数 *)
  | NoEviction     (** 不删除策略 *)

(** {1 基础缓存操作} *)

(** 获取缓存值
    @param key 缓存键
    @return 缓存值选项，若不存在则返回 None *)
val get_cached : string -> cache_value option

(** 设置缓存值
    @param key 缓存键
    @param value 缓存值 *)
val set_cached : string -> cache_value -> unit

(** 删除缓存项
    @param key 要删除的缓存键 *)
val remove_cached : string -> unit

(** 清空所有缓存 *)
val clear_cache : unit -> unit

(** {1 缓存策略管理} *)

(** 设置缓存策略
    @param policy 要设置的缓存策略 *)
val set_cache_policy : cache_policy -> unit

(** 获取当前缓存策略
    @return 当前使用的缓存策略 *)
val get_cache_policy : unit -> cache_policy

(** {1 缓存统计与监控} *)

(** 获取缓存统计信息
    @return 统计信息列表，包含总条目数、总访问次数、平均年龄等 *)
val get_cache_stats : unit -> (string * string) list

(** 获取热点数据
    @param limit 返回的热点条目数量限制
    @return 按访问次数排序的热点条目列表 *)
val get_hot_entries : int -> (string * int) list

(** {1 专门的艺术评估缓存} *)

(** 缓存评估结果
    @param poem_text 诗词文本
    @param result 评估结果 *)
val cache_evaluation_result : string -> cache_value -> unit

(** 获取缓存的评估结果
    @param poem_text 诗词文本
    @return 缓存的评估结果选项 *)
val get_cached_evaluation : string -> cache_value option

(** 缓存韵律分析结果
    @param poem_text 诗词文本
    @param rhyme_data 韵律分析数据 *)
val cache_rhyme_analysis : string -> cache_value -> unit

(** 获取缓存的韵律分析结果
    @param poem_text 诗词文本
    @return 缓存的韵律分析结果选项 *)
val get_cached_rhyme_analysis : string -> cache_value option

(** 缓存意境分析结果
    @param poem_text 诗词文本
    @param mood_data 意境分析数据 *)
val cache_mood_analysis : string -> cache_value -> unit

(** 获取缓存的意境分析结果
    @param poem_text 诗词文本
    @return 缓存的意境分析结果选项 *)
val get_cached_mood_analysis : string -> cache_value option

(** {1 缓存预热与维护} *)

(** 预热缓存，加载常用数据 *)
val warm_up_cache : unit -> unit

(** 清理缓存，根据当前策略删除过期或不常用的条目 *)
val cleanup_cache : unit -> unit

(** 优化缓存大小，根据访问模式自动调整缓存策略 *)
val optimize_cache_size : unit -> unit

(** {1 缓存导出和导入} *)

(** 导出缓存数据
    @return 格式化的缓存数据字符串 *)
val export_cache : unit -> string

(** 导入缓存数据
    @param data 要导入的缓存数据字符串 *)
val import_cache : string -> unit