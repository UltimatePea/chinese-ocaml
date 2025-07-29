(** 韵律核心数据模块接口 - 模块化重构版本
 *
 *  此模块通过模块化架构整合所有韵律数据，替代原来728行的大文件。
 *  使用独立的韵组模块提高代码可维护性和可读性。
 *
 *  @author Beta, 代码审查代理
 *  @version 1.0 - 模块化重构版本
 *  @since 2025-07-27 *)

(** {1 模块化韵律数据接口} *)

include module type of Rhyme_groups_modular.Rhyme_groups_registry
(** 重新导出韵组注册中心的所有公共接口 *)

(** {2 兼容性接口} *)

val all_rhyme_data : (string * string list) list
(** 所有韵律数据的统一集合 - 兼容性别名 *)

val data_by_group : (string * (string * string list) list) list
(** 按韵组分类的数据 - 兼容性别名 *)

val data_by_category : (string * (string * string list) list) list
(** 按声韵类别分类的数据 - 兼容性别名 *)

val rhyme_group_descriptions : (string * string) list
(** 韵组描述信息 - 兼容性别名 *)

val char_count_by_group : (string * int) list
(** 按韵组统计字符数量 - 兼容性别名 *)

val char_count_by_category : (string * int) list
(** 按声韵类别统计字符数量 - 兼容性别名 *)

(** {3 重构统计信息} *)

val refactoring_stats : string
(** 重构前后对比数据 *)

val modularization_benefits : (string * string) list
(** 模块化收益统计 *)
