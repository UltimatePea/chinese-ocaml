(** 韵律数据管理模块接口 - 提供数据源管理、导入导出和验证功能
 *
 *  从rhyme_data_unified.ml重构而来，专注于数据源管理、
 *  数据导入导出和完整性验证，实现完整的数据管理生命周期。
 *
 *  @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
 *  @version 3.0 - 模块化重构版本
 *  @since 2025-07-29 - 基于issue #1662的模块化重构 *)

open Rhyme_data_core
open Rhyme_query_engine

(** {1 韵律数据源管理} *)

val register_rhyme_source :
  string ->
  (unit -> (string * Rhyme_data_core.tone * int) list) ->
  ?priority:int ->
  string ->
  Rhyme_data_core.result

val get_available_sources : unit -> (string * string * int) list
val remove_rhyme_source : string -> Rhyme_data_core.result
val update_source_priority : string -> int -> Rhyme_data_core.result

(** {1 数据导出功能} *)

val format_tone_string : Rhyme_data_core.tone -> string
val export_rhyme_data : Rhyme_query_engine.query -> format:[ `JSON | `CSV | `XML ] -> string
val export_all_data : format:[ `JSON | `CSV | `XML ] -> string

(** {1 数据导入功能} *)

val import_rhyme_data : string -> format:[ `JSON | `CSV ] -> string -> Rhyme_data_core.result
val import_from_file : string -> format:[ `JSON | `CSV ] -> string -> Rhyme_data_core.result

(** {1 备份与恢复} *)

val backup_rhyme_data : unit -> string
val restore_rhyme_data : string -> Rhyme_data_core.result
val create_data_snapshot : unit -> string

(** {1 统计与分析} *)

val get_rhyme_statistics : unit -> (string * int) list

(** {1 数据验证} *)

val validate_rhyme_data : unit -> Rhyme_data_core.result
val find_data_conflicts : unit -> (string * string list) list
val resolve_conflicts_automatically : unit -> Rhyme_data_core.result

(** {1 维护功能} *)

val check_source_health : unit -> (string * string) list
val cleanup_unused_sources : unit -> Rhyme_data_core.result
