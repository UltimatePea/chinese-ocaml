(** 韵律查询引擎模块接口 - 提供高效的韵律数据查询功能
 *
 *  从rhyme_data_unified.ml重构而来，专注于查询操作实现、
 *  索引管理和查询优化，实现高性能的韵律数据检索。
 *
 *  @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
 *  @version 3.0 - 模块化重构版本
 *  @since 2025-07-29 - 基于issue #1662的模块化重构 *)

open Rhyme_data_core

(** {1 索引构建和管理} *)

val rebuild_character_index : rhyme_data_item list -> unit

val rebuild_group_index : rhyme_data_item list -> unit

val rebuild_category_index : rhyme_data_item list -> unit

val rebuild_tone_index : rhyme_data_item list -> unit

val rebuild_all_indexes : unit -> unit

(** {1 查询功能} *)

type query = rhyme_query

val query_rhyme_data : query -> rhyme_data_item list rhyme_result

val find_rhyme_character : string -> rhyme_data_item option

val find_rhyme_group_characters : Poetry_core.Json_core.rhyme_group -> rhyme_data_item list

val find_characters_by_tone : [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ] -> rhyme_data_item list

(** {1 性能优化} *)

val clear_query_cache : unit -> unit

val optimize_indexes : unit -> unit