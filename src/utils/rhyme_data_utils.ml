(** 韵律数据处理统一工具模块 - 重构优化版本
    
    本模块经过长函数重构优化，使用分离的子模块提升性能：
    - Rhyme_file_config: 文件配置和查找（查找表优化）
    - Rhyme_json_parser: JSON解析和错误处理
    - Rhyme_data_cache: 高性能缓存和内存管理
    
    Phase 2.1 长函数重构 - 韵律配置模块优化
    
    @author Alpha, 主工作代理
    @version 2.0
    @since 2025-07-27 - Fix #1460 Phase 2.1 *)

(* 模块引用，使用完全限定名称以避免名称冲突 *)
open Common_patterns
open Printf

(** ======================================================================== 
    类型重导出 - 从专门的子模块导入
    ======================================================================== *)

(* 类型从 Rhyme_file_config 重导出 *)
type rhyme_category = Rhyme_file_config.rhyme_category =
  | PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng

type rhyme_group = Rhyme_file_config.rhyme_group =
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
  | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | XueRhyme 
  | JiangRhyme | HuiRhyme | UnknownRhyme

type rhyme_file_config = Rhyme_file_config.rhyme_file_config

(* 类型从 Rhyme_json_parser 重导出 *)
type json_rhyme_data = Rhyme_json_parser.json_rhyme_data

(* 类型从 Rhyme_data_cache 重导出 *)
type rhyme_entry = Rhyme_data_cache.rhyme_entry
type cache_stats = Rhyme_data_cache.cache_stats

(** ======================================================================== 
    文件配置和查找 - 使用优化的子模块
    ======================================================================== *)

(* 从 Rhyme_file_config 重导出函数 *)
let default_rhyme_config = Rhyme_file_config.default_rhyme_config
let string_of_rhyme_category = Rhyme_file_config.string_of_rhyme_category
let string_of_rhyme_group = Rhyme_file_config.string_of_rhyme_group
let build_rhyme_file_path = Rhyme_file_config.build_rhyme_file_path
let find_rhyme_data_file = Rhyme_file_config.find_rhyme_data_file
let batch_build_file_paths = Rhyme_file_config.batch_build_file_paths
let validate_config = Rhyme_file_config.validate_config
let config_summary = Rhyme_file_config.config_summary

(** ======================================================================== 
    JSON解析 - 使用优化的子模块
    ======================================================================== *)

(* 从 Rhyme_json_parser 重导出函数 *)
let parse_json_rhyme_data = Rhyme_json_parser.parse_json_rhyme_data
let batch_parse_json_data = Rhyme_json_parser.batch_parse_json_data
let safe_load_json_file = Rhyme_json_parser.safe_load_json_file
let batch_load_rhyme_files = Rhyme_json_parser.batch_load_rhyme_files
let validate_json_rhyme_data = Rhyme_json_parser.validate_json_rhyme_data
let filter_valid_json_data = Rhyme_json_parser.filter_valid_json_data
let json_data_summary = Rhyme_json_parser.json_data_summary
let batch_json_summary = Rhyme_json_parser.batch_json_summary

(** ======================================================================== 
    字符组数据处理工具 - 优化版本
    ======================================================================== *)

(** 字符组加载器类型 *)
type character_group_loader = string -> string list

(** 创建字符组加载器 - 使用更好的错误处理 *)
let create_character_group_loader base_loader =
  fun group_name ->
    try base_loader group_name
    with exn ->
      print_warning (sprintf "加载字符组失败 %s: %s" group_name (Printexc.to_string exn));
      []

(** 统一的字符组加载模式 *)
let load_rhyme_character_groups loader group_names =
  load_character_groups loader group_names

(** 组装韵律数据 - 使用缓存模块的函数 *)
let assemble_rhyme_data character_groups category group =
  List.concat (List.map (fun chars -> Rhyme_data_cache.create_rhyme_entries chars category group) character_groups)

(** ======================================================================== 
    数据验证和分析 - 使用缓存模块的优化函数
    ======================================================================== *)

(* 从 Rhyme_data_cache 重导出验证和分析函数 *)
let create_rhyme_entries = Rhyme_data_cache.create_rhyme_entries
let validate_rhyme_entry = Rhyme_data_cache.validate_rhyme_entry
let deduplicate_rhyme_entries = Rhyme_data_cache.deduplicate_rhyme_entries
let analyze_rhyme_data = Rhyme_data_cache.analyze_rhyme_data
let create_rhyme_matcher = Rhyme_data_cache.create_rhyme_matcher
let create_rhyme_validator = Rhyme_data_cache.create_rhyme_validator
let generate_rhyme_report = Rhyme_data_cache.generate_rhyme_report

(** ======================================================================== 
    缓存和性能优化 - 使用优化的缓存模块
    ======================================================================== *)

(* 重导出缓存模块 *)
module RhymeCache = Rhyme_data_cache.RhymeCache

(** 带缓存的韵律数据加载器 - 性能优化版本 *)
let load_rhyme_data_with_cache config category group =
  match RhymeCache.get_cached category group with
  | Some data -> 
      print_debug_info (sprintf "使用缓存的韵律数据: %s/%s" 
        (string_of_rhyme_category category) (string_of_rhyme_group group));
      data
  | None ->
      print_debug_info (sprintf "加载韵律数据: %s/%s" 
        (string_of_rhyme_category category) (string_of_rhyme_group group));
      let data = batch_load_rhyme_files config [(category, group)] in
      let entries = List.concat (List.map (fun json_data -> 
        Rhyme_data_cache.create_rhyme_entries json_data.Rhyme_json_parser.characters category group
      ) data) in
      RhymeCache.store_cached category group entries "";
      entries

(** 批量加载和缓存韵律数据 - 新增高性能函数 *)
let batch_load_with_cache config category_group_pairs =
  List.map (fun (category, group) ->
    (category, group, load_rhyme_data_with_cache config category group)
  ) category_group_pairs

(** ======================================================================== 
    高级韵律数据操作工具 - 重构优化完成
    ======================================================================== *)

(** 常用韵律组合定义 - 性能优化 *)
let common_ping_sheng_groups = [
  (PingSheng, FengRhyme);
  (PingSheng, YuRhyme);
  (PingSheng, HuaRhyme);
]

let common_ze_sheng_groups = [
  (ZeSheng, YueRhyme);
  (ZeSheng, JiangRhyme);
  (ZeSheng, HuiRhyme);
]

(** 预热缓存 - 为常用数据组合预加载 *)
let warm_up_common_rhymes config =
  let all_common = common_ping_sheng_groups @ common_ze_sheng_groups in
  RhymeCache.warm_up_cache config all_common

(** 性能统计报告 *)
let performance_report () =
  let cache_info = RhymeCache.cache_info () in
  let config_info = config_summary default_rhyme_config in
  sprintf "韵律系统性能报告:\n%s\n%s" cache_info config_info