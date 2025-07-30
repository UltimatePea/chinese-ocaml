(** 缓存存储操作模块接口
    
    此模块定义缓存系统的核心存储操作接口，包括存储、检索、
    删除和元数据管理等基本功能。所有缓存操作都通过此接口进行。
    
    ## 主要特性
    - 支持TTL (生存时间) 管理
    - 支持优先级分级存储
    - 支持标签化管理
    - 自动内存管理和驱逐策略
    - 线程安全的缓存操作
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

val store : string -> 'a -> ?priority:cache_priority -> ?ttl:float option -> ?tags:string list -> unit -> bool
(** 存储数据到缓存
    @param key 缓存键
    @param data 要缓存的数据
    @param priority 缓存优先级，默认为Normal
    @param ttl 生存时间（秒），None表示永不过期
    @param tags 标签列表，用于批量操作
    @return 存储是否成功 *)

val retrieve : string -> 'a cache_result
(** 从缓存检索数据
    @param key 缓存键
    @return 缓存结果：CacheHit of data | CacheMiss | CacheError of error *)

val exists : string -> bool
(** 检查缓存键是否存在
    @param key 缓存键
    @return 是否存在且未过期 *)

val delete : string -> bool
(** 删除缓存项
    @param key 缓存键
    @return 删除是否成功 *)

val update_ttl : string -> float -> bool
(** 更新缓存项的生存时间
    @param key 缓存键
    @param new_ttl 新的生存时间（秒）
    @return 更新是否成功 *)

val get_metadata : string -> cache_metadata option
(** 获取缓存项的元数据
    @param key 缓存键
    @return 元数据信息，包括创建时间、访问时间、大小等 *)