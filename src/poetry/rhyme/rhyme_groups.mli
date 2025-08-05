(** 统一韵组管理模块接口

    本模块整合了原本分散在多个文件中的韵组数据，建立统一的韵组管理架构。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合实施
    @since 2025-08-04 *)

open Rhyme_types

(** {1 韵组数据访问} *)

val all_rhyme_characters : (string * tone_category * rhyme_group) list
(** 所有韵组字符数据 - 包含字符、声调、韵组的完整映射 *)

(** {1 韵组管理函数} *)

val group_characters_by_rhyme : unit -> (rhyme_group, rhyme_character list) Hashtbl.t
(** 按韵组分类所有字符，返回分组哈希表 *)

val get_group_characters : rhyme_group -> rhyme_character list
(** 获取特定韵组的所有字符 *)

val get_ping_sheng_groups : unit -> rhyme_group list
(** 获取平声韵组列表 *)

val get_ze_sheng_groups : unit -> rhyme_group list
(** 获取仄声韵组列表 *)

val is_ping_sheng_group : rhyme_group -> bool
(** 判断韵组是否为平声 *)

val create_rhyme_group_data : rhyme_group -> rhyme_group_data
(** 创建韵组数据结构 *)

val get_all_rhyme_group_data : unit -> rhyme_group_data list
(** 获取所有韵组数据 *)

val find_character_group : string -> (rhyme_group * tone_category) option
(** 查找字符所属韵组，返回 (韵组, 声调) 或 None *)

val get_rhyme_statistics : unit -> rhyme_statistics
(** 获取韵组统计信息 *)

(** {1 兼容性接口} *)

(** 为了兼容现有代码，提供访问特定韵组数据的函数 *)
module Compat : sig
  val get_hua_rhyme_chars : unit -> string list
  (** 获取花韵组字符列表 *)

  val get_feng_rhyme_chars : unit -> string list
  (** 获取风韵组字符列表 *)

  val get_yu_rhyme_chars : unit -> string list
  (** 获取鱼韵组字符列表 *)

  val get_yue_rhyme_chars : unit -> string list
  (** 获取月韵组字符列表 *)

  val get_jiang_rhyme_chars : unit -> string list
  (** 获取江韵组字符列表 *)

  val get_hui_rhyme_chars : unit -> string list
  (** 获取灰韵组字符列表 *)
end
