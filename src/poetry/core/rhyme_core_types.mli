(** 韵律核心类型定义模块接口 - 骆言诗词编程特性

    此接口重新导出统一的韵律类型系统，保持向后兼容性。
    所有类型定义现在来自 poetry_types.ml 统一类型系统。

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

(** {1 统一类型重新导出} *)

(* Re-export all types from the unified poetry_types system *)
type rhyme_category = Poetry_types.rhyme_category
type rhyme_group = Poetry_types.rhyme_group
type char_rhyme_info = Poetry_types.char_rhyme_info
type verse_rhyme_analysis = Poetry_types.verse_rhyme_analysis
type poem_rhyme_analysis = Poetry_types.poem_rhyme_analysis
type rhyme_data_entry = Poetry_types.rhyme_data_entry
type rhyme_match_result = Poetry_types.rhyme_match_result
type rhyme_suggestion = Poetry_types.rhyme_suggestion
type rhyme_error = Poetry_types.rhyme_error

(* Re-export utility functions *)
val string_of_rhyme_category : rhyme_category -> string
val string_of_rhyme_group : rhyme_group -> string
val rhyme_category_to_string : rhyme_category -> string
val rhyme_group_to_string : rhyme_group -> string
val string_to_rhyme_category : string -> rhyme_category option
val string_to_rhyme_group : string -> rhyme_group option
val rhyme_category_equal : rhyme_category -> rhyme_category -> bool
val rhyme_group_equal : rhyme_group -> rhyme_group -> bool
val is_ping_sheng : rhyme_category -> bool
val is_ze_sheng : rhyme_category -> bool