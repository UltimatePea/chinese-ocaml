(** 查询管理器模块接口
    
    负责统一数据管理器的查询功能，包括索引构建、
    数据查询、流式查询和高性能查找。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @author Whisky, PR Worker - 负责接口修复
    @refactored_from data_manager.ml query functions
    @fix_issue #1727 *)

open Poetry_data_core.Data_types

(** {1 索引构建功能} *)

(** 重建字符索引
    @param data_list 数据项列表 *)
val rebuild_character_index : unified_data_item list -> unit

(** 重建韵组索引
    @param data_list 数据项列表 *)
val rebuild_group_index : unified_data_item list -> unit

(** 重建韵类索引
    @param data_list 数据项列表 *)
val rebuild_category_index : unified_data_item list -> unit

(** 重建所有索引
    @param data_list 数据项列表 *)
val rebuild_all_indexes : unified_data_item list -> unit

(** {1 核心查询功能} *)

(** 查询数据 - 公共接口
    @param criteria 查询条件
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果 *)
val query_data : query_criteria -> (data_source_id -> unified_data_item list data_result) -> unified_data_item list data_result

(** 流式查询数据 - 适用于大量数据的处理
    @param criteria 查询条件
    @param callback 处理每个数据项的回调函数
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果 *)
val query_data_streaming : query_criteria -> (unified_data_item -> unit) -> (data_source_id -> unified_data_item list data_result) -> unit data_result

(** 计算符合条件的数据数量
    @param criteria 查询条件
    @param get_from_source 从数据源获取数据的函数
    @return 数据数量 *)
val count_data : query_criteria -> (data_source_id -> unified_data_item list data_result) -> int data_result

(** {1 批量查询功能} *)

(** 批量查询多个条件
    @param criteria_list 查询条件列表
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果列表 *)
val batch_query : query_criteria list -> (data_source_id -> unified_data_item list data_result) -> (query_criteria * unified_data_item list data_result) list

(** 并行批量查询(如果支持的话)
    @param criteria_list 查询条件列表
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果列表 *)
val parallel_batch_query : query_criteria list -> (data_source_id -> unified_data_item list data_result) -> (query_criteria * unified_data_item list data_result) list

(** 获取查询管理器统计信息 *)
val get_query_statistics : unit -> index_statistics

(** 清理所有索引 *)
val clear_all_indexes : unit -> unit

(** {1 高性能查询模块} *)

module FastLookup : sig
  (** 构建高性能索引
      @param source_list 数据源列表
      @param load_all_data 加载所有数据的函数
      @return 构建结果 *)
  val build_index : data_source_id list -> (unit -> unified_data_item list data_result) -> unit data_result

  (** 快速字符查找
      @param char 要查找的字符
      @return 查找结果 *)
  val lookup_character : string -> unified_data_item option data_result

  (** 快速韵组查找
      @param group 要查找的韵组
      @return 查找结果 *)
  val lookup_group : string -> unified_data_item list data_result

  (** 快速韵类查找
      @param category 要查找的韵类
      @return 查找结果 *)
  val lookup_category : string -> unified_data_item list data_result

  (** 检查索引状态
      @param source_id 数据源ID
      @return 索引是否已构建 *)
  val is_indexed : data_source_id -> bool

  (** 获取索引统计信息
      @return 索引统计信息 *)
  val get_index_statistics : unit -> index_statistics
end