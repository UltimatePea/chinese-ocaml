(** 韵律JSON处理核心模块接口 - Wave 2 重构版本

    基于统一JSON核心的兼容接口层。保持100%向后兼容性。

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

(** {1 异常类型} *)

exception Json_parse_error of string
exception Rhyme_data_not_found of string

(** {1 数据类型} *)

type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  group_name : string;
  chars : string list;
  tone_patterns : int list;
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

(** {1 缓存管理} *)

val is_cache_valid : unit -> bool
(** 检查缓存是否有效 *)

val get_cached_data : unit -> rhyme_data_file
(** 获取缓存的数据 *)

val set_cached_data : rhyme_data_file -> unit
(** 设置缓存数据 *)

val clear_cache : unit -> unit
(** 清理缓存 *)

val refresh_cache : rhyme_data_file -> unit
(** 强制刷新缓存 *)

(** {1 JSON解析器} *)

val clean_json_string : string -> string
(** 清理JSON字符串 *)

val parse_nested_json : string -> rhyme_data_file
(** 解析嵌套JSON内容 *)

(** {1 文件I/O操作} *)

val default_data_file : string
(** 默认数据文件路径 *)

val safe_read_file : string -> string
(** 安全地读取文件内容 *)

val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file
(** 从文件加载韵律数据 *)

(** {1 降级数据处理} *)

val fallback_rhyme_data : (string * rhyme_group_data) list
(** 降级韵律数据 *)

val use_fallback_data : unit -> rhyme_data_file
(** 使用降级数据 *)

(** {1 主要API函数} *)

val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file
(** 获取韵律数据（支持缓存） *)

val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
(** 获取所有韵组 *)

val get_rhyme_group_characters : string -> string list
(** 获取指定韵组的字符列表 *)

val get_rhyme_group_category : string -> rhyme_category
(** 获取指定韵组的韵类 *)

val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
(** 获取韵律映射关系 *)

val get_data_statistics : unit -> (int * int) option
(** 获取数据统计信息 (总韵组数, 总字符数) *)

val print_statistics : unit -> unit
(** 打印统计信息 *)

val get_rhyme_data_safe : ?force_reload:bool -> unit -> rhyme_data_file option
(** 安全获取韵律数据（带降级处理） *)
