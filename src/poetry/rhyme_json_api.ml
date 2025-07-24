(** 韵律JSON API兼容层
    
    提供向后兼容的API接口，确保现有代码在模块整合后继续正常工作。
    本模块重新导出原分散模块的接口，实现无缝迁移。
    
    @author 骆言诗词编程团队
    @version 2.0  
    @since 2025-07-24 - Phase 7.1 JSON处理系统整合重构 *)

(** {1 类型重新导出} *)

(** 重新导出核心类型以保持兼容性 *)
type rhyme_category = Rhyme_json_core.rhyme_category =
  | PingSheng  (** 平声 *)
  | ZeSheng  (** 仄声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng  (** 去声 *)
  | RuSheng  (** 入声 *)

type rhyme_group = Rhyme_json_core.rhyme_group =
  | AnRhyme  (** 安韵 *)
  | SiRhyme  (** 思韵 *)
  | TianRhyme  (** 天韵 *)
  | WangRhyme  (** 王韵 *)
  | QuRhyme  (** 曲韵 *)
  | YuRhyme  (** 雨韵 *)
  | HuaRhyme  (** 花韵 *)
  | FengRhyme  (** 风韵 *)
  | YueRhyme  (** 月韵 *)
  | XueRhyme  (** 雪韵 *)
  | JiangRhyme  (** 江韵 *)
  | HuiRhyme  (** 辉韵 *)
  | UnknownRhyme  (** 未知韵 *)

exception Json_parse_error = Rhyme_json_core.Json_parse_error
exception Rhyme_data_not_found = Rhyme_json_core.Rhyme_data_not_found

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
  type rhyme_category = Rhyme_json_core.rhyme_category =
    | PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng
  
  type rhyme_group = Rhyme_json_core.rhyme_group =
    | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
    | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | XueRhyme 
    | JiangRhyme | HuiRhyme | UnknownRhyme
  
  exception Json_parse_error = Rhyme_json_core.Json_parse_error
  exception Rhyme_data_not_found = Rhyme_json_core.Rhyme_data_not_found
  
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
  let cache_ttl = 300.0
  let is_cache_valid = Rhyme_json_core.is_cache_valid
  let get_cached_data = Rhyme_json_core.get_cached_data
  let set_cached_data = Rhyme_json_core.set_cached_data
  let clear_cache = Rhyme_json_core.clear_cache
  let refresh_cache = Rhyme_json_core.refresh_cache
end

(** {1 原 Rhyme_json_parser 模块兼容接口} *)
module Parser = struct
  let parse_nested_json = Rhyme_json_core.parse_nested_json
end

(** {1 原 Rhyme_json_io 模块兼容接口} *)
module Io = struct
  let default_data_file = "data/poetry/rhyme_groups/rhyme_data.json"
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
  let use_fallback_data = Rhyme_json_core.use_fallback_data
end

(** {1 主要API - 完全兼容原接口} *)

(** 类型转换函数 *)
let string_to_rhyme_category = Rhyme_json_core.string_to_rhyme_category
let string_to_rhyme_group = Rhyme_json_core.string_to_rhyme_group

(** 获取韵律数据（兼容原有接口） *)
let get_rhyme_data ?(force_reload = false) () =
  try Some (Rhyme_json_core.get_rhyme_data ~force_reload ())
  with Rhyme_data_not_found _ | Json_parse_error _ -> Some (Rhyme_json_core.use_fallback_data ())

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