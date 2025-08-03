(** 骆言诗词统一韵律系统接口 - Issue #2084 架构整合
 *
 * 此接口整合了130+个分散韵律文件的核心功能，提供统一、简洁的韵律处理API。
 *
 * @author Whisky, PR Worker
 * @consolidation_issue #2084  
 * @version 1.0 - 统一韵律系统接口
 *)

(** {1 核心类型重导出} *)

(* 重新导出统一类型定义 *)
include module type of Poetry_core.Types

(** {1 韵律数据管理} *)

module RhymeData : sig
  (** 韵律数据条目 *)
  type entry = {
    character : string;
    category : rhyme_category;
    group : rhyme_group;
    tone : tone_pattern option;
    metadata : (string * string) list;
  }

  (** 查找字符韵律信息 *)
  val find_character_rhyme : string -> entry option

  (** 获取韵组所有字符 *)
  val get_characters_by_group : rhyme_group -> string list

  (** 获取声韵类别所有字符 *)
  val get_characters_by_category : rhyme_category -> string list

  (** 数据库统计信息: (字符数, 韵组数, 声韵类别数) *)
  val get_statistics : unit -> int * int * int
end

(** {1 韵律验证引擎} *)

module RhymeValidator : sig
  (** 韵律验证结果 *)
  type validation_result = {
    is_valid : bool;
    score : float;
    errors : string list;
    suggestions : string list;
    confidence : float;
  }

  (** 验证两个字符是否押韵 *)
  val validate_rhyme_pair : string -> string -> validation_result

  (** 验证诗句韵律 *)
  val validate_verse_rhyme : string -> validation_result

  (** 验证多句韵律模式 *)
  val validate_verses_pattern : string list -> validation_result
end

(** {1 韵律查询引擎} *)

module RhymeQuery : sig
  (** 查询类型 *)
  type query_type =
    | ByCharacter of string
    | ByGroup of rhyme_group
    | ByCategory of rhyme_category
    | ByPattern of string

  (** 查询结果 *)
  type query_result = {
    matches : RhymeData.entry list;
    total_count : int;
    query_time : float;
    suggestions : string list;
  }

  (** 执行查询 *)
  val execute_query : query_type -> query_result

  (** 搜索相似韵律 *)
  val find_similar_rhymes : string -> string list
end

(** {1 韵律匹配和评分} *)

module RhymeMatching : sig
  (** 匹配结果 *)
  type match_result = {
    source_char : string;
    matched_chars : string list;
    match_quality : float;
    match_type : [`Perfect | `Good | `Acceptable | `Poor];
  }

  (** 查找最佳韵律匹配 *)
  val find_best_matches : string -> int -> match_result
end

(** {1 诗词格律检查} *)

module PoetryMeter : sig
  (** 格律类型 *)
  type meter_type = 
    | JueJu of [`WuYan | `QiYan]  (* 绝句 *)
    | LuShi of [`WuYan | `QiYan]  (* 律诗 *)
    | Ci of string                (* 词 *)
    | Fu of string                (* 赋 *)

  (** 格律检查结果 *)
  type meter_result = {
    detected_meter : meter_type option;
    is_standard : bool;
    compliance_score : float;
    violations : string list;
    suggestions : string list;
  }

  (** 检查诗词格律 *)
  val check_meter : string list -> meter_result
end

(** {1 统一对外API} *)

(** 快速韵律检查 - 单句 *)
val quick_rhyme_check : string -> float * bool * string list

(** 快速韵律检查 - 多句 *)
val quick_verses_check : string list -> float * PoetryMeter.meter_type option * string list

(** 查找字符韵律 *)
val lookup_character_rhyme : string -> RhymeData.entry option

(** 查找相似韵律字符 *)
val find_rhyme_matches : string -> int -> string list

(** 获取韵组字符列表 *)
val get_rhyme_group_characters : rhyme_group -> string list

(** 获取系统统计信息 *)
val get_system_statistics : unit -> (string * string) list

(** 系统初始化 *)
val initialize_system : unit -> unit

(** {1 向后兼容性接口} *)

(** 查找字符韵律信息 (兼容性) *)
val find_character_rhyme : string -> RhymeData.entry option

(** 获取韵组字符 (兼容性) *)
val get_characters_by_group : rhyme_group -> string list

(** 验证韵律 (兼容性) *)
val validate_rhyme : string -> float * bool * string list

(** 检查多句韵律 (兼容性) *)
val check_verses_rhyme : string list -> bool

(** 获取韵律建议 (兼容性) *)
val get_rhyme_suggestions : string -> string list