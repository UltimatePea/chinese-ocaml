(** 韵律JSON数据类型定义 - Wave 2 重构版本

    基于统一JSON核心的兼容接口层。所有核心功能已迁移到poetry_core.json_core，
    此模块现在作为向后兼容的薄包装层存在。

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

(** {1 JSON专用类型重新导出} *)

(* 重新导出异常类型 *)
exception Json_parse_error of string
exception Rhyme_data_not_found of string

(* 重新导出数据结构类型 *)
type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Poetry_core.Json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 函数转发 - 完全兼容} *)

(** 字符串转韵类 - 转发到统一核心 *)
let string_to_rhyme_category s =
  match Poetry_core.Json_core.string_to_rhyme_category s with
  | Some category -> category
  | None -> PingSheng (* 保持原有默认行为 *)

(** 字符串转韵组 - 转发到统一核心 *)
let string_to_rhyme_group s =
  match Poetry_core.Json_core.string_to_rhyme_group s with
  | Some group -> group
  | None -> UnknownRhyme (* 保持原有默认行为 *)
