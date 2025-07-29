(** 韵律JSON API兼容层 - Wave 2 重构版本

    基于统一JSON核心的兼容接口层。提供向后兼容的API接口，
    确保现有代码在模块整合后继续正常工作。

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 重构
    @previous_version 2.0 - 2025-07-24 Phase 7.1 整合重构
    @fix_issue #1548 *)

(** {1 类型重新导出} *)

type rhyme_category = Rhyme_json_core.rhyme_category
(** 重新导出核心类型以保持兼容性 *)

type rhyme_group = Rhyme_json_core.rhyme_group
type rhyme_data_item = Rhyme_json_core.rhyme_data_item

exception Json_parse_error = Poetry_core_types.Json_parse_error
exception Rhyme_data_not_found of string

type rhyme_group_data = Rhyme_json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Rhyme_json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 原 Rhyme_json_types 模块兼容接口} *)
module Types = struct
  type rhyme_category = Rhyme_json_core.rhyme_category
  type rhyme_group = Rhyme_json_core.rhyme_group
  type rhyme_data_item = Rhyme_json_core.rhyme_data_item

  exception Json_parse_error = Poetry_core_types.Json_parse_error
  exception Rhyme_data_not_found of string

  type rhyme_group_data = Rhyme_json_core.rhyme_group_data = {
    category : string;
    characters : string list;
  }

  type rhyme_data_file = Rhyme_json_core.rhyme_data_file = {
    rhyme_groups : (string * rhyme_group_data) list;
    metadata : (string * string) list;
  }

  let string_to_rhyme_category = Rhyme_json_core.string_to_rhyme_category
  let string_to_rhyme_group = Rhyme_json_core.string_to_rhyme_group
end

(** {1 原 Rhyme_json_cache 模块兼容接口} *)
module Cache = struct
  let is_cache_valid = Rhyme_json_core.is_cache_valid
  let get_cached_data = Rhyme_json_core.get_cached_data
  let set_cached_data = Rhyme_json_core.set_cached_data
  let clear_cache = Rhyme_json_core.clear_cache
  let refresh_cache = Rhyme_json_core.refresh_cache
end

(** {1 原 Rhyme_json_parser 模块兼容接口} *)
module Parser = struct
  let parse_nested_json = Rhyme_json_core.parse_nested_json
  let clean_json_string = Rhyme_json_core.clean_json_string
end

(** {1 原 Rhyme_json_io 模块兼容接口} *)
module Io = struct
  let default_data_file = Rhyme_json_core.default_data_file
  let safe_read_file = Rhyme_json_core.safe_read_file
  let load_rhyme_data_from_file = Rhyme_json_core.load_rhyme_data_from_file
  let get_rhyme_data = Rhyme_json_core.get_rhyme_data
end

(** {1 原 Rhyme_json_access 模块兼容接口} *)
module Access = struct
  let get_all_rhyme_groups = Rhyme_json_core.get_all_rhyme_groups
  let get_rhyme_group_characters = Rhyme_json_core.get_rhyme_group_characters
  let get_rhyme_group_category = Rhyme_json_core.get_rhyme_group_category
  let get_rhyme_mappings = Rhyme_json_core.get_rhyme_mappings
  let get_data_statistics = Rhyme_json_core.get_data_statistics
  let print_statistics = Rhyme_json_core.print_statistics
end

(** {1 原 Rhyme_json_fallback 模块兼容接口} *)
module Fallback = struct
  let fallback_rhyme_data = Rhyme_json_core.fallback_rhyme_data
  let use_fallback_data = Rhyme_json_core.use_fallback_data
end

(** {1 主要API - 完全兼容原接口} *)

(** 类型转换函数 *)
let string_to_rhyme_category = Rhyme_json_core.string_to_rhyme_category

let string_to_rhyme_group = Rhyme_json_core.string_to_rhyme_group

(** 获取韵律数据（兼容原有接口） *)
let get_rhyme_data ?(force_reload = false) () =
  match Rhyme_json_core.get_rhyme_data_safe ~force_reload () with
  | Some data -> Some data
  | None -> Some (Rhyme_json_core.use_fallback_data ())

(** 获取所有韵组（兼容原有接口） *)
let get_all_rhyme_groups = Rhyme_json_core.get_all_rhyme_groups

(** 获取韵组字符（兼容原有接口） *)
let get_rhyme_group_characters = Rhyme_json_core.get_rhyme_group_characters

(** 获取韵组韵类（兼容原有接口） *)
let get_rhyme_group_category = Rhyme_json_core.get_rhyme_group_category

(** 获取韵律映射（兼容原有接口） *)
let get_rhyme_mappings = Rhyme_json_core.get_rhyme_mappings

(** 获取统计信息（兼容原有接口） *)
let get_data_statistics = Rhyme_json_core.get_data_statistics

(** 打印统计信息（兼容原有接口） *)
let print_statistics = Rhyme_json_core.print_statistics

(** 缓存管理（兼容原有接口） *)
let is_cache_valid = Rhyme_json_core.is_cache_valid

let clear_cache = Rhyme_json_core.clear_cache
let refresh_cache = Rhyme_json_core.refresh_cache

(** 文件操作（兼容原有接口） *)
let load_rhyme_data_from_file = Rhyme_json_core.load_rhyme_data_from_file

(** 降级处理（兼容原有接口） *)
let use_fallback_data = Rhyme_json_core.use_fallback_data

(** JSON解析（兼容原有接口） *)
let parse_nested_json = Rhyme_json_core.parse_nested_json

let clean_json_string = Rhyme_json_core.clean_json_string
