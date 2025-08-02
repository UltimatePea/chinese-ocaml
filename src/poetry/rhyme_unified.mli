(** 韵律模块统一接口 - 消除重复和简化架构

    此模块提供韵律相关功能的统一入口点，整合原有的多个重复模块：
    - rhyme_json_* 系列模块 (9个)
    - rhyme_data_* 系列模块 (5个)
    - rhyme_core_* 系列模块 (4个)
    - unified_* 重复模块

    @author Alpha代理, 技术债务清理专员
    @version 1.0 - 统一整合版本
    @since 2025-07-29 - 韵律模块整合重构

    参见 issue #1673 *)

(** {1 核心类型重新导出} *)

(* 从Poetry_core.Json_core导出核心类型，确保兼容性 *)
type rhyme_category = Poetry_core.Json_core.rhyme_category
type rhyme_group = Poetry_core.Json_core.rhyme_group
type rhyme_data_item = Poetry_core.Json_core.rhyme_data_item

(** {1 数据结构类型} *)

type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Poetry_core.Json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 异常类型} *)

exception Json_parse_error of string
(** JSON解析错误 *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到 *)

exception Cache_error of string
(** 缓存操作错误 *)

(** {1 核心功能模块} *)

(** 数据管理模块 - 整合所有数据加载和缓存功能 *)
module Data : sig
  val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file option
  (** 获取韵律数据（带缓存管理）*)

  val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
  (** 获取所有韵组 *)

  val get_rhyme_group_characters : string -> string list
  (** 获取指定韵组的字符列表 *)

  val get_rhyme_group_category : string -> rhyme_category
  (** 获取指定韵组的声韵类别 *)

  val clear_cache : unit -> unit
  (** 清空缓存 *)

  val get_cache_stats : unit -> int * int * float
  (** 获取缓存统计信息 *)
end

(** JSON处理模块 - 整合所有JSON相关功能 *)
module Json : sig
  val parse_rhyme_json : string -> rhyme_data_file
  (** 解析韵律数据JSON *)

  val load_from_file : ?filename:string -> unit -> rhyme_data_file
  (** 从文件加载韵律数据 *)

  val clean_json_string : string -> string
  (** 清理JSON字符串 *)
end

(** 查询和分析模块 - 整合韵律分析功能 *)
module Analysis : sig
  val find_character_rhyme : string -> rhyme_data_item option
  (** 查找字符的韵律信息 *)

  val get_character_rhyme_group : string -> rhyme_group option
  (** 获取字符的韵组 *)

  val can_rhyme_together : string -> string -> bool
  (** 检查两个字符是否可以押韵 *)

  val find_rhyming_characters : string -> string list
  (** 查找与指定字符押韵的字符 *)
end

(** 实用工具模块 - 整合辅助功能 *)
module Utils : sig
  val string_to_rhyme_category : string -> rhyme_category option
  (** 字符串转韵类（安全版本） *)

  val string_to_rhyme_group : string -> rhyme_group option
  (** 字符串转韵组（安全版本） *)

  val get_data_statistics : unit -> int * int
  (** 获取数据统计信息 (韵组数, 字符数) *)

  val print_statistics : unit -> unit
  (** 打印统计信息 *)
end

(** {1 兼容性接口 - 保持向后兼容} *)

(** 主要API函数 - 为现有代码提供兼容接口 *)

val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file option
(** 获取韵律数据 (兼容rhyme_json_core接口) *)

val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
(** 获取所有韵组 (兼容多个模块接口) *)

val get_rhyme_group_characters : string -> string list
(** 获取韵组字符 (兼容多个模块接口) *)

val get_rhyme_group_category : string -> rhyme_category
(** 获取韵组类别 (兼容多个模块接口) *)

val find_character_rhyme : string -> rhyme_data_item option
(** 查找字符韵律 (兼容rhyme_api_core接口) *)

val can_rhyme_together : string -> string -> bool
(** 韵律匹配检查 (兼容分析模块接口) *)

val clear_cache : unit -> unit
(** 清空缓存 (兼容缓存模块接口) *)

val string_to_rhyme_category : string -> rhyme_category option
(** 类型转换 (兼容类型模块接口) *)

val string_to_rhyme_group : string -> rhyme_group option
(** 类型转换 (兼容类型模块接口) *)

val parse_rhyme_json : string -> rhyme_data_file
(** JSON解析 (兼容JSON模块接口) *)

val load_from_file : ?filename:string -> unit -> rhyme_data_file
(** 文件加载 (兼容I/O模块接口) *)

val get_data_statistics : unit -> int * int
(** 数据统计 (兼容统计模块接口) *)

val print_statistics : unit -> unit
(** 打印统计 (兼容统计模块接口) *)

(** {1 使用说明} *)

(** 推荐使用方式:

    新代码建议使用模块化接口:
    - Rhyme_unified.Data.* - 数据管理
    - Rhyme_unified.Json.* - JSON处理
    - Rhyme_unified.Analysis.* - 韵律分析
    - Rhyme_unified.Utils.* - 实用工具

    现有代码可以继续使用顶层兼容函数，无需修改。 *)
