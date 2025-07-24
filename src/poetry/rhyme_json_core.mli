(** 韵律JSON处理核心模块接口 - 整合版本
    
    整合了原本分散在8个模块中的功能，提供统一的韵律数据处理接口。
    
    @author 骆言诗词编程团队
    @version 2.0  
    @since 2025-07-24 - Phase 7.1 JSON处理系统整合重构 *)

(** {1 类型定义} *)

(** 韵类定义 *)
type rhyme_category =
  | PingSheng  (** 平声 *)
  | ZeSheng  (** 仄声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng  (** 去声 *)
  | RuSheng  (** 入声 *)

(** 韵组定义 *)
type rhyme_group =
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

(** JSON解析异常 *)
exception Json_parse_error of string

(** 韵律数据未找到异常 *)
exception Rhyme_data_not_found of string

(** 韵组数据类型 *)
type rhyme_group_data = {
  category : string;  (** 韵类名称 *)
  characters : string list;  (** 该韵组包含的字符列表 *)
}

(** 韵律数据文件结构 *)
type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;  (** 韵组映射 *)
  metadata : (string * string) list;  (** 元数据信息 *)
}

(** {1 类型转换函数} *)

(** 字符串转韵类 *)
val string_to_rhyme_category : string -> rhyme_category

(** 字符串转韵组 *)
val string_to_rhyme_group : string -> rhyme_group

(** {1 缓存管理} *)

(** 检查缓存是否有效 *)
val is_cache_valid : unit -> bool

(** 获取缓存的数据 *)
val get_cached_data : unit -> rhyme_data_file

(** 设置缓存数据 *)
val set_cached_data : rhyme_data_file -> unit

(** 清理缓存 *)
val clear_cache : unit -> unit

(** 强制刷新缓存 *)
val refresh_cache : rhyme_data_file -> unit

(** {1 主要API函数} *)

(** 获取韵律数据（支持缓存）
    @param force_reload 是否强制重新加载，默认false *)
val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file

(** 安全获取韵律数据（带降级处理）
    @param force_reload 是否强制重新加载，默认false *)
val get_rhyme_data_safe : ?force_reload:bool -> unit -> rhyme_data_file option

(** 获取所有韵组 *)
val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list

(** 获取指定韵组的字符列表 *)
val get_rhyme_group_characters : string -> string list

(** 获取指定韵组的韵类 *)
val get_rhyme_group_category : string -> rhyme_category

(** 获取韵律映射关系 *)
val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list

(** 获取数据统计信息
    @return Some (韵组总数, 字符总数) 或 None（失败时） *)
val get_data_statistics : unit -> (int * int) option

(** 打印统计信息 *)
val print_statistics : unit -> unit

(** {1 内部函数（用于兼容层）} *)

(** 从文件加载韵律数据 *)
val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file

(** 使用降级数据 *)
val use_fallback_data : unit -> rhyme_data_file

(** 解析嵌套JSON内容 *)
val parse_nested_json : string -> (string * rhyme_group_data) list