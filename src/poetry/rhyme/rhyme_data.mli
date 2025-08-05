(** 韵律数据统一整合模块接口

    本接口提供对整合后韵律数据的所有访问功能，替代了原有的12个分散数据文件。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types

(** {1 基础查询接口} *)

val lookup_character : string -> query_result
(** 查询单个字符的韵律信息 - O(1)复杂度 *)

val lookup_group : rhyme_group -> rhyme_group_data option
(** 查询韵组的完整数据 *)

val get_group_characters : rhyme_group -> rhyme_character list
(** 获取韵组的所有字符 *)

val get_ping_sheng_characters : rhyme_group -> string list
(** 获取韵组的平声字符 *)

val get_ze_sheng_characters : rhyme_group -> string list
(** 获取韵组的仄声字符 *)

val check_rhyme_match : string -> string -> bool
(** 检查两个字符是否同韵 *)

val batch_lookup_characters : string list -> query_result list
(** 批量查询字符 *)

(** {1 统计和分析接口} *)

val get_all_groups : unit -> rhyme_group_data list
(** 获取所有韵组列表 *)

val get_statistics : unit -> rhyme_statistics
(** 计算韵律统计信息 *)

(** {1 验证和完整性检查} *)

val validate_data_integrity : unit -> bool * string list
(** 验证数据完整性，返回(是否有效, 问题列表) *)

val get_module_info : unit -> string
(** 获取模块信息 *)
