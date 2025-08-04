(** 数据缓存管理器模块接口
 *
 * 此模块提供通用的数据缓存管理功能，包括缓存策略管理、
 * 缓存生命周期控制、性能优化等。
 *
 * 主要功能：
 * - 多级缓存支持
 * - 缓存策略管理
 * - 自动过期机制
 * - 缓存统计监控
 * - 批量缓存操作
 * - 缓存持久化
 *
 * @author Whisky, PR Worker
 *)

(** {1 缓存类型定义} *)

(** 缓存条目 *)
type cache_entry = {
  key : string;              (** 缓存键 *)
  value : string;            (** 缓存值 *)
  created_at : float;        (** 创建时间 *)
  last_accessed : float;     (** 最后访问时间 *)
  access_count : int;        (** 访问次数 *)
  expiry_time : float option; (** 过期时间 *)
  metadata : (string * string) list; (** 元数据 *)
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_entries : int;       (** 总条目数 *)
  hit_count : int;           (** 命中次数 *)
  miss_count : int;          (** 未命中次数 *)
  hit_rate : float;          (** 命中率 *)
  total_size : int;          (** 总大小（字节） *)
  expired_entries : int;     (** 过期条目数 *)
}

(** 缓存策略 *)
type cache_policy = 
  | LRU of int              (** 最近最少使用，参数为最大条目数 *)
  | LFU of int              (** 最少使用频率，参数为最大条目数 *)
  | TTL of float            (** 生存时间，参数为秒数 *)
  | FIFO of int             (** 先进先出，参数为最大条目数 *)
  | Custom of (cache_entry list -> cache_entry list) (** 自定义清理函数 *)

(** 缓存配置 *)
type cache_config = {
  max_entries : int option;     (** 最大条目数 *)
  max_size : int option;        (** 最大大小（字节） *)
  default_ttl : float option;   (** 默认TTL（秒） *)
  policy : cache_policy;        (** 缓存策略 *)
  enable_statistics : bool;     (** 是否启用统计 *)
  auto_cleanup : bool;          (** 是否自动清理 *)
}

(** {1 基础缓存操作} *)

(** 初始化缓存管理器
    @param config 缓存配置
    @return 初始化是否成功 *)
val initialize : cache_config -> bool

(** 获取缓存值
    @param key 缓存键
    @return 缓存值选项 *)
val get : string -> string option

(** 设置缓存值
    @param key 缓存键
    @param value 缓存值
    @param ttl TTL选项（秒）
    @return 设置是否成功 *)
val set : string -> string -> float option -> bool

(** 删除缓存条目
    @param key 缓存键
    @return 删除是否成功 *)
val delete : string -> bool

(** 检查键是否存在
    @param key 缓存键
    @return 是否存在 *)
val exists : string -> bool

(** 清空所有缓存
    @return 清空是否成功 *)
val clear : unit -> bool

(** {1 批量操作} *)

(** 批量获取
    @param keys 键列表
    @return 键值对列表 *)
val multi_get : string list -> (string * string option) list

(** 批量设置
    @param key_values 键值对列表
    @param ttl TTL选项（秒）
    @return 成功设置的键列表 *)
val multi_set : (string * string) list -> float option -> string list

(** 批量删除
    @param keys 键列表
    @return 成功删除的键列表 *)
val multi_delete : string list -> string list

(** {1 缓存策略管理} *)

(** 设置缓存策略
    @param policy 新缓存策略 *)
val set_policy : cache_policy -> unit

(** 获取当前缓存策略
    @return 当前缓存策略 *)
val get_policy : unit -> cache_policy

(** 应用缓存策略（手动触发清理）
    @return 清理的条目数 *)
val apply_policy : unit -> int

(** {1 缓存监控与统计} *)

(** 获取缓存统计信息
    @return 缓存统计信息 *)
val get_statistics : unit -> cache_statistics

(** 重置统计信息 *)
val reset_statistics : unit -> unit

(** 获取热点数据
    @param limit 返回数量限制
    @return 热点键列表（按访问频率排序） *)
val get_hot_keys : int -> string list

(** 获取缓存条目详情
    @param key 缓存键
    @return 缓存条目选项 *)
val get_entry_details : string -> cache_entry option

(** {1 过期管理} *)

(** 设置条目过期时间
    @param key 缓存键
    @param ttl 生存时间（秒）
    @return 设置是否成功 *)
val expire : string -> float -> bool

(** 获取条目剩余TTL
    @param key 缓存键
    @return 剩余时间（秒）选项 *)
val ttl : string -> float option

(** 清理所有过期条目
    @return 清理的条目数 *)
val cleanup_expired : unit -> int

(** {1 持久化功能} *)

(** 保存缓存到文件
    @param filename 文件名
    @return 保存是否成功 *)
val save_to_file : string -> bool

(** 从文件加载缓存
    @param filename 文件名
    @return 加载是否成功 *)
val load_from_file : string -> bool

(** 导出缓存数据
    @return 导出的数据字符串 *)
val export_data : unit -> string

(** 导入缓存数据
    @param data 数据字符串
    @return 导入是否成功 *)
val import_data : string -> bool

(** {1 高级功能} *)

(** 预热缓存
    @param key_values 预热数据键值对列表 *)
val warm_up : (string * string) list -> unit

(** 获取缓存键列表
    @param pattern 键模式（支持通配符）
    @return 匹配的键列表 *)
val get_keys : string option -> string list

(** 获取缓存大小（字节）
    @return 缓存总大小 *)
val get_size : unit -> int

(** 设置缓存配置
    @param config 新配置 *)
val update_config : cache_config -> unit

(** 获取当前配置
    @return 当前缓存配置 *)
val get_config : unit -> cache_config

(** {1 事件回调} *)

(** 注册缓存事件回调
    @param event_type 事件类型（"hit", "miss", "expire", "evict"）
    @param callback 回调函数 *)
val register_callback : string -> (string -> unit) -> unit

(** 移除事件回调
    @param event_type 事件类型 *)
val remove_callback : string -> unit