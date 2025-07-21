(** 鱼韵组数据模块接口 - 骆言诗词编程特性

    鱼书居虚，渔樵江渚意深远。鱼韵组提供丰富的韵律字符数据， 依《平水韵》传统分类，为诗词创作提供标准的韵律支持。 *)

open Rhyme_group_types

(** {1 鱼韵组核心字符数据} *)

val yu_yun_core_chars : string list
(** 鱼韵组核心常用字 - 最常用的鱼韵字符 *)

val yu_yun_jia_chars : string list
(** 鱼韵组贾价系列 - "贾、价、假、嫁"等字符 *)

val yu_yun_qi_chars : string list
(** 鱼韵组棋期系列 - "棋、旗、期、欺"等字符 *)

val yu_yun_fish_chars : string list
(** 鱼韵组扩展鱼类字符 - 各种鱼类名称字符 *)

(** {1 鱼韵组数据合成} *)

val yu_yun_ping_sheng : (string * rhyme_category * rhyme_group) list
(** 鱼韵组平声韵数据 - 完整的鱼韵平声韵数据 *)

(** {1 鱼韵组统计信息} *)

val yu_yun_char_count : int
(** 获取鱼韵组字符总数 *)

val yu_yun_core_count : int
(** 获取鱼韵组核心字符数量 *)

val yu_yun_jia_count : int
(** 获取鱼韵组贾价系列字符数量 *)

val yu_yun_qi_count : int
(** 获取鱼韵组棋期系列字符数量 *)

val yu_yun_fish_count : int
(** 获取鱼韵组鱼类扩展字符数量 *)
