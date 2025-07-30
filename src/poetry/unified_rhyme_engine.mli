(** 统一韵律引擎接口 - 核心功能整合 Phase 2.2
    
    此模块提供统一的韵律处理接口，整合了原本分散在多个模块中的功能。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - Phase 2.2 核心引擎统一版本
    @since 2025-07-30
    @fix_issue #1755 *)

(** {1 统一韵律数据类型定义} *)

type unified_rhyme_entry = {
  character : string;
  category : Poetry_core.Poetry_types.rhyme_category;
  group : Poetry_core.Poetry_types.rhyme_group;
  variants : string list;
  frequency : float;
}

type unified_rhyme_group = {
  group_id : Poetry_core.Poetry_types.rhyme_group;
  group_name : string;
  entries : unified_rhyme_entry list;
  description : string;
}

type database_stats = {
  total_characters : int;
  total_groups : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
}

type unified_rhyme_database = {
  version : string;
  groups : unified_rhyme_group list;
  index : (string, unified_rhyme_entry) Hashtbl.t;
  stats : database_stats;
}

(** {2 向后兼容类型重导出} *)

type rhyme_data_entry = Rhyme_core_types.rhyme_data_entry = {
  character : string;
  category : Poetry_core.Poetry_types.rhyme_category;
  group : Poetry_core.Poetry_types.rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type rhyme_group_data = Rhyme_core_types.rhyme_group_data = {
  group_name : Poetry_core.Poetry_types.rhyme_group;
  group_description : string;
  entries : rhyme_data_entry list;
  example_poems : string list;
}

(** {3 核心韵律查找和检测功能} *)

val find_rhyme_info :
  string -> (Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) option
(** 统一的韵律信息查找函数
    @param char 要查找的字符
    @return 韵类和韵组的组合，如果未找到则返回None *)

val detect_rhyme_category : string -> Poetry_core.Poetry_types.rhyme_category
(** 检测字符的韵类
    @param char 要检测的字符
    @return 韵类，如果无法检测则返回PingSheng作为默认值 *)

val detect_rhyme_group : string -> Poetry_core.Poetry_types.rhyme_group
(** 检测字符的韵组
    @param char 要检测的字符
    @return 韵组，如果无法检测则返回UnknownRhyme *)

val detect_rhyme_category_by_string : string -> Poetry_core.Poetry_types.rhyme_category
(** 字符韵类检测 - 兼容接口 *)

val get_rhyme_characters : Poetry_core.Poetry_types.rhyme_group -> string list
(** 获取韵组包含的所有字符
    @param group 韵组
    @return 字符列表 *)

(** {4 韵律匹配算法} *)

val check_rhyme_match : string -> string -> bool
(** 检查两个字符是否押韵
    @param char1 第一个字符
    @param char2 第二个字符
    @return 是否押韵 *)

val validate_rhyme_pattern : string list -> bool
(** 检查字符列表是否形成有效的韵脚模式
    @param chars 字符列表
    @return 韵律匹配结果 *)

(** {5 韵律验证功能} *)

val detect_rhyme_group_char : char -> Poetry_core.Poetry_types.rhyme_group
(** 字符韵律检测辅助函数 *)

val detect_rhyme_category_char : char -> Poetry_core.Poetry_types.rhyme_category

val analyze_verse_chars :
  string ->
  (char * Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) list
(** 分析诗句字符的韵律信息
    @param verse 诗句
    @return 字符韵律分析结果列表 *)

val extract_verse_rhyme_info : string list -> char list * Poetry_core.Poetry_types.rhyme_group list
(** 提取诗句的韵脚和韵组信息
    @param verses 诗句列表
    @return (韵脚字符列表, 韵组列表) *)

val validate_verses_rhyme : string list -> bool
(** 验证诗句列表的韵律一致性
    @param verses 诗句列表
    @return 韵律验证结果 *)

(** {6 兼容性接口} *)

val make_entry :
  string ->
  Poetry_core.Poetry_types.rhyme_category ->
  Poetry_core.Poetry_types.rhyme_group ->
  ?variants:string list ->
  ?frequency:float ->
  unit ->
  rhyme_data_entry
(** 重导出构建辅助函数 *)

val make_group_entries :
  Poetry_core.Poetry_types.rhyme_category ->
  Poetry_core.Poetry_types.rhyme_group ->
  string list ->
  rhyme_data_entry list

val an_rhyme_data : rhyme_group_data
(** 重导出所有韵组数据 *)

val si_rhyme_data : rhyme_group_data
val tian_rhyme_data : rhyme_group_data
val wang_rhyme_data : rhyme_group_data
val qu_rhyme_data : rhyme_group_data
val yu_rhyme_data : rhyme_group_data
val hua_rhyme_data : rhyme_group_data
val feng_rhyme_data : rhyme_group_data
val yue_rhyme_data : rhyme_group_data
val jiang_rhyme_data : rhyme_group_data
val hui_rhyme_data : rhyme_group_data

val all_rhyme_groups : rhyme_group_data list
(** 所有韵组数据的统一集合 *)

(** {7 统一引擎状态管理} *)

val engine_version : string
(** 引擎版本信息 *)

val get_engine_stats : unit -> database_stats
(** 引擎统计信息 *)

val engine_health_check : unit -> bool
(** 引擎健康检查 *)

(** {8 附加功能函数} - 为其他模块提供的兼容函数 *)

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : Poetry_core.Poetry_types.rhyme_group;
  rhyme_category : Poetry_core.Poetry_types.rhyme_category;
  char_analysis :
    (char * Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) list;
}
(** 韵律分析报告类型 - 兼容性定义 *)

val generate_rhyme_report : string -> rhyme_analysis_report
(** 生成韵律报告 - 兼容性函数 *)

val get_rhyme_group_data : Poetry_core.Poetry_types.rhyme_group -> rhyme_group_data option
(** 获取韵组数据 - 兼容性函数 *)

val find_rhyming_characters : char -> string list
(** 查找押韵字符 - 兼容性函数 *)

val get_all_entries : unit -> rhyme_data_entry list
(** 获取所有条目 - 兼容性函数 *)

val check_rhyme : char -> char -> bool
(** 简单押韵检查 - 兼容性函数 *)

val get_chars_by_category : Poetry_core.Poetry_types.rhyme_category -> string list
(** 按韵类获取字符 - 兼容性函数 *)

val get_all_groups : unit -> Poetry_core.Poetry_types.rhyme_group list
(** 获取所有韵组 - 兼容性函数 *)

val safe_find_rhyme_info :
  string ->
  (Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) option option
(** 安全查找韵律信息 - 兼容性函数 *)

val find_char_rhyme_info :
  string -> (Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) option
(** 查找字符韵律信息 - 兼容性函数 *)
