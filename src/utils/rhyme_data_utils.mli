(** 韵律数据处理统一工具模块接口 - 重构优化版本
    
    本模块经过长函数重构优化，使用分离的子模块提升性能。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 韵律配置模块优化 *)

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
    文件配置和查找 - 从优化的子模块重导出
    ======================================================================== *)

val default_rhyme_config : rhyme_file_config
val string_of_rhyme_category : rhyme_category -> string
val string_of_rhyme_group : rhyme_group -> string
val build_rhyme_file_path : rhyme_file_config -> rhyme_category -> rhyme_group -> string
val find_rhyme_data_file : rhyme_file_config -> rhyme_category -> rhyme_group -> string option
val batch_build_file_paths : rhyme_file_config -> (rhyme_category * rhyme_group) list -> (rhyme_category * rhyme_group * string) list
val validate_config : rhyme_file_config -> bool
val config_summary : rhyme_file_config -> string

(** ======================================================================== 
    JSON解析 - 从优化的子模块重导出
    ======================================================================== *)

val parse_json_rhyme_data : Yojson.Basic.t -> (json_rhyme_data, string) result
val batch_parse_json_data : Yojson.Basic.t list -> json_rhyme_data list * string list
val safe_load_json_file : string -> (Yojson.Basic.t, string) result
val batch_load_rhyme_files : rhyme_file_config -> (rhyme_category * rhyme_group) list -> json_rhyme_data list
val validate_json_rhyme_data : json_rhyme_data -> bool
val filter_valid_json_data : json_rhyme_data list -> json_rhyme_data list
val json_data_summary : json_rhyme_data -> string
val batch_json_summary : json_rhyme_data list -> string

(** ======================================================================== 
    字符组数据处理工具
    ======================================================================== *)

type character_group_loader = string -> string list

val create_character_group_loader : character_group_loader -> character_group_loader
val load_rhyme_character_groups : character_group_loader -> string list -> string list list
val assemble_rhyme_data : string list list -> rhyme_category -> rhyme_group -> rhyme_entry list

(** ======================================================================== 
    数据验证和分析 - 从缓存模块重导出
    ======================================================================== *)

val create_rhyme_entries : string list -> rhyme_category -> rhyme_group -> rhyme_entry list
val validate_rhyme_entry : rhyme_entry -> bool
val deduplicate_rhyme_entries : rhyme_entry list -> rhyme_entry list
val analyze_rhyme_data : rhyme_entry list -> string
val create_rhyme_matcher : rhyme_entry list -> (string -> rhyme_group option)
val create_rhyme_validator : rhyme_entry list -> (string -> bool)
val generate_rhyme_report : rhyme_entry list -> string

(** ======================================================================== 
    缓存和性能优化
    ======================================================================== *)

module RhymeCache : sig
  val get_cached : rhyme_category -> rhyme_group -> rhyme_entry list option
  val store_cached : rhyme_category -> rhyme_group -> rhyme_entry list -> string -> unit
  val clear_cache : unit -> unit
  val get_cache_stats : unit -> cache_stats
  val cache_info : unit -> string
  val warm_up_cache : rhyme_file_config -> (rhyme_category * rhyme_group) list -> unit
end

val load_rhyme_data_with_cache : rhyme_file_config -> rhyme_category -> rhyme_group -> rhyme_entry list
val batch_load_with_cache : rhyme_file_config -> (rhyme_category * rhyme_group) list -> (rhyme_category * rhyme_group * rhyme_entry list) list

(** ======================================================================== 
    高级操作和性能优化
    ======================================================================== *)

val common_ping_sheng_groups : (rhyme_category * rhyme_group) list
val common_ze_sheng_groups : (rhyme_category * rhyme_group) list
val warm_up_common_rhymes : rhyme_file_config -> unit
val performance_report : unit -> string