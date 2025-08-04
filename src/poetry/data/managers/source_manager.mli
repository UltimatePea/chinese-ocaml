(** 数据源管理器模块接口
 *
 * 此模块提供统一的数据源管理功能，支持多种数据源类型的连接、
 * 配置、监控和维护。
 *
 * 主要功能：
 * - 多种数据源支持
 * - 连接池管理
 * - 数据源健康监控
 * - 自动故障转移
 * - 负载均衡
 * - 数据同步管理
 *
 * @author Whisky, PR Worker
 *)

(** {1 数据源类型定义} *)

(** 数据源类型 *)
type source_type = 
  | FileSystem of string        (** 文件系统数据源 *)
  | Database of string * int    (** 数据库数据源（主机，端口） *)
  | WebAPI of string           (** Web API数据源 *)
  | Memory                     (** 内存数据源 *)
  | Network of string * int    (** 网络数据源（主机，端口） *)

(** 数据源状态 *)
type source_status = 
  | Active         (** 活跃状态 *)
  | Inactive       (** 非活跃状态 *)
  | Error of string (** 错误状态 *)
  | Maintenance    (** 维护状态 *)

(** 数据源配置 *)
type source_config = {
  source_id : string;                    (** 数据源ID *)
  source_type : source_type;             (** 数据源类型 *)
  connection_params : (string * string) list; (** 连接参数 *)
  timeout : float;                       (** 连接超时时间 *)
  retry_count : int;                     (** 重试次数 *)
  health_check_interval : float;         (** 健康检查间隔 *)
  priority : int;                        (** 优先级 *)
  metadata : (string * string) list;    (** 元数据 *)
}

(** 数据源信息 *)
type source_info = {
  config : source_config;               (** 配置信息 *)
  status : source_status;               (** 当前状态 *)
  last_active : float;                  (** 最后活跃时间 *)
  error_count : int;                    (** 错误次数 *)
  success_count : int;                  (** 成功次数 *)
  average_response_time : float;        (** 平均响应时间 *)
}

(** 连接池配置 *)
type pool_config = {
  max_connections : int;                (** 最大连接数 *)
  min_connections : int;                (** 最小连接数 *)
  connection_timeout : float;           (** 连接超时 *)
  idle_timeout : float;                 (** 空闲超时 *)
  max_lifetime : float;                 (** 连接最大生命周期 *)
}

(** {1 数据源管理} *)

(** 注册数据源
    @param config 数据源配置
    @return 注册是否成功 *)
val register_source : source_config -> bool

(** 注销数据源
    @param source_id 数据源ID
    @return 注销是否成功 *)
val unregister_source : string -> bool

(** 获取数据源信息
    @param source_id 数据源ID
    @return 数据源信息选项 *)
val get_source_info : string -> source_info option

(** 列出所有数据源
    @return 数据源ID列表 *)
val list_sources : unit -> string list

(** 更新数据源配置
    @param source_id 数据源ID
    @param config 新配置
    @return 更新是否成功 *)
val update_source_config : string -> source_config -> bool

(** {1 连接管理} *)

(** 建立连接
    @param source_id 数据源ID
    @return 连接是否成功 *)
val connect : string -> bool

(** 断开连接
    @param source_id 数据源ID
    @return 断开是否成功 *)
val disconnect : string -> bool

(** 测试连接
    @param source_id 数据源ID
    @return 连接测试结果 *)
val test_connection : string -> bool * string

(** 重新连接
    @param source_id 数据源ID
    @return 重连是否成功 *)
val reconnect : string -> bool

(** {1 连接池管理} *)

(** 配置连接池
    @param source_id 数据源ID
    @param pool_config 连接池配置 *)
val configure_connection_pool : string -> pool_config -> unit

(** 获取连接池状态
    @param source_id 数据源ID
    @return 连接池状态信息 *)
val get_pool_status : string -> (string * int) list

(** 清理空闲连接
    @param source_id 数据源ID
    @return 清理的连接数 *)
val cleanup_idle_connections : string -> int

(** 重置连接池
    @param source_id 数据源ID
    @return 重置是否成功 *)
