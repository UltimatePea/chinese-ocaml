(** 韵律数据处理统一工具模块接口 - 消除Poetry/Rhyme系统重复代码
    
    Phase 7 技术债务清理 - 韵律系统重复消除
    
    @author Beta, 代码审查代理
    @version 1.0
    @since 2025-07-27 - Fix #1429 *)

(** ======================================================================== 
    韵律数据类型定义
    ======================================================================== *)

(** 韵律分类 *)
type rhyme_category =
  | PingSheng  | ZeSheng   | ShangSheng | QuSheng   | RuSheng

(** 韵律组 *)
type rhyme_group =
  | AnRhyme    | SiRhyme   | TianRhyme  | WangRhyme | QuRhyme
  | YuRhyme    | HuaRhyme  | FengRhyme  | YueRhyme  | XueRhyme
  | JiangRhyme | HuiRhyme  | UnknownRhyme

(** 韵律数据条目 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_info : string option;
  usage_notes : string option;
}

(** ======================================================================== 
    数据文件查找和加载工具
    ======================================================================== *)

(** 韵律数据文件路径配置 *)
type rhyme_file_config = {
  base_path : string;
  ping_sheng_path : string;
  ze_sheng_path : string;
  fallback_paths : string list;
}

(** 默认韵律文件配置 *)
val default_rhyme_config : rhyme_file_config

(** 构建文件路径 *)
val build_rhyme_file_path : rhyme_file_config -> rhyme_category -> rhyme_group -> string

(** 韵律组名称转换 *)
val string_of_rhyme_group : rhyme_group -> string

(** 查找韵律数据文件 *)
val find_rhyme_data_file : rhyme_file_config -> rhyme_category -> rhyme_group -> string option

(** ======================================================================== 
    JSON数据解析工具
    ======================================================================== *)

(** JSON韵律数据结构 *)
type json_rhyme_data = {
  name : string;
  category : string;
  characters : string list;
  metadata : (string * string) list;
}

(** 解析JSON韵律数据 *)
val parse_json_rhyme_data : Yojson.Basic.t -> (json_rhyme_data, string) result

(** 批量加载JSON韵律文件 *)
val batch_load_rhyme_files : 
  rhyme_file_config -> 
  (rhyme_category * rhyme_group) list -> 
  json_rhyme_data list

(** ======================================================================== 
    字符组数据处理工具
    ======================================================================== *)

(** 字符组加载器类型 *)
type character_group_loader = string -> string list

(** 创建字符组加载器 *)
val create_character_group_loader : character_group_loader -> character_group_loader

(** 统一的字符组加载模式 *)
val load_rhyme_character_groups : character_group_loader -> string list -> string list list

(** 创建韵律条目 *)
val create_rhyme_entries : string list -> rhyme_category -> rhyme_group -> rhyme_entry list

(** 组装韵律数据 *)
val assemble_rhyme_data : string list list -> rhyme_category -> rhyme_group -> rhyme_entry list

(** ======================================================================== 
    韵律数据验证和清理工具
    ======================================================================== *)

(** 验证韵律条目 *)
val validate_rhyme_entry : rhyme_entry -> bool

(** 清理重复的韵律条目 *)
val deduplicate_rhyme_entries : rhyme_entry list -> rhyme_entry list

(** 韵律数据统计 *)
val analyze_rhyme_data : rhyme_entry list -> string

(** ======================================================================== 
    韵律数据缓存和性能优化
    ======================================================================== *)

(** 韵律数据缓存模块 *)
module RhymeCache : sig
  val get_cached : rhyme_category -> rhyme_group -> rhyme_entry list option
  val store_cached : rhyme_category -> rhyme_group -> rhyme_entry list -> string -> unit
  val clear_cache : unit -> unit
  val cache_info : unit -> string
end

(** 带缓存的韵律数据加载器 *)
val load_rhyme_data_with_cache : 
  rhyme_file_config -> 
  rhyme_category -> 
  rhyme_group -> 
  rhyme_entry list

(** ======================================================================== 
    高级韵律数据操作工具
    ======================================================================== *)

(** 韵律匹配器 *)
val create_rhyme_matcher : rhyme_entry list -> (string -> rhyme_group option)

(** 韵律验证器 *)
val create_rhyme_validator : rhyme_entry list -> (string -> bool)

(** 韵律分析报告 *)
val generate_rhyme_report : rhyme_entry list -> string