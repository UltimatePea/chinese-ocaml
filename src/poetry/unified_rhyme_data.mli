(** 韵律数据加载模块接口

    负责加载和管理韵律数据，将硬编码数据集中管理，便于维护和扩展。 *)

open Rhyme_types

(** {1 数据加载函数} *)

val load_rhyme_data_to_cache : unit -> unit
(** 加载韵律数据到缓存 *)

val get_rhyme_group_chars : rhyme_group -> string list option
(** 获取指定韵组的字符集 *)

val get_all_rhyme_groups : unit -> (rhyme_group * rhyme_category) list
(** 获取所有韵组列表 *)

val get_data_stats : unit -> int * int
(** 获取韵律数据统计信息 *)
