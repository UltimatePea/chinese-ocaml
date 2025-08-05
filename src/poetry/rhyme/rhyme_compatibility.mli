(** 韵律模块向后兼容性接口

    提供与原有12个韵律数据文件完全兼容的接口，确保现有代码无需修改。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types

(** {1 原始数据格式兼容} *)

module Legacy_Core : sig
  type rhyme_entry = {
    character : string;
    category : tone_category;
    group : rhyme_group;
    variants : string list;
    usage_frequency : float;
  }

  type rhyme_group_data = {
    group_name : rhyme_group;
    group_description : string;
    entries : rhyme_entry list;
    example_poems : string list;
  }

  val make_rhyme_group_data :
    rhyme_group -> string -> (string * tone_category * rhyme_group) list -> rhyme_group_data

  val make_ping_sheng_group :
    rhyme_group -> string list -> (string * tone_category * rhyme_group) list

  val make_ze_sheng_group :
    rhyme_group -> string list -> (string * tone_category * rhyme_group) list

  val create_rhyme_data : rhyme_group -> string -> string list -> string list -> rhyme_group_data
end

(** {1 个别韵组数据模块兼容} *)

module An_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val an_rhyme_data : Legacy_Core.rhyme_group_data
end

module Si_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val si_rhyme_data : Legacy_Core.rhyme_group_data
end

module Tian_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val tian_rhyme_data : Legacy_Core.rhyme_group_data
end

module Wang_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val wang_rhyme_data : Legacy_Core.rhyme_group_data
end

module Qu_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val qu_rhyme_data : Legacy_Core.rhyme_group_data
end

module Yu_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val yu_rhyme_data : Legacy_Core.rhyme_group_data
end

module Hua_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val hua_rhyme_data : Legacy_Core.rhyme_group_data
end

module Feng_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val feng_rhyme_data : Legacy_Core.rhyme_group_data
end

module Yue_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val yue_rhyme_data : Legacy_Core.rhyme_group_data
end

module Jiang_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val jiang_rhyme_data : Legacy_Core.rhyme_group_data
end

module Hui_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val hui_rhyme_data : Legacy_Core.rhyme_group_data
end

(** {1 传统查询接口兼容} *)

module Legacy_Query : sig
  type legacy_query_result = Found of Legacy_Core.rhyme_entry | NotFound

  val rhyme_lookup : string -> legacy_query_result
  val group_lookup : rhyme_group -> Legacy_Core.rhyme_group_data option
  val is_ping_sheng : string -> bool
  val is_ze_sheng_char : string -> bool
  val get_rhyme_group : string -> rhyme_group option
end

(** {1 韵组注册表兼容} *)

module Legacy_Registry : sig
  val get_all_registered_groups : unit -> Legacy_Core.rhyme_group_data list
  val find_group_by_name : string -> Legacy_Core.rhyme_group_data option
  val register_rhyme_group : Legacy_Core.rhyme_group_data -> unit
end

(** {1 兼容性别名} *)

module Rhyme_data_core = Legacy_Core
module Rhyme_data_registry = Legacy_Registry

(** {1 兼容性测试} *)

val verify_compatibility : unit -> bool
val get_compatibility_report : unit -> string
