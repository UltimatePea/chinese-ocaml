(** 统一诗韵数据模块接口 *)

open Poetry_types_unified

(** {1 韵组数据} *)

(** 安韵组数据 *)
val an_rhyme_data : rhyme_group_data

(** 风韵组数据 *)
val feng_rhyme_data : rhyme_group_data

(** 花韵组数据 *)
val hua_rhyme_data : rhyme_group_data

(** 灰韵组数据 *)
val hui_rhyme_data : rhyme_group_data

(** 江韵组数据 *)
val jiang_rhyme_data : rhyme_group_data

(** 去韵组数据 *)
val qu_rhyme_data : rhyme_group_data

(** 思韵组数据 *)
val si_rhyme_data : rhyme_group_data

(** 天韵组数据 *)
val tian_rhyme_data : rhyme_group_data

(** 王韵组数据 *)
val wang_rhyme_data : rhyme_group_data

(** 鱼韵组数据 *)
val yu_rhyme_data : rhyme_group_data

(** 月韵组数据 *)
val yue_rhyme_data : rhyme_group_data

(** 雪韵组数据 *)
val xue_rhyme_data : rhyme_group_data

(** {1 数据集合} *)

(** 所有韵组数据列表 *)
val all_rhyme_groups : rhyme_group_data list

(** 创建韵组数据库索引 *)
val create_rhyme_database : unit -> rhyme_database

(** 全局韵组数据库实例 *)
val rhyme_database : rhyme_database Lazy.t

(** {1 查询接口} *)

(** 根据字符查找韵组信息 *)
val find_rhyme_by_char : string -> query_result

(** 根据韵组获取所有韵字 *)
val get_rhyme_group_data : rhyme_group -> rhyme_group_data option

(** 获取所有韵组列表 *)
val get_all_rhyme_groups : unit -> rhyme_group_data list

(** 验证韵律一致性 *)
val validate_rhyme_consistency : string list -> validation_result