(** 韵律数据统一整合模块接口 - 替代多个重复数据模块
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律数据统一整合
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

open Poetry_core.Poetry_types

(** {2 替代原有模块的导出接口} *)

(** 替代 an_rhyme_data.ml *)
module An_Rhyme_Unified : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val data : (string * rhyme_group * rhyme_category * float) list
end

(** 替代 feng_rhyme_data.ml *)
module Feng_Rhyme_Unified : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val data : (string * rhyme_group * rhyme_category * float) list
end

(** 替代 hua_rhyme_data.ml *)
module Hua_Rhyme_Unified : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val data : (string * rhyme_group * rhyme_category * float) list
end

(** 替代其他所有韵组数据模块的通用接口 *)
val get_rhyme_group_data : rhyme_group -> (string * rhyme_category * float) list

(** 替代 rhyme_database.ml 的查询功能 *)
val query_character_rhyme : string -> (string * rhyme_group * rhyme_category * float) option

(** 替代 unified_rhyme_data.ml 的加载功能 *)
val load_unified_rhyme_data : unit -> (rhyme_group * rhyme_category * string list) list

(** {2 统计和验证} *)

(** 数据统计结构 *)
type database_stats = {
  total_entries: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
  group_counts: (rhyme_group * int) list;
}

(** 数据统计 *)
val get_unified_stats : unit -> database_stats

(** 验证数据完整性 *)
val validate_unified_data : unit -> bool