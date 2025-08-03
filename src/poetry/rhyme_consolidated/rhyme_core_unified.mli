(** 韵律模块统一核心接口 - Issue #1999 Implementation
    
    这是Poetry韵律模块重构的核心接口文件。
    定义了所有韵律操作的标准化接口。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

(* Independent interface - no external dependencies *)

(** {1 核心韵律类型定义} *)

type rhyme_category = 
  | PingSheng    (** 平声：第一、二声 *)
  | ShangSheng   (** 上声：第三声 *)
  | QuSheng      (** 去声：第四声 *)
  | RuSheng      (** 入声：古代汉语特有 *)
  | ZeSheng      (** 仄声：上、去、入声总称 *)

type rhyme_group = 
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
  | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | XueRhyme
  | JiangRhyme | HuiRhyme | UnknownRhyme

type rhyme_character_info = {
  character: string;
  category: rhyme_category;
  group: rhyme_group;
  variants: string list;
  usage_frequency: float;
  is_common: bool;
}

type rhyme_group_data = {
  group_name: rhyme_group;
  group_description: string;
  entries: rhyme_character_info list;
  character_count: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
}

type rhyme_query_result = 
  | Found of rhyme_character_info
  | NotFound of string
  | MultipleMatches of rhyme_character_info list

type rhyme_statistics = {
  total_characters: int;
  total_groups: int;
  ping_sheng_chars: int;
  ze_sheng_chars: int;
  most_frequent_group: rhyme_group;
  least_frequent_group: rhyme_group;
}

(** {1 核心查询接口} *)

val query_character : string -> rhyme_query_result
val query_group_characters : rhyme_group -> string list
val query_category_characters : rhyme_category -> string list
val check_rhyme_match : string -> string -> bool
val batch_query_characters : string list -> rhyme_character_info list

(** {1 韵组管理接口} *)

val get_all_groups : unit -> rhyme_group_data list
val get_group_info : rhyme_group -> rhyme_group_data option
val get_statistics : unit -> rhyme_statistics

(** {1 验证和校验接口} *)

val validate_data_integrity : unit -> bool * string list
val validate_character_consistency : string -> bool
val run_full_validation : unit -> bool

(** {1 性能优化接口} *)

val preload_cache : unit -> unit
val refresh_cache : unit -> unit
val get_cache_stats : unit -> float * int * int

(** {1 兼容性接口} *)

val get_legacy_rhyme_data : rhyme_group -> (string * rhyme_category) list
val legacy_rhyme_lookup : string -> rhyme_group option
val is_ping_sheng : string -> bool
val is_ze_sheng : string -> bool

(** {1 调试和监控接口} *)

val get_version_info : unit -> string
val debug_print_stats : unit -> unit
val benchmark_query_performance : int -> float