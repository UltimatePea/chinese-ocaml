(** 韵律JSON API兼容层接口 - Wave 2 重构版本

    基于统一JSON核心的兼容接口层。保持100%向后兼容性。

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

exception Json_parse_error of string
exception Rhyme_data_not_found of string

type rhyme_group_data = Rhyme_json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Rhyme_json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 原模块兼容接口} *)

module Types : sig
  type rhyme_category = Rhyme_json_core.rhyme_category
  type rhyme_group = Rhyme_json_core.rhyme_group
  type rhyme_data_item = Rhyme_json_core.rhyme_data_item

  exception Json_parse_error of string
  exception Rhyme_data_not_found of string

  type rhyme_group_data = Rhyme_json_core.rhyme_group_data = {
    category : string;
    characters : string list;
  }

  type rhyme_data_file = Rhyme_json_core.rhyme_data_file = {
    rhyme_groups : (string * rhyme_group_data) list;
    metadata : (string * string) list;
  }

  val string_to_rhyme_category : string -> rhyme_category
  val string_to_rhyme_group : string -> rhyme_group
end

module Cache : sig
  val is_cache_valid : unit -> bool
  val get_cached_data : unit -> rhyme_data_file
  val set_cached_data : rhyme_data_file -> unit
  val clear_cache : unit -> unit
  val refresh_cache : rhyme_data_file -> unit
end

module Parser : sig
  val parse_nested_json : string -> rhyme_data_file
  val clean_json_string : string -> string
end

module Io : sig
  val default_data_file : string
  val safe_read_file : string -> string
  val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file
  val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file
end

module Access : sig
  val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
  val get_rhyme_group_characters : string -> string list
  val get_rhyme_group_category : string -> rhyme_category
  val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
  val get_data_statistics : unit -> (int * int) option
  val print_statistics : unit -> unit
end

module Fallback : sig
  val fallback_rhyme_data : (string * rhyme_group_data) list
  val use_fallback_data : unit -> rhyme_data_file
end

(** {1 主要API函数} *)

val string_to_rhyme_category : string -> rhyme_category
val string_to_rhyme_group : string -> rhyme_group
val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file option
val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
val get_rhyme_group_characters : string -> string list
val get_rhyme_group_category : string -> rhyme_category
val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
val get_data_statistics : unit -> (int * int) option
val print_statistics : unit -> unit
val is_cache_valid : unit -> bool
val clear_cache : unit -> unit
val refresh_cache : rhyme_data_file -> unit
val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file
val use_fallback_data : unit -> rhyme_data_file
val parse_nested_json : string -> rhyme_data_file
val clean_json_string : string -> string
