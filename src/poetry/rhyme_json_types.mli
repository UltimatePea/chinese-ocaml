(** 韵律JSON数据类型定义接口 - Wave 2 重构版本

    基于统一JSON核心的兼容接口层。保持100%向后兼容性。

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 2.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 重构
    @previous_version 1.0 - 2025-07-20 Phase 29
    @fix_issue #1548 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出核心类型以保持100%向后兼容 *)
type rhyme_category = Poetry_core.Json_core.rhyme_category
type rhyme_group = Poetry_core.Json_core.rhyme_group
type rhyme_data_item = Poetry_core.Json_core.rhyme_data_item

(** {1 异常类型} *)

exception Json_parse_error of string
exception Rhyme_data_not_found of string

(** {1 数据类型} *)

type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Poetry_core.Json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 类型转换函数} *)

val string_to_rhyme_category : string -> rhyme_category
(** 字符串转韵类 - 转发到统一核心 *)

val string_to_rhyme_group : string -> rhyme_group
(** 字符串转韵组 - 转发到统一核心 *)
