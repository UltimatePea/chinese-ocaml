(** 统一数据加载器扩展模块接口 - Phase 2: 外化数据支持
    
    此模块扩展unified_data_loader，提供externalized_data_loader的兼容性接口，
    实现Phase 2数据整合目标。
    
    @author Beta, 代码审查专员
    @version 2.0 - Phase 2 外化数据整合
    @since 2025-07-29
    @fix_issue #1732 *)

(** {1 兼容性错误类型} *)

(** 外化数据错误类型 - 向后兼容 *)
type externalized_data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception ExternalizedDataError of externalized_data_error

(** {1 错误处理} *)

val format_error : externalized_data_error -> string
(** 格式化错误信息
    @param error 错误类型
    @return 格式化的错误消息字符串 *)

(** {1 兼容性接口 - 与externalized_data_loader保持一致} *)

val get_nature_nouns : unit -> string list
(** 获取自然名词列表
    @return 自然名词字符串列表 *)

val get_geography_politics_nouns : unit -> string list
(** 获取地理政治名词列表
    @return 地理政治名词字符串列表 *)

val get_person_relation_nouns : unit -> string list
(** 获取人物关系名词列表
    @return 人物关系名词字符串列表 *)

val get_social_status_nouns : unit -> string list
(** 获取社会地位名词列表
    @return 社会地位名词字符串列表 *)

val get_tools_objects_nouns : unit -> string list
(** 获取工具物品名词列表
    @return 工具物品名词字符串列表 *)

val get_building_place_nouns : unit -> string list
(** 获取建筑场所名词列表
    @return 建筑场所名词字符串列表 *)

val validate_data_integrity : unit -> bool
(** 验证数据完整性
    @return 验证结果，成功时返回true *)

(** {1 扩展数据结构} *)

(** 所有诗词数据结构 - 包含词类和声调数据 *)
type all_poetry_data = {
  nature_nouns : string list;
  geography_politics_nouns : string list;
  person_relation_nouns : string list;
  social_status_nouns : string list;
  tools_objects_nouns : string list;
  building_place_nouns : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}

(** {1 统一接口} *)

val load_all_word_class_data : unit -> all_poetry_data
(** 加载所有词类数据 - 包含声调数据
    @return 包含所有词类和声调数据的结构 *)

(** {1 性能优化} *)

val warm_word_class_cache : unit -> unit
(** 预热词类数据缓存
    预加载所有常用词类数据到缓存中 *)

val get_word_class_stats : unit -> (string * int) list
(** 获取词类数据统计信息
    @return (类别名称, 词汇数量) 列表 *)