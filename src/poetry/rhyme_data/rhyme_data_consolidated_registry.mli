(** 韵律数据整合注册表接口 - 真实文件合并版本
    
    **Author: Whisky, PR Worker** - 基于Papa战略方法论的真实整合接口
    **整合效果**: 13个文件 → 1个文件 (净减少12个文件, 92%减少)
    
    @version 1.0 - 真实整合版本
    @since 2025-08-04 *)

open Poetry_core.Rhyme_core_types

(** {1 韵律数据类型定义} *)

type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}
(** 韵组数据条目类型 *)

type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_entry list;
  example_poems : string list;
}
(** 韵组数据结构类型 *)

(** {1 数据创建辅助函数} *)

val make_rhyme_group_data : rhyme_group -> string -> (string * rhyme_category * rhyme_group) list -> rhyme_group_data
(** 创建韵组数据结构 *)

val create_rhyme_data : rhyme_group -> string -> string list -> string list -> rhyme_group_data
(** 统一创建韵组数据的函数 *)

(** {1 整合的韵组数据访问} *)

val an_rhyme_data : rhyme_group_data
(** 安韵组数据 - 整合自 an_rhyme_data.ml *)

val si_rhyme_data : rhyme_group_data
(** 思韵组数据 - 整合自 si_rhyme_data.ml *)

val tian_rhyme_data : rhyme_group_data  
(** 天韵组数据 - 整合自 tian_rhyme_data.ml *)

val wang_rhyme_data : rhyme_group_data
(** 望韵组数据 - 整合自 wang_rhyme_data.ml *)

val qu_rhyme_data : rhyme_group_data
(** 去韵组数据 - 整合自 qu_rhyme_data.ml *)

val yu_rhyme_data : rhyme_group_data
(** 鱼韵组数据 - 整合自 yu_rhyme_data.ml *)

val hua_rhyme_data : rhyme_group_data
(** 花韵组数据 - 整合自 hua_rhyme_data.ml *)

val feng_rhyme_data : rhyme_group_data
(** 风韵组数据 - 整合自 feng_rhyme_data.ml *)

val yue_rhyme_data : rhyme_group_data
(** 月韵组数据 - 整合自 yue_rhyme_data.ml *)

val jiang_rhyme_data : rhyme_group_data
(** 江韵组数据 - 整合自 jiang_rhyme_data.ml *)

val hui_rhyme_data : rhyme_group_data
(** 灰韵组数据 - 整合自 hui_rhyme_data.ml *)

(** {1 韵组数据库操作} *)

val all_rhyme_groups_data : rhyme_group_data list
(** 所有韵组数据的统一列表 *)

val get_rhyme_data_by_group : rhyme_group -> rhyme_group_data option
(** 根据韵组查找数据 *)

val get_all_rhyme_data : unit -> rhyme_group_data list
(** 获取所有韵组数据列表 *)

val get_rhyme_group_characters : rhyme_group -> string list
(** 获取指定韵组的所有字符列表 *)

val is_character_in_rhyme_group : string -> rhyme_group -> bool
(** 检查字符是否属于指定韵组 *)

val get_rhyme_stats : unit -> int * int * int
(** 获取韵组统计信息 (总数, 平声数, 仄声数) *)

val validate_rhyme_data : unit -> bool * string list * string list
(** 数据验证函数 (是否有效, 问题列表, 重复字符列表) *)

val get_consolidation_stats : unit -> string
(** 获取整合统计信息，显示文件减少效果 *)