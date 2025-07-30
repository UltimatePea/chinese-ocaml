(** 韵律数据统一核心模块 - 兼容性层 (Phase 2.2 重构)

    此模块现在作为 unified_rhyme_engine.ml 的兼容性层，保持所有现有API完全不变。 实际功能已整合到统一韵律引擎中，实现以下改进：

    Phase 2.2 整合成果：
    - 5个核心模块 (1086行) → 1个统一引擎
    - 消除功能重复，提升维护性
    - 统一API接口，简化调用
    - 保持100%向后兼容

    Author: Alpha, 主要工作代理
    @version 6.0 - Phase 2.2 引擎整合兼容层
    @since 2025-07-30 - Fix #1755 核心引擎统一 *)

(** {1 兼容性重导出} *)

module Engine = Unified_rhyme_engine
(** 所有功能现在通过统一韵律引擎提供 *)

(** {2 类型重导出 - 保持API兼容性} *)

type rhyme_data_entry = Engine.rhyme_data_entry = {
  character : string;
  category : Poetry_core.Poetry_types.rhyme_category;
  group : Poetry_core.Poetry_types.rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type rhyme_group_data = Engine.rhyme_group_data = {
  group_name : Poetry_core.Poetry_types.rhyme_group;
  group_description : string;
  entries : rhyme_data_entry list;
  example_poems : string list;
}

(** {3 构建函数重导出} *)

let make_entry = Engine.make_entry
let make_group_entries = Engine.make_group_entries

(** {4 韵律数据重导出 - 保持API兼容性} *)

let an_rhyme_data = Engine.an_rhyme_data
let si_rhyme_data = Engine.si_rhyme_data
let tian_rhyme_data = Engine.tian_rhyme_data
let wang_rhyme_data = Engine.wang_rhyme_data
let qu_rhyme_data = Engine.qu_rhyme_data
let yu_rhyme_data = Engine.yu_rhyme_data
let hua_rhyme_data = Engine.hua_rhyme_data
let feng_rhyme_data = Engine.feng_rhyme_data
let yue_rhyme_data = Engine.yue_rhyme_data
let jiang_rhyme_data = Engine.jiang_rhyme_data
let hui_rhyme_data = Engine.hui_rhyme_data

(** 所有韵组数据的统一集合 *)
let all_rhyme_groups = Engine.all_rhyme_groups

(** 附加兼容性函数 *)
let get_rhyme_group_data = Engine.get_rhyme_group_data

let get_all_entries = Engine.get_all_entries
let get_chars_by_category = Engine.get_chars_by_category
let get_all_groups = Engine.get_all_groups
let find_char_rhyme_info = Engine.find_char_rhyme_info
