(** 韵律数据处理工具模块接口 - 简化版本
    
    修复 Issue #1463 架构问题的最小化实现：
    - 消除全局状态和缓存复杂性
    - 简化为纯函数式设计
    - 移除过度工程化 *)

(** 韵律分类 *)
type rhyme_category =
  | PingSheng  (* 平声韵 *)
  | ZeSheng    (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng    (* 去声韵 *)
  | RuSheng    (* 入声韵 *)

(** 韵律组 *)
type rhyme_group =
  | AnRhyme     | SiRhyme     | TianRhyme   | WangRhyme
  | QuRhyme     | YuRhyme     | HuaRhyme    | FengRhyme
  | YueRhyme    | XueRhyme    | JiangRhyme  | HuiRhyme
  | UnknownRhyme

(** 韵律数据条目 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_info : string option;
  usage_notes : string option;
}

(** 韵律文件配置信息 *)
type rhyme_file_config = {
  base_dir : string;
  file_extension : string;
  default_encoding : string;
}

(** JSON韵律数据结构 *)
type json_rhyme_data = {
  characters : string list;
  category : rhyme_category;
  group : rhyme_group;
  metadata : (string * string) list;
}

(** 字符组加载器类型 *)
type character_group_loader = string -> string list

(** 字符串转换函数 *)
val string_of_rhyme_category : rhyme_category -> string
val string_of_rhyme_group : rhyme_group -> string

(** 文件配置和路径处理 *)
val default_rhyme_config : rhyme_file_config
val build_rhyme_file_path : rhyme_file_config -> rhyme_category -> rhyme_group -> string
val find_rhyme_data_file : rhyme_file_config -> rhyme_category -> rhyme_group -> string option

(** JSON数据处理 *)
val parse_json_rhyme_data : string -> json_rhyme_data
val safe_load_json_file : string -> json_rhyme_data option

(** 字符组数据处理工具 *)
val create_character_group_loader : character_group_loader -> character_group_loader
val load_rhyme_character_groups : character_group_loader -> string list -> string list list

(** 韵律数据创建和验证 *)
val create_rhyme_entries : string list -> rhyme_category -> rhyme_group -> rhyme_entry list
val validate_rhyme_entry : rhyme_entry -> bool
val assemble_rhyme_data : string list list -> rhyme_category -> rhyme_group -> rhyme_entry list


(** 韵律数据分析和匹配 *)
val create_rhyme_matcher : rhyme_entry list -> (string -> rhyme_group option)
val create_rhyme_validator : rhyme_entry list -> (string -> bool)
val analyze_rhyme_data : rhyme_entry list -> string

(** 高级韵律数据操作工具 *)
val batch_load_rhyme_files : rhyme_file_config -> (rhyme_category * rhyme_group) list -> json_rhyme_data list
val load_rhyme_data : rhyme_file_config -> rhyme_category -> rhyme_group -> rhyme_entry list
val performance_report : rhyme_file_config -> string