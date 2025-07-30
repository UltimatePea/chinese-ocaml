(** 统一韵律核心数据模块接口 - 整合版
    
    提供统一的韵律数据访问接口，整合原本分散在124个文件中的韵律数据。
    这是Poetry模块技术债务整合的核心接口。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 韵律数据统一整合版本
    @since 2025-07-30 - Fix #1797 Poetry模块优化 *)

open Poetry_core.Poetry_types

(** {1 核心数据结构} *)

type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  frequency : float;
  variants : string list;
}
(** 韵律条目定义 *)

type rhyme_group_data = {
  group : rhyme_group;
  ping_sheng_chars : string list;
  ze_sheng_chars : string list;
  shang_sheng_chars : string list;
  qu_sheng_chars : string list;
  ru_sheng_chars : string list;
}
(** 韵组数据结构 *)

(** {1 统一数据访问接口} *)

val get_rhyme_group_data : rhyme_group -> rhyme_group_data option
(** 根据韵组获取完整的韵组数据 *)

val find_character_rhyme : string -> (rhyme_group * rhyme_category) option
(** 根据字符查找对应的韵组和声调分类 *)

val are_rhyme_matched : string -> string -> bool
(** 验证两个字符是否属于同一韵组 *)

val get_all_characters_in_group : rhyme_group -> string list
(** 获取指定韵组的所有字符列表 *)

val get_total_character_count : unit -> int
(** 获取所有韵字的总数量 *)

val get_rhyme_statistics : unit -> int * (rhyme_group * int) list
(** 获取韵律统计信息：(总数, 各韵组字符数列表) *)

(** {1 向后兼容接口} *)

val an_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 安韵组数据 - 兼容原有API *)

val tian_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 天韵组数据 - 兼容原有API *)

val si_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 思韵组数据 - 兼容原有API *)

val yu_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 鱼韵组数据 - 兼容原有API *)

val feng_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 风韵组数据 - 兼容原有API *)

val hua_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 华韵组数据 - 兼容原有API *)

val jiang_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 江韵组数据 - 兼容原有API *)

val yue_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 月韵组数据 - 兼容原有API *)

val hui_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 汇韵组数据 - 兼容原有API *)

val qu_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 曲韵组数据 - 兼容原有API *)

val wang_rhyme_data : (string * rhyme_category * rhyme_group) list
(** 王韵组数据 - 兼容原有API *)