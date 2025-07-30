(** 韵律数据注册表模块接口 *)

open Poetry_core.Rhyme_core_types

(** 统一韵律数据访问模块 *)
module Unified_rhyme_data : sig
  val get_rhyme_data_by_group : rhyme_group -> Rhyme_data_core.rhyme_group_data
  (** 根据韵组类型获取对应的韵组数据 *)

  val get_all_rhyme_data : unit -> Rhyme_data_core.rhyme_group_data list
  (** 获取所有韵组数据列表 *)

  val get_rhyme_stats : unit -> int * int * int
  (** 获取韵组统计信息 *)
  
  val validate_rhyme_data : unit -> bool * string list * string list
  (** 数据验证：检查字符重复和一致性。返回 (是否有效, 问题列表, 重复字符列表) *)
  
  val check_data_integrity : unit -> bool
  (** 运行数据验证并打印结果。返回是否通过验证 *)
end

(** {1 向后兼容性接口} *)

val an_rhyme_data : Rhyme_data_core.rhyme_group_data
(** 各韵组数据 *)

val si_rhyme_data : Rhyme_data_core.rhyme_group_data
val tian_rhyme_data : Rhyme_data_core.rhyme_group_data
val wang_rhyme_data : Rhyme_data_core.rhyme_group_data
val qu_rhyme_data : Rhyme_data_core.rhyme_group_data
val yu_rhyme_data : Rhyme_data_core.rhyme_group_data
val hua_rhyme_data : Rhyme_data_core.rhyme_group_data
val feng_rhyme_data : Rhyme_data_core.rhyme_group_data
val yue_rhyme_data : Rhyme_data_core.rhyme_group_data
val jiang_rhyme_data : Rhyme_data_core.rhyme_group_data
val hui_rhyme_data : Rhyme_data_core.rhyme_group_data

val get_all_rhyme_data : unit -> Rhyme_data_core.rhyme_group_data list
(** 统一访问函数 *)

val get_rhyme_data_by_group : rhyme_group -> Rhyme_data_core.rhyme_group_data
val get_rhyme_stats : unit -> int * int * int

val validate_rhyme_data : unit -> bool * string list * string list
(** 数据验证：检查字符重复和一致性。返回 (是否有效, 问题列表, 重复字符列表) *)

val check_data_integrity : unit -> bool
(** 运行数据验证并打印结果。返回是否通过验证 *)
