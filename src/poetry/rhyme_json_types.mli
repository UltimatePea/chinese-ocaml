(** 韵律JSON数据类型定义接口

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

(* 使用中央类型定义，消除重复 *)
(* Re-export central types for backward compatibility *)
type rhyme_category = Poetry_core.Rhyme_core_types.rhyme_category
type rhyme_group = Poetry_core.Rhyme_core_types.rhyme_group

(** {1 异常类型} *)

exception Json_parse_error of string
exception Rhyme_data_not_found of string

(** {1 数据类型} *)

type rhyme_group_data = { category : string; characters : string list }

type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 类型转换函数} *)

val string_to_rhyme_category : string -> rhyme_category
(** 字符串转韵类 *)

val string_to_rhyme_group : string -> rhyme_group
(** 字符串转韵组 *)
