(** 韵律JSON处理核心模块 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本361行的重复代码现在转发到统一的JSON核心，实现了70%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 类型定义 → 转发到统一核心
    - JSON解析 → 转发到统一核心
    - 缓存管理 → 转发到统一核心
    - 文件I/O操作 → 转发到统一核心
    - 数据访问接口 → 转发到统一核心
    - 降级处理 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 重构
    @previous_version 2.0 - 2025-07-24 Phase 7.1 整合重构
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

(** {1 类型转换函数 - 转发到统一核心} *)

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

(** {1 缓存管理 - 转发到统一核心} *)

(** 检查缓存是否有效 - 转发到统一核心 *)
let is_cache_valid = Poetry_core.Json_core.Cache.is_cache_valid

(** 获取缓存的数据 - 转发到统一核心 *)
let get_cached_data () =
  match Poetry_core.Json_core.Cache.get_cached_data () with
  | Some data -> data
  | None -> raise (Rhyme_data_not_found "缓存中无数据")

(** 设置缓存数据 - 转发到统一核心 *)
let set_cached_data = Poetry_core.Json_core.Cache.set_cached_data

(** 清理缓存 - 转发到统一核心 *)
let clear_cache = Poetry_core.Json_core.Cache.clear_cache

(** 强制刷新缓存 - 转发到统一核心 *)
let refresh_cache data =
  clear_cache ();
  set_cached_data data

(** {1 JSON解析器 - 转发到统一核心} *)

(** 清理JSON字符串 - 转发到统一核心 *)
let clean_json_string = Poetry_core.Json_core.Parser.clean_json_string

(** 解析嵌套JSON内容 - 转发到统一核心 *)
let parse_nested_json = Poetry_core.Json_core.Parser.parse_simple_json

(** {1 文件I/O操作 - 转发到统一核心} *)

(** 默认数据文件路径 *)
let default_data_file = Poetry_core.Json_core.Io.default_rhyme_data_path

(** 安全地读取文件内容 - 转发到统一核心 *)
let safe_read_file = Poetry_core.Json_core.Io.safe_read_file

(** 从文件加载韵律数据 - 转发到统一核心 *)
let load_rhyme_data_from_file ?(filename = default_data_file) () =
  try
    let content = safe_read_file filename in
    let data = Poetry_core.Json_core.Parser.parse_rhyme_json content in
    set_cached_data data;
    data
  with
  | Json_parse_error msg -> raise (Json_parse_error ("JSON解析错误: " ^ msg))
  | Rhyme_data_not_found msg -> raise (Rhyme_data_not_found msg)
  | exn -> raise (Json_parse_error ("加载韵律数据时发生异常: " ^ Printexc.to_string exn))

(** {1 降级数据处理 - 转发到统一核心} *)

(** 降级韵律数据 *)
let fallback_rhyme_data = Poetry_core.Json_core.Fallback.fallback_rhyme_data

(** 使用降级数据 - 转发到统一核心 *)
let use_fallback_data = Poetry_core.Json_core.Fallback.use_fallback_data

(** {1 主要API函数 - 转发到统一核心} *)

(** 获取韵律数据（支持缓存） - 转发到统一核心 *)
let get_rhyme_data ?(force_reload = false) () =
  match Poetry_core.Json_core.get_rhyme_data_safe ~force_reload () with
  | Some data -> data
  | None -> use_fallback_data ()

(** 获取所有韵组 - 转发到统一核心 *)
let get_all_rhyme_groups () = Poetry_core.Json_core.get_all_rhyme_groups ()

(** 获取指定韵组的字符列表 - 转发到统一核心 *)
let get_rhyme_group_characters group_name =
  Poetry_core.Json_core.get_rhyme_group_characters group_name

(** 获取指定韵组的韵类 - 转发到统一核心 *)
let get_rhyme_group_category group_name = Poetry_core.Json_core.get_rhyme_group_category group_name

(** 获取韵律映射关系 - 转发到统一核心 *)
let get_rhyme_mappings () = Poetry_core.Json_core.get_rhyme_mappings ()

(** 获取数据统计信息 - 转发到统一核心 *)
let get_data_statistics () =
  match Poetry_core.Json_core.get_data_statistics () with
  | Some (total_groups, total_chars, _cache_hits, _cache_misses, _last_modified) ->
      Some (total_groups, total_chars)
  | None -> None

(** 打印统计信息 - 转发到统一核心 *)
let print_statistics () = Poetry_core.Json_core.print_statistics ()

(** 安全获取韵律数据（带降级处理） - 转发到统一核心 *)
let get_rhyme_data_safe ?(force_reload = false) () =
  Poetry_core.Json_core.get_rhyme_data_safe ~force_reload ()
