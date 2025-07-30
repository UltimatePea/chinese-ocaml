(** 统一韵律核心模块 - 兼容性层 (Phase 2.2 重构)

    此模块现在作为 unified_rhyme_engine.ml 的兼容性层，保持所有现有API完全不变。
    原有的统一数据类型和核心数据定义现在通过统一韵律引擎提供。

    Author: Alpha, 主要工作代理
    @version 2.0 - Phase 2.2 引擎整合兼容层
    @since 2025-07-30 - Fix #1755 核心引擎统一 *)

(** {1 兼容性重导出} *)

(** 所有功能现在通过统一韵律引擎提供 *)
module Engine = Unified_rhyme_engine

(** {2 统一韵律数据类型重导出} *)

type unified_rhyme_entry = Engine.unified_rhyme_entry = {
  character : string;
  category : Poetry_core.Poetry_types.rhyme_category;
  group : Poetry_core.Poetry_types.rhyme_group;
  variants : string list;
  frequency : float;
}

type unified_rhyme_group = Engine.unified_rhyme_group = {
  group_id : Poetry_core.Poetry_types.rhyme_group;
  group_name : string;
  entries : unified_rhyme_entry list;
  description : string;
}

type database_stats = Engine.database_stats = {
  total_characters : int;
  total_groups : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
}

type unified_rhyme_database = Engine.unified_rhyme_database = {
  version : string;
  groups : unified_rhyme_group list;
  index : (string, unified_rhyme_entry) Hashtbl.t;
  stats : database_stats;
}

(** {3 核心功能重导出} *)

(** 引擎版本信息 *)
let engine_version = Engine.engine_version

(** 引擎统计信息 *)
let get_engine_stats = Engine.get_engine_stats

(** 引擎健康检查 *)
let engine_health_check = Engine.engine_health_check