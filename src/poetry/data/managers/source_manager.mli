(** 数据源管理器模块接口
    
    负责统一数据管理器的数据源管理功能，包括数据源注册、
    数据加载、冲突检测和完整性验证。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @author Whisky, PR Worker - 负责接口修复
    @refactored_from data_manager.ml source management functions  
    @fix_issue #1727 *)

open Poetry_data_core.Data_types

(** {1 数据源注册管理} *)

(** 注册数据源
    @param source_id 数据源标识符
    @param loader 数据加载函数
    @param priority 优先级(默认0，数值越高优先级越高)
    @param description 数据源描述
    @return 注册结果 *)
val register_data_source : data_source_id -> (unit -> unified_data_item list data_result) -> ?priority:int -> string -> unit data_result

(** 注销数据源
    @param source_id 数据源标识符
    @return 注销结果 *)
val unregister_data_source : data_source_id -> unit data_result

(** 列出所有已注册的数据源
    @return 数据源列表 (source_id, description, priority) *)
val list_registered_sources : unit -> (data_source_id * string * int) list

(** 检查数据源是否已注册
    @param source_id 数据源标识符
    @return 是否已注册 *)
val is_source_registered : data_source_id -> bool

(** 获取数据源详细信息
    @param source_id 数据源标识符
    @return 数据源信息 *)
val get_source_info : data_source_id -> data_source_info data_result

(** {1 数据加载和合并} *)

(** 从指定数据源加载数据
    @param source_id 数据源标识符
    @return 数据加载结果 *)
val load_from_source : data_source_id -> unified_data_item list data_result

(** 加载所有数据源的数据，按优先级合并
    @return 合并后的数据列表 *)
val load_all_data : unit -> unified_data_item list data_result

(** 选择性加载数据源
    @param source_ids 要加载的数据源ID列表
    @return 加载结果 *)
val load_selected_sources : data_source_id list -> unified_data_item list data_result

(** {1 数据完整性和冲突检测} *)

(** 验证数据完整性
    @param source_list 要验证的数据源列表
    @return 验证结果 *)
val validate_data_integrity : data_source_id list -> unit data_result

(** 检测数据源之间的冲突
    @param source_list 要检查的数据源列表
    @return 冲突检测结果 *)
val detect_data_conflicts : data_source_id list -> (string * data_source_id * data_source_id) list data_result

(** 合并冲突数据
    @param resolve_conflict 冲突解决函数
    @param source_list 数据源列表
    @return 合并结果 *)
val merge_conflicting_data : resolve_conflict:(unified_data_item -> unified_data_item -> unified_data_item) -> data_source_id list -> unified_data_item list data_result

(** {1 统计和监控功能} *)

(** 获取数据源统计信息 *)
val get_data_source_statistics : unit -> source_statistics

(** 获取指定数据源的统计信息
    @param source_id 数据源标识符
    @return 统计信息 *)
val get_source_statistics : data_source_id -> single_source_statistics data_result

(** 性能报告生成 *)
val print_performance_report : unit -> unit

(** {1 清理和维护功能} *)

(** 清理所有数据源注册 *)
val clear_all_sources : unit -> unit

(** 重新加载所有数据源 *)
val reload_all_sources : unit -> unified_data_item list data_result