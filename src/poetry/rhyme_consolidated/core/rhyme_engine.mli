(** 骆言诗词韵律引擎接口 - 统一韵律分析核心
    
    Author: Whisky, PR Worker - Issue #2084 Phase 2 韵律系统整合
    Date: 2025-08-04
    
    本模块接口定义了统一的韵律分析功能，整合了原有分散的韵律模块。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 核心韵律分析函数 === *)

(** 获取字符的韵律信息 *)
val get_rhyme_info : string -> char_rhyme_info option

(** 检查两个字符是否押韵 *)
val check_rhyme : string -> string -> rhyme_match_result

(** 分析诗句的韵律结构 *)
val analyze_verse : string -> verse_rhyme_analysis

(** 分析整首诗的韵律结构 *)
val analyze_poem : string list -> poem_rhyme_analysis

(** 生成韵律建议 *)
val suggest_rhymes : string -> rhyme_group -> rhyme_suggestion

(** === 验证函数 === *)

(** 验证诗句韵律分析的有效性 *)
val validate_verse_analysis : verse_rhyme_analysis -> bool

(** 验证诗篇韵律分析的有效性 *)
val validate_poem_analysis : poem_rhyme_analysis -> bool