val reset_connection_pool : string -> bool

(** {1 健康监控} *)

(** 启动健康检查
    @param source_id 数据源ID
    @return 启动是否成功 *)
val start_health_check : string -> bool

(** 停止健康检查
    @param source_id 数据源ID
    @return 停止是否成功 *)
val stop_health_check : string -> bool

(** 执行立即健康检查
    @param source_id 数据源ID
    @return 健康检查结果 *)
val immediate_health_check : string -> bool * string

(** 获取健康报告
    @param source_id 数据源ID
    @return 健康报告 *)
val get_health_report : string -> (string * string) list

(** {1 故障处理} *)

(** 设置故障转移规则
    @param primary_source_id 主数据源ID
    @param fallback_source_ids 备用数据源ID列表 *)
val setup_failover : string -> string list -> unit

(** 触发故障转移
    @param failed_source_id 失效的数据源ID
    @return 转移到的数据源ID选项 *)
val trigger_failover : string -> string option

(** 恢复主数据源
    @param primary_source_id 主数据源ID
    @return 恢复是否成功 *)
val restore_primary : string -> bool

(** 获取故障转移状态
    @return 故障转移状态报告 *)
val get_failover_status : unit -> (string * string) list

(** {1 负载均衡} *)

(** 配置负载均衡
    @param source_ids 数据源ID列表
    @param strategy 负载均衡策略（"round_robin", "weighted", "least_connections"） *)
val configure_load_balancing : string list -> string -> unit

(** 获取下一个数据源
    @return 数据源ID选项 *)
val get_next_source : unit -> string option

(** 报告响应时间
    @param source_id 数据源ID
    @param response_time 响应时间（毫秒） *)
val report_response_time : string -> float -> unit

(** 获取负载均衡统计
    @return 负载均衡统计信息 *)
val get_load_balancing_stats : unit -> (string * int) list

(** {1 数据同步} *)

(** 启动数据同步
    @param source_source_id 源数据源ID
    @param target_source_id 目标数据源ID
    @return 同步任务ID选项 *)
val start_data_sync : string -> string -> string option

(** 停止数据同步
    @param sync_task_id 同步任务ID
    @return 停止是否成功 *)
val stop_data_sync : string -> bool

(** 获取同步状态
    @param sync_task_id 同步任务ID
    @return 同步状态信息 *)
val get_sync_status : string -> (string * string) list

(** 列出所有同步任务
    @return 同步任务ID列表 *)
val list_sync_tasks : unit -> string list

(** {1 统计与监控} *)

(** 获取数据源统计
    @param source_id 数据源ID
    @return 统计信息 *)
val get_source_statistics : string -> (string * string) list

(** 获取性能指标
    @param source_id 数据源ID
    @param time_range 时间范围（秒）
    @return 性能指标列表 *)
val get_performance_metrics : string -> float -> (string * float) list

(** 生成监控报告
    @param source_ids 数据源ID列表选项（None表示所有数据源）
    @return 监控报告 *)
val generate_monitoring_report : string list option -> string

(** {1 配置管理} *)

(** 导出数据源配置
    @param source_id 数据源ID
    @return 配置JSON字符串 *)
val export_source_config : string -> string

(** 导入数据源配置
    @param config_json 配置JSON字符串
    @return 导入是否成功 *)
val import_source_config : string -> bool

(** 批量配置数据源
    @param configs 配置列表
    @return 成功配置的数据源ID列表 *)
val batch_configure_sources : source_config list -> string list

(** {1 事件处理} *)

(** 注册事件监听器
    @param event_type 事件类型（"connect", "disconnect", "error", "recover"）
    @param source_id 数据源ID选项（None表示所有数据源）
    @param callback 事件回调函数 *)
val register_event_listener : string -> string option -> (string -> string -> unit) -> unit

(** 移除事件监听器
    @param event_type 事件类型
    @param source_id 数据源ID选项 *)
val remove_event_listener : string -> string option -> unit

(** 触发自定义事件
    @param event_type 事件类型
    @param source_id 数据源ID
    @param event_data 事件数据 *)
val trigger_custom_event : string -> string -> string -> unit