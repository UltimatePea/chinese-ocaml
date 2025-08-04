(** 骆言诗词韵律查询引擎接口 - 统一韵律查询接口
    
    Author: Whisky, PR Worker - Issue #2084 Phase 2 韵律系统整合
    Date: 2025-08-04
    
    本模块接口定义了统一的韵律查询功能。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 基础查询接口 === *)

(** 查询字符的所有韵律匹配项 *)
val query_matches : string -> rhyme_data_item list

(** 查找与目标字符押韵的所有字符 *)
val find_rhymes : string -> rhyme_data_item list

(** 按韵组查询字符 *)
val query_group : rhyme_group -> rhyme_data_item list

(** 按声调查询字符 *)
val query_category : rhyme_category -> rhyme_data_item list

(** === 建议系统接口 === *)

(** 为指定文本生成韵律建议 *)
val suggest_for_text : string -> rhyme_group -> (string * rhyme_data_item list) list

(** 生成韵脚建议 *)
val suggest_endings : string -> rhyme_group -> rhyme_data_item list

(** === 高级查询接口 === *)

(** 执行复合查询 *)
val execute_query : rhyme_query -> (string * rhyme_match_result * float) list

(** 批量查询处理 *)
val batch_execute : rhyme_query list -> (string * rhyme_match_result * float) list list