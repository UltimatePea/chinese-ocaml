(** 韵律核心类型定义模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。声韵调谐，方称佳构。 此模块统一定义所有音韵类型，为整个诗词系统提供基础类型支撑。 消除项目中30+文件的类型重复定义问题。

    重构目标：
    - 统一所有韵律相关类型定义
    - 消除rhyme_types.ml、poetry_types_consolidated.ml等文件的重复
    - 为整个诗词模块提供单一权威类型源

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

(** {1 统一类型导入} *)

(* Import all unified types from poetry_types.ml *)
open Poetry_types

(* Re-export all types for backward compatibility *)
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
let string_of_rhyme_category = string_of_rhyme_category
let string_of_rhyme_group = string_of_rhyme_group
let rhyme_category_to_string = rhyme_category_to_string
let rhyme_group_to_string = rhyme_group_to_string
let string_to_rhyme_category = string_to_rhyme_category
let string_to_rhyme_group = string_to_rhyme_group
let rhyme_category_equal = rhyme_category_equal
let rhyme_group_equal = rhyme_group_equal
let is_ping_sheng = is_ping_sheng
let is_ze_sheng = is_ze_sheng