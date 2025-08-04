(** 缓存事件系统模块接口
    
    此模块管理缓存事件的触发、监听和历史记录，
    为缓存系统提供完整的事件驱动支持。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_engine

(** {1 事件触发和管理} *)

(** 触发缓存事件
    @param event 要触发的缓存事件 *)
val fire_event : cache_event -> unit

(** 更新缓存统计信息
    @param hit 是否为缓存命中
    @param access_time 访问时间（可选） *)
val update_statistics : bool -> float option -> unit

(** {1 事件监听器管理} *)

(** 注册事件监听器
    @param listener 事件监听器函数
    @return 监听器ID *)
val register_event_listener : (cache_event -> unit) -> int

(** 注销事件监听器
    @param listener_id 监听器ID
    @return 是否成功注销 *)
val unregister_event_listener : int -> bool

(** {1 事件历史查询} *)

(** 获取最近的事件
    @param count 要获取的事件数量
    @return 最近的事件列表 *)
val get_recent_events : int -> cache_event list