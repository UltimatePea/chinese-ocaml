(** 统一韵律数据库接口模块 - 骆言诗词编程特性

    此模块整合所有韵组数据，提供统一的数据库访问接口。 保持与原 expanded_rhyme_data.ml 的完全向后兼容性。 *)

(** {1 韵律数据库} *)

val expanded_rhyme_database : (string * Rhyme_group_types.rhyme_category * Rhyme_group_types.rhyme_group) list
(** 扩展韵律数据库 - 完整的韵律数据库 *)

(** {1 向后兼容接口} *)

val expanded_rhyme_char_count : int
(** 扩展韵律数据库字符总数 *)

val get_expanded_rhyme_database :
  unit -> (string * Rhyme_group_types.rhyme_category * Rhyme_group_types.rhyme_group) list
(** 获取扩展韵律数据库 *)

val is_in_expanded_rhyme_database : string -> bool
(** 检查字符是否在扩展韵律数据库中 *)

val get_expanded_char_list : unit -> string list
(** 获取扩展韵律数据库中的字符列表 *)

(** {1 新增模块化接口} *)

val get_rhyme_data_by_group :
  Rhyme_group_types.rhyme_group -> (string * Rhyme_group_types.rhyme_category * Rhyme_group_types.rhyme_group) list
(** 按韵组获取数据 *)

val get_rhyme_data_by_category :
  Rhyme_group_types.rhyme_category -> (string * Rhyme_group_types.rhyme_category * Rhyme_group_types.rhyme_group) list
(** 按韵类获取数据 *)

val get_all_rhyme_groups : unit -> Rhyme_group_types.rhyme_group list
(** 获取所有韵组列表 *)

val get_rhyme_group_char_count : Rhyme_group_types.rhyme_group -> int
(** 获取特定韵组的字符数量 *)

val get_rhyme_category_char_count : Rhyme_group_types.rhyme_category -> int
(** 获取特定韵类的字符数量 *)

(** {1 数据库状态查询} *)

val get_database_stats : unit -> int * int * int
(** 获取数据库统计信息 - 返回 (总字符数, 韵组数量, 韵类数量) *)

val validate_database : unit -> bool * string list
(** 验证数据库完整性 - 返回 (是否完整, 重复字符列表) *)
