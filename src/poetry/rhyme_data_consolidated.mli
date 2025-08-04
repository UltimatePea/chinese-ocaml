(** 韵律数据整合模块接口 - 真实文件合并整合
    
    此模块接口定义了整合后的韵律数据系统，通过真正的代码合并
    替代了12个分散的韵组数据文件，实现文件数量的实际减少。
    
    **Author: Whisky, PR Worker** - 基于Papa战略指导的真实整合
    **Consolidation**: 12个独立文件 → 1个统一文件 (净减少11个文件)
    
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
(** 统一创建韵组数据的函数
    @param rhyme_type 韵组类型
    @param description 韵组描述
    @param ping_chars 平声字列表
    @param ze_chars 仄声字列表 *)

(** {1 韵组数据访问} *)

val an_rhyme_data : rhyme_group_data
(** 安韵组数据 *)

val feng_rhyme_data : rhyme_group_data
(** 风韵组数据 *)

val hua_rhyme_data : rhyme_group_data
(** 花韵组数据 *)

val hui_rhyme_data : rhyme_group_data
(** 灰韵组数据 *)

val jiang_rhyme_data : rhyme_group_data
(** 江韵组数据 *)

val qu_rhyme_data : rhyme_group_data
(** 去韵组数据 *)

val si_rhyme_data : rhyme_group_data
(** 思韵组数据 *)

val tian_rhyme_data : rhyme_group_data
(** 天韵组数据 *)

val wang_rhyme_data : rhyme_group_data
(** 望韵组数据 *)

val yu_rhyme_data : rhyme_group_data
(** 鱼韵组数据 *)

val yue_rhyme_data : rhyme_group_data
(** 月韵组数据 *)

(** {1 韵组数据库操作} *)

val all_rhyme_groups_data : rhyme_group_data list
(** 所有韵组数据的统一列表 *)

val find_rhyme_group_data : rhyme_group -> rhyme_group_data option
(** 查找指定韵组的数据 *)

val get_rhyme_group_characters : rhyme_group -> string list
(** 获取指定韵组的所有字符列表 *)

val is_character_in_rhyme_group : string -> rhyme_group -> bool
(** 检查字符是否属于指定韵组 *)

val get_consolidation_stats : unit -> string
(** 获取整合统计信息，显示文件减少效果 *)