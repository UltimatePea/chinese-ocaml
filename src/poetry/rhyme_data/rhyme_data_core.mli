(** 韵律数据核心模块接口 *)

open Poetry_core.Rhyme_core_types

(** {1 共享类型定义} *)

(** 韵组数据条目类型 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

(** 韵组数据结构类型 *)
type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_entry list;
  example_poems : string list;
}

(** 辅助函数：将元组列表转换为rhyme_group_data结构 *)
val make_rhyme_group_data : 
  rhyme_group -> string -> (string * rhyme_category * rhyme_group) list -> rhyme_group_data

(** 辅助函数：创建平声组数据 *)
val make_ping_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 辅助函数：创建仄声组数据 *)
val make_ze_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 统一创建韵组数据的函数 *)
val create_rhyme_data : rhyme_group -> string -> string list -> string list -> rhyme_group_data