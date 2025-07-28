(** 韵律数据统一核心模块接口 - 骆言诗词编程特性

    此模块是技术债务整合的核心成果，统一管理所有韵律数据，消除项目中100+文件的数据重复问题。

    重构目标：
    - 消除20+个重复的韵律数据文件（减少70%重复）
    - 提供统一的数据访问接口
    - 降低编译时间25%和维护复杂度
    - 保持所有诗词分析功能正常工作

    Author: Alpha, 主要工作代理
    @version 4.0 - 统一重构版本
    @since 2025-07-27 - Poetry模块技术债务专项整合 - Fix #1516 *)

open Poetry_types_consolidated

(** {1 韵律数据类型定义} *)

type rhyme_data_entry = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  variants : string list;  (** 异体字或相关字 *)
  usage_frequency : float;  (** 使用频度 *)
}
(** 韵律数据条目：基础数据单元 *)

type rhyme_group_data = {
  group_name : rhyme_group;  (** 韵组名称 *)
  group_description : string;  (** 韵组描述 *)
  entries : rhyme_data_entry list;  (** 该韵组所有条目 *)
  example_poems : string list;  (** 典型用例诗句 *)
}
(** 韵组数据：某个韵组的完整信息 *)

(** {1 韵律数据构建辅助函数} *)

val make_entry :
  string ->
  rhyme_category ->
  rhyme_group ->
  ?variants:string list ->
  ?frequency:float ->
  unit ->
  rhyme_data_entry
(** 创建韵律数据条目的辅助函数 *)

val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_data_entry list
(** 创建某个韵组字符列表的辅助函数 *)

(** {2 统一韵律数据} *)

val an_rhyme_data : rhyme_group_data
(** 安韵组数据 *)

val si_rhyme_data : rhyme_group_data
(** 思韵组数据 *)

val tian_rhyme_data : rhyme_group_data
(** 天韵组数据 *)

val wang_rhyme_data : rhyme_group_data
(** 望韵组数据 *)

val qu_rhyme_data : rhyme_group_data
(** 去韵组数据 *)

val yu_rhyme_data : rhyme_group_data
(** 鱼韵组数据 *)

val hua_rhyme_data : rhyme_group_data
(** 花韵组数据 *)

val feng_rhyme_data : rhyme_group_data
(** 风韵组数据 *)

val yue_rhyme_data : rhyme_group_data
(** 月韵组数据 *)

val jiang_rhyme_data : rhyme_group_data
(** 江韵组数据 *)

val hui_rhyme_data : rhyme_group_data
(** 灰韵组数据 *)

(** {3 韵律数据集合} *)

val all_rhyme_groups : rhyme_group_data list
(** 所有韵组数据的统一集合 *)

val all_rhyme_entries : rhyme_data_entry list
(** 扁平化的所有韵律数据条目 *)

(** {4 查询接口函数} *)

val find_char_rhyme_info : string -> rhyme_data_entry option
(** 根据字符查找韵律信息 *)

val get_rhyme_group_data : rhyme_group -> rhyme_group_data option
(** 根据韵组获取所有数据 *)

val get_chars_by_category : rhyme_category -> string list
(** 根据韵类获取所有字符 *)

val get_chars_by_group : rhyme_group -> string list
(** 根据韵组获取所有字符 *)

val get_statistics : unit -> string
(** 获取统计信息 *)

(** {5 向后兼容性接口} *)

val get_legacy_rhyme_data : unit -> rhyme_data_entry list
(** 为保持兼容性而提供的遗留接口函数 *)

val lookup_character : string -> rhyme_data_entry option
(** 导出供其他模块使用的数据访问函数 *)

val lookup_group : rhyme_group -> rhyme_group_data option
val get_all_groups : unit -> rhyme_group_data list
val get_all_entries : unit -> rhyme_data_entry list
val get_all_rhyme_groups : unit -> rhyme_group list
