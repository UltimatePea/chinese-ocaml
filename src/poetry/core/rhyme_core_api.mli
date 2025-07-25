(** 韵律核心API模块接口 - 骆言诗词编程特性

    此模块提供统一的韵律数据访问API，消除项目中多个重复API接口。

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

open Rhyme_core_types

(** {1 基础查询函数} *)

val find_character_rhyme : string -> rhyme_data_entry option
(** 查找字符的韵律信息 *)

val find_character_rhyme_exn : string -> rhyme_data_entry
(** 查找字符的韵律信息（抛出异常版本） *)

val get_character_rhyme_group : string -> rhyme_group option
(** 获取字符的韵组 *)

val get_character_rhyme_category : string -> rhyme_category option
(** 获取字符的声韵类别 *)

(** {2 韵组相关查询} *)

val get_characters_by_group : rhyme_group -> string list
(** 获取指定韵组的所有字符 *)

val get_characters_by_category : rhyme_category -> string list
(** 获取指定声韵类别的所有字符 *)

val get_rhyme_group_description : rhyme_group -> string
(** 获取韵组描述 *)

val get_rhyme_group_examples : rhyme_group -> string list
(** 获取韵组的典型诗句示例 *)

(** {3 韵律匹配功能} *)

val can_rhyme_together : string -> string -> rhyme_match_result
(** 检查两个字符是否可以押韵 *)

val find_rhyming_characters : string -> ?min_quality:float -> unit -> string list
(** 为指定字符查找押韵字符 *)

(** {4 诗句韵律分析} *)

val analyze_character : string -> ?confidence:float -> unit -> char_rhyme_info option
(** 分析单个字符的韵律信息 *)

val analyze_verse : string -> ?config:analysis_config -> unit -> verse_rhyme_analysis
(** 分析诗句的韵律特征 *)

val analyze_poem : string list -> ?config:analysis_config -> unit -> poem_rhyme_analysis
(** 分析整首诗的韵律特征 *)

(** {5 韵律建议功能} *)

val suggest_rhyme_characters :
  string -> ?max_suggestions:int -> ?min_quality:float -> unit -> rhyme_suggestion list
(** 为指定位置推荐押韵字符 *)

(** {6 缓存和性能优化} *)

val find_character_rhyme_cached : string -> rhyme_data_entry option
(** 带缓存的字符韵律查询 *)

val clear_cache : unit -> unit
(** 清空缓存 *)

(** {7 统计和监控} *)

val get_system_stats : unit -> (string * int) list
(** 获取系统统计信息 *)
