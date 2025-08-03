(** 韵律数据统一整合模块接口
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_core_unified

(** {1 数据访问函数} *)

val get_all_rhyme_data : unit -> rhyme_character_info list
val get_characters_by_group : rhyme_group -> rhyme_character_info list
val get_characters_by_category : rhyme_category -> rhyme_character_info list
val find_character_info : string -> rhyme_character_info option
val get_group_statistics : rhyme_group -> int * int * int
val get_all_groups : unit -> rhyme_group_data list

(** {1 数据验证函数} *)

val validate_data_integrity : unit -> bool * string list
val check_data_integrity : unit -> bool

(** {1 向后兼容性接口} *)

val get_legacy_rhyme_data : rhyme_group -> (string * rhyme_category) list

module Legacy_Compat : sig
  val an_rhyme_data : (string * rhyme_category) list
  val si_rhyme_data : (string * rhyme_category) list
  val tian_rhyme_data : (string * rhyme_category) list
  val wang_rhyme_data : (string * rhyme_category) list
  val qu_rhyme_data : (string * rhyme_category) list
  val yu_rhyme_data : (string * rhyme_category) list
  val hua_rhyme_data : (string * rhyme_category) list
  val feng_rhyme_data : (string * rhyme_category) list
  val yue_rhyme_data : (string * rhyme_category) list
  val jiang_rhyme_data : (string * rhyme_category) list
  val hui_rhyme_data : (string * rhyme_category) list
end

(** {1 性能统计} *)

val get_consolidated_stats : unit -> unit