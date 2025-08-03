(** 韵组统一管理模块接口
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_core_unified

(** {1 韵组分类管理} *)

module PingShengGroups : sig
  val get_all_ping_groups : unit -> rhyme_group list
  val is_ping_group : rhyme_group -> bool
  val get_ping_group_data : rhyme_group -> rhyme_character_info list option
  val get_all_ping_characters : unit -> rhyme_character_info list
  val get_ping_statistics : unit -> int * int * int
end

module ZeShengGroups : sig
  val get_all_ze_groups : unit -> rhyme_group list
  val is_ze_group : rhyme_group -> bool
  val get_ze_group_data : rhyme_group -> rhyme_character_info list option
  val get_all_ze_characters : unit -> rhyme_character_info list
  val get_ze_statistics : unit -> int * int * int
end

module RuShengGroups : sig
  val get_all_ru_groups : unit -> rhyme_group list
  val is_ru_group : rhyme_group -> bool
  val get_ru_group_data : rhyme_group -> rhyme_character_info list option
  val get_all_ru_characters : unit -> rhyme_character_info list
  val get_ru_statistics : unit -> int * int * int
end

(** {1 统一管理接口} *)

type group_classification = {
  group: rhyme_group;
  tone_type: rhyme_category;
  character_count: int;
  representative_chars: string list;
}

val classify_group : rhyme_group -> group_classification
val get_all_group_classifications : unit -> group_classification list
val group_by_tone_type : unit -> (rhyme_category * rhyme_group list) list

(** {1 韵组匹配和查询} *)

val are_groups_same_type : rhyme_group -> rhyme_group -> bool
val find_character_group_type : string -> rhyme_category option
val get_groups_by_tone_type : rhyme_category -> rhyme_group list

(** {1 韵组平衡分析} *)

type balance_info = {
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
  total_count: int;
  ping_ratio: float;
  ze_ratio: float;
  ru_ratio: float;
  is_balanced: bool;
}

val analyze_group_balance : unit -> balance_info
val print_balance_analysis : unit -> unit

(** {1 高级韵组操作} *)

val find_similar_groups : rhyme_group -> int -> group_classification list
val suggest_rhyme_groups : string -> rhyme_group list

(** {1 实用工具函数} *)

val random_group_by_type : rhyme_category -> rhyme_group option
val get_group_detailed_info : rhyme_group -> unit