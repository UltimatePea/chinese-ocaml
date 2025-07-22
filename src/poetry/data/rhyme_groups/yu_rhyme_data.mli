(** 鱼韵组数据模块接口 - 第二阶段技术债务重构版本

    数据外化重构版本的公共接口，提供懒加载的韵律数据访问， 同时保持与原始模块的向后兼容性。

    修复 Issue #801 - 技术债务改进第二阶段：超长函数重构和数据外化

    @author 骆言诗词编程团队
    @version 2.0 (数据外化重构版)
    @since 2025-07-21 - 技术债务改进第二阶段 *)

(** {1 数据加载异常} *)

exception Yu_rhyme_data_error of string

(** {1 懒加载数据} *)

val yu_yun_core_chars : string list Lazy.t
(** 鱼韵组核心字符数据 (懒加载) *)

val yu_yun_jia_chars : string list Lazy.t
(** 鱼韵组贾价系列字符数据 (懒加载) *)

val yu_yun_qi_chars : string list Lazy.t
(** 鱼韵组棋期系列字符数据 (懒加载) *)

val yu_yun_fish_chars : string list Lazy.t
(** 鱼韵组扩展鱼类字符数据 (懒加载) *)

val yu_yun_ping_sheng :
  (string * Rhyme_group_types.rhyme_category * Rhyme_group_types.rhyme_group) list Lazy.t
(** 鱼韵组平声韵数据 (懒加载) *)

(** {1 统计信息 (懒加载)} *)

val yu_yun_char_count : int Lazy.t
(** 鱼韵组字符总数 (懒加载) *)

val yu_yun_core_count : int Lazy.t
(** 鱼韵组核心字符数量 (懒加载) *)

val yu_yun_jia_count : int Lazy.t
(** 鱼韵组贾价系列字符数量 (懒加载) *)

val yu_yun_qi_count : int Lazy.t
(** 鱼韵组棋期系列字符数量 (懒加载) *)

val yu_yun_fish_count : int Lazy.t
(** 鱼韵组鱼类扩展字符数量 (懒加载) *)

(** {1 向后兼容性接口} *)

(** 向后兼容性模块，提供立即访问的接口 *)
module Compatibility : sig
  val get_yu_yun_core_chars : unit -> string list
  (** 立即获取核心字符列表 *)

  val get_yu_yun_jia_chars : unit -> string list
  (** 立即获取贾价系列字符列表 *)

  val get_yu_yun_qi_chars : unit -> string list
  (** 立即获取棋期系列字符列表 *)

  val get_yu_yun_fish_chars : unit -> string list
  (** 立即获取鱼类扩展字符列表 *)

  val get_yu_yun_ping_sheng :
    unit -> (string * Rhyme_group_types.rhyme_category * Rhyme_group_types.rhyme_group) list
  (** 立即获取平声韵数据 *)

  val get_yu_yun_char_count : unit -> int
  (** 立即获取字符总数 *)

  val get_yu_yun_core_count : unit -> int
  (** 立即获取核心字符数量 *)

  val get_yu_yun_jia_count : unit -> int
  (** 立即获取贾价系列字符数量 *)

  val get_yu_yun_qi_count : unit -> int
  (** 立即获取棋期系列字符数量 *)

  val get_yu_yun_fish_count : unit -> int
  (** 立即获取鱼类扩展字符数量 *)
end
