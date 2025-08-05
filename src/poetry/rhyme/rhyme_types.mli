(** 韵律模块统一类型定义接口 - Phase 1-A 整合版

    Phase 1-A 重构：移除重复类型定义，改为引用poetry_types_consolidated权威源。 消除技术债务，统一韵律类型系统。

    Author: Whisky, PR Worker Issue: #2158 - Phase 1-A 韵律系统整合 *)

(* Accessing consolidated types from parent poetry library *)
include module type of Poetry_types.Poetry_types_consolidated
(** Phase 1-A: 引用统一权威类型源 *)

(** {1 基础韵律类型 - 从权威源导入} *)

(** Phase 1-A: 向后兼容映射 *)
type tone_category = rhyme_category
(** 兼容原 tone_category，映射至 rhyme_category *)

(** 所有核心类型现从 Poetry_types_consolidated 导入：
    - rhyme_category (统一声调类型)
    - rhyme_group (统一韵组定义)
    - rhyme_character (统一字符信息)
    - query_result (统一查询结果)
    - rhyme_group_data (统一韵组数据) *)

(** Phase 1-A: 所有重复类型定义已移除，统一使用权威源
    - rhyme_group_data: 从 Poetry_types_consolidated 导入
    - query_result: 从 Poetry_types_consolidated 导入
    - rhyme_character: 从 Poetry_types_consolidated 导入 *)

type rhyme_statistics = {
  total_characters : int;
  total_groups : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  group_distribution : (rhyme_group * int) list;
  most_frequent_group : rhyme_group;
  least_frequent_group : rhyme_group;
}
(** 韵律统计信息 *)

(** {1 辅助函数} *)

val string_of_rhyme_group : rhyme_group -> string
val string_of_tone_category : tone_category -> string
val is_ze_sheng : tone_category -> bool
val all_rhyme_groups : rhyme_group list
val all_tone_categories : tone_category list

(** {1 创建函数} *)

val make_rhyme_character :
  ?variants:string list ->
  ?usage_freq:float ->
  ?is_common:bool ->
  ?pinyin:string option ->
  ?confidence:float ->
  string ->
  tone_category ->
  rhyme_group ->
  rhyme_character

val make_ping_char : string -> rhyme_group -> rhyme_character
val make_ze_char : string -> rhyme_group -> rhyme_character
