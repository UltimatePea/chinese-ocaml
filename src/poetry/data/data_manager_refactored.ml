(** 重构后的统一数据管理器 - 模块化架构实现
    
    基于Delta代理批判性分析的架构修正，将原本589行的巨大文件
    重构为清晰的模块化架构，解决单一职责原则违反问题。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @refactored_from data_manager.ml (589 lines -> modular architecture)
    @fix_issue #1727 *)

(* 导入重构后的模块 *)
module Data_types = Poetry_data_core.Data_types
module Cache_manager = Poetry_data_managers.Cache_manager  
module Query_manager = Poetry_data_managers.Query_manager
module Source_manager = Poetry_data_managers.Source_manager

(* 重新导出核心类型以保持API兼容性 *)
open Data_types

(** {1 统一数据管理器公共接口} *)

(** {2 数据源管理接口} *)

(** 注册数据源 - 委托给Source_manager *)
let register_data_source = Source_manager.register_data_source

(** 注销数据源 - 委托给Source_manager *)
let unregister_data_source = Source_manager.unregister_data_source

(** 列出已注册数据源 - 委托给Source_manager *)
let list_registered_sources = Source_manager.list_registered_sources

(** 检查数据源是否已注册 - 委托给Source_manager *)
let is_source_registered = Source_manager.is_source_registered

(** {2 数据查询接口} *)

(** 查询数据 - 整合Query_manager和Source_manager *)
let query_data criteria = 
  Query_manager.query_data criteria Source_manager.load_from_source

(** 流式查询数据 - 整合Query_manager和Source_manager *)
let query_data_streaming criteria callback =
  Query_manager.query_data_streaming criteria callback Source_manager.load_from_source

(** 计算数据数量 - 整合Query_manager和Source_manager *)
let count_data criteria =
  Query_manager.count_data criteria Source_manager.load_from_source

(** 批量查询 - 整合Query_manager和Source_manager *)
let batch_query criteria_list =
  Query_manager.batch_query criteria_list Source_manager.load_from_source

(** {2 数据加载接口} *)

(** 加载所有数据 - 委托给Source_manager *)
let load_all_data = Source_manager.load_all_data

(** 选择性加载数据源 - 委托给Source_manager *)
let load_selected_sources = Source_manager.load_selected_sources

(** {2 缓存管理接口} *)

(** 更新缓存配置 - 委托给Cache_manager *)
let update_cache_config = Cache_manager.update_cache_config

(** 获取缓存配置 - 委托给Cache_manager *)
let get_cache_config = Cache_manager.get_cache_config

(** 获取缓存统计 - 委托给Cache_manager *)
let get_cache_statistics = Cache_manager.get_cache_statistics

(** 清空缓存 - 委托给Cache_manager *)
let clear_cache = Cache_manager.clear_cache

(** 缓存预热 - 委托给Cache_manager *)
let warmup_cache criteria_list = 
  Cache_manager.warmup_cache criteria_list query_data

(** {2 高性能查询接口} *)

module FastLookup = struct
  (** 构建索引 - 委托给Query_manager.FastLookup *)
  let build_index source_list =
    Query_manager.FastLookup.build_index source_list Source_manager.load_all_data

  (** 快速字符查找 - 委托给Query_manager.FastLookup *)
  let lookup_character = Query_manager.FastLookup.lookup_character

  (** 快速韵组查找 - 委托给Query_manager.FastLookup *)
  let lookup_group = Query_manager.FastLookup.lookup_group

  (** 快速韵类查找 - 委托给Query_manager.FastLookup *)
  let lookup_category = Query_manager.FastLookup.lookup_category

  (** 检查索引状态 - 委托给Query_manager.FastLookup *)
  let is_indexed = Query_manager.FastLookup.is_indexed

  (** 获取索引统计 - 委托给Query_manager.FastLookup *)
  let get_index_statistics = Query_manager.FastLookup.get_index_statistics
end

(** {2 数据完整性和验证接口} *)

(** 验证数据完整性 - 委托给Source_manager *)
let validate_data_integrity = Source_manager.validate_data_integrity

(** 检测数据冲突 - 委托给Source_manager *)
let detect_data_conflicts = Source_manager.detect_data_conflicts

(** 合并冲突数据 - 委托给Source_manager *)
let merge_conflicting_data = Source_manager.merge_conflicting_data

(** {2 统计和监控接口} *)

(** 获取数据统计信息 - 整合多个管理器的统计 *)
let get_data_statistics () =
  let cache_stats = Cache_manager.get_cache_statistics () in
  let query_stats = Query_manager.get_query_statistics () in
  let source_stats = Source_manager.get_data_source_statistics () in
  {
    cache_statistics = cache_stats;
    query_statistics = query_stats;
    source_statistics = source_stats;
  }

(** 获取数据源统计 - 委托给Source_manager *)
let get_source_statistics = Source_manager.get_source_statistics

(** 打印性能报告 - 整合所有管理器的报告 *)
let print_performance_report () =
  Printf.printf "\n=== Unified Data Manager Performance Report ===\n";
  
  (* 缓存统计 *)
  let cache_stats = Cache_manager.get_cache_statistics () in
  Printf.printf "\nCache Statistics:\n";
  Printf.printf "  Total queries: %d\n" cache_stats.total_queries;
  Printf.printf "  Cache hits: %d\n" cache_stats.cache_hits;
  Printf.printf "  Cache misses: %d\n" cache_stats.cache_misses;
  Printf.printf "  Hit rate: %.2f%%\n" (cache_stats.hit_rate *. 100.0);
  Printf.printf "  Cache size: %d\n" cache_stats.cache_size;
  
  (* 查询统计 *)
  let query_stats = Query_manager.get_query_statistics () in  
  Printf.printf "\nQuery Index Statistics:\n";
  Printf.printf "  Character index size: %d\n" query_stats.character_index_size;
  Printf.printf "  Group index size: %d\n" query_stats.group_index_size;
  Printf.printf "  Category index size: %d\n" query_stats.category_index_size;
  
  (* 数据源统计 *)
  Printf.printf "\nData Source Statistics:\n";
  Source_manager.print_performance_report ();
  
  Printf.printf "=============================================\n\n"

(** {2 兼容性和迁移支持} *)

module Compatibility = struct
  (** 向后兼容的旧接口 - 逐步废弃 *)
  
  (** @deprecated 使用 query_data 替代 *)
  let query_legacy criteria = query_data criteria
  
  (** @deprecated 使用 load_all_data 替代 *)
  let load_legacy () = load_all_data ()
  
  (** @deprecated 使用 get_cache_statistics 替代 *)
  let cache_info () = get_cache_statistics ()
end

(** {2 数据导入导出接口} *)

(** 导出数据
    @param criteria 查询条件
    @param format 导出格式
    @return 导出结果 *)
let export_data criteria ~format =
  match query_data criteria with
  | Success items -> (
      match format with
      | JSON ->
          let json_items = List.map (fun item ->
            Printf.sprintf 
              "{\"character\":\"%s\",\"category\":\"%s\",\"group\":\"%s\",\"metadata\":%s}"
              item.character
              (Obj.repr item.category |> Obj.tag |> string_of_int)
              (Obj.repr item.group |> Obj.tag |> string_of_int)
              (String.concat "," (List.map (fun (k,v) -> 
                Printf.sprintf "\"%s\":\"%s\"" k v) item.metadata))
          ) items in
          Success ("[" ^ String.concat "," json_items ^ "]")
      | CSV ->
          let csv_header = "character,category,group,metadata\n" in
          let csv_rows = List.map (fun item ->
            Printf.sprintf "%s,%d,%d,\"%s\""
              item.character
              (Obj.repr item.category |> Obj.tag)
              (Obj.repr item.group |> Obj.tag) 
              (String.concat ";" (List.map (fun (k,v) -> k^":"^v) item.metadata))
          ) items in
          Success (csv_header ^ String.concat "\n" csv_rows)
      | XML ->
          let xml_items = List.map (fun item ->
            Printf.sprintf 
              "<item><character>%s</character><category>%d</category><group>%d</group></item>"
              item.character
              (Obj.repr item.category |> Obj.tag)
              (Obj.repr item.group |> Obj.tag)
          ) items in
          Success ("<data>" ^ String.concat "" xml_items ^ "</data>")
    )
  | Error err -> Error err

(** 导入数据 - 简化版本
    @param source_id 数据源ID
    @param format 数据格式
    @param data 数据内容
    @return 导入结果 *)
let import_data _source_id ~format:_format _data =
  (* 简化版本的数据导入 - 实际实现需要根据格式解析数据 *)
  Error (Poetry_core.Poetry_errors.DataSourceError "Import not yet implemented in refactored version")

(** {1 综合统计信息类型} *)

type comprehensive_statistics = {
  cache_statistics : cache_statistics;
  query_statistics : Query_manager.index_statistics;
  source_statistics : Source_manager.data_source_statistics;
}

(** {1 初始化和清理} *)

(** 初始化数据管理器 - 设置默认配置 *)
let initialize ?(cache_config = default_cache_strategy) () =
  Cache_manager.update_cache_config cache_config;
  Printf.printf "Unified Data Manager initialized with modular architecture\n";
  Printf.printf "Cache enabled: %b, Max size: %d\n" 
    cache_config.enable_cache cache_config.max_cache_size

(** 清理所有状态 - 用于测试和重启 *)
let cleanup_all () =
  Cache_manager.clear_cache ();
  Query_manager.clear_all_indexes ();
  Source_manager.clear_all_sources ();
  Printf.printf "All data manager state cleared\n"

(** {1 架构信息} *)

(** 获取架构信息 - 用于调试和监控 *)
let get_architecture_info () =
  Printf.sprintf
    "Unified Data Manager - Modular Architecture\n\
     ├── Data Types Module: Core type definitions\n\
     ├── Cache Manager: LRU caching with TTL support\n\
     ├── Query Manager: Index-based querying with FastLookup\n\
     ├── Source Manager: Data source registration and loading\n\
     └── Main Interface: Unified API with backward compatibility\n\
     \n\
     Refactored from: 589-line monolithic file\n\
     Benefits: Single responsibility, better testability, cleaner architecture"