(** 骆言诗词统一韵律API接口 - Issue #2084 Phase 2 韵律系统整合完成
    
    Author: Whisky, PR Worker - Poetry模块架构整合
    Date: 2025-08-04
    
    本模块接口定义了统一的韵律系统API，是韵律功能的单一入口点。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 子模块接口 === *)

(** 韵律分析引擎 *)
module Engine : sig
  val get_rhyme_info : string -> char_rhyme_info option
  val check_rhyme : string -> string -> rhyme_match_result
  val analyze_verse : string -> verse_rhyme_analysis
  val analyze_poem : string list -> poem_rhyme_analysis
  val suggest_rhymes : string -> rhyme_group -> rhyme_suggestion
  val validate_verse_analysis : verse_rhyme_analysis -> bool
  val validate_poem_analysis : poem_rhyme_analysis -> bool
end

(** 韵律数据库 *)
module Database : sig
  val find_character : string -> rhyme_data_item option
  val get_group_chars : rhyme_group -> rhyme_data_item list
  val get_all_groups : unit -> (rhyme_group * string * int) list
  val get_stats : unit -> (int * int * float)
  val export_json : unit -> rhyme_data_file
  val get_cached_char : string -> rhyme_data_item option
  val clear_cache : unit -> unit
end

(** 韵律查询 *)
module Query : sig
  val query_matches : string -> rhyme_data_item list
  val find_rhymes : string -> rhyme_data_item list
  val query_group : rhyme_group -> rhyme_data_item list
  val query_category : rhyme_category -> rhyme_data_item list
  val suggest_for_text : string -> rhyme_group -> (string * rhyme_data_item list) list
  val suggest_endings : string -> rhyme_group -> rhyme_data_item list
  val execute_query : rhyme_query -> (string * rhyme_match_result * float) list
  val batch_execute : rhyme_query list -> (string * rhyme_match_result * float) list list
end

(** === 一体化接口 === *)

(** 一站式韵律分析：文本 -> (诗篇分析, 分析结果, 有效性) *)
val complete_analysis : string -> (poem_rhyme_analysis * rhyme_analysis_result * bool)

(** 快速韵律检查 *)
val quick_rhyme_check : string -> string -> rhyme_match_result

(** 快速字符查询 *)
val quick_char_lookup : string -> string

(** 批量韵律检查 *)
val batch_rhyme_check : (string * string) list -> ((string * string) * rhyme_match_result) list

(** 智能建议生成 *)
val smart_suggestions : string -> rhyme_group -> rhyme_suggestion

(** === 系统管理接口 === *)

(** 生成系统状态报告 *)
val system_status_report : unit -> string

(** 性能基准测试 *)
val performance_benchmark : unit -> string

(** 模块完整性检查 *)
val module_integrity_check : unit -> string

(** === 向后兼容接口 === *)

(** 兼容原 unified_rhyme_api 接口 *)
val get_character_rhyme_info : string -> char_rhyme_info option
val check_rhyme_match : string -> string -> rhyme_match_result
val analyze_verse_rhyme : string -> verse_rhyme_analysis
val analyze_poem_rhyme : string list -> poem_rhyme_analysis

(** 兼容原 rhyme_query_engine 接口 *)
val query_rhyme_matches : string -> rhyme_data_item list
val find_rhyme_alternatives : string -> rhyme_data_item list

(** 兼容原 rhyme_database 接口 *)
val lookup_character : string -> rhyme_data_item option
val get_rhyme_group_data : rhyme_group -> rhyme_data_item list