(** Poetry Data Unified Consolidated Module Interface - Issue #1999
 * 
 * 统一的韵律数据访问接口模块
 * Author: Whisky, PR Worker
 *)

open Poetry_core_consolidated

(** {1 数据源类型定义} *)

type data_load_status = 
  | NotLoaded
  | Loading  
  | Loaded
  | LoadError of string

type data_source = 
  | InMemory
  | JsonFile
  | External

type data_statistics = {
  total_rhyme_entries: int;
  rhyme_groups_count: int;
  tone_patterns_count: int;
  load_time: float;
  memory_usage: int;
}

(** {1 数据加载管理} *)

(** 加载数据到缓存 *)
val load_data_to_cache : unit -> unit

(** 检查数据是否已加载 *)
val is_data_loaded : unit -> bool

(** 强制重新加载数据 *)
val force_reload_data : unit -> unit

(** {1 统一数据访问接口} *)

(** 获取韵律信息 *)
val get_rhyme_info : string -> rhyme_info option

(** 获取韵部所有字符 *)
val get_rhyme_group_characters : rhyme_group -> string list

(** 获取指定声调的字符 *)
val get_characters_by_tone : int -> (string * rhyme_info) list

(** 获取指定声调分类的字符 *)
val get_characters_by_category : rhyme_category -> (string * rhyme_info) list

(** 搜索相似韵律的字符 *)
val find_similar_rhyme_characters : string -> int -> string list

(** {1 批量操作接口} *)

(** 批量获取韵律信息 *)
val batch_get_rhyme_info : string list -> (string * rhyme_info option) list

(** 批量韵律验证 *)
val batch_validate_rhyme : (string * string) list -> (string * string * bool) list

(** {1 数据统计和查询} *)

(** 获取数据统计信息 *)
val get_data_statistics : unit -> data_statistics

(** 获取所有韵部列表 *)
val get_all_rhyme_groups : unit -> rhyme_group list

(** 获取韵部统计信息 *)
val get_rhyme_group_stats : rhyme_group -> int

(** 生成数据报告 *)
val generate_data_report : unit -> string

(** {1 缓存管理} *)

(** 清理数据缓存 *)
val clear_data_cache : unit -> unit

(** 预热缓存 *)
val warm_up_cache : unit -> unit

(** {1 兼容性接口} *)

val find_rhyme_data_compat : string -> rhyme_info option
val get_rhyme_database_compat : unit -> (string * rhyme_info) list
val load_rhyme_data_to_cache : unit -> unit