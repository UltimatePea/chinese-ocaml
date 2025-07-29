(** 韵律数据统一核心模块 - 骆言诗词编程特性

    此模块是技术债务重构的核心成果，经过模块化重构后提供统一的韵律数据访问接口。 模块化重构消除了854行单一文件的维护复杂度，提高编译并行度。

    重构目标：
    - 模块化拆分降低单文件复杂度（从854行拆分为4个职责单一模块）
    - 提供统一的数据访问接口
    - 提升编译效率和维护性
    - 保持100%的API兼容性

    Author: Alpha, 主要工作代理
    @version 5.0 - 模块化重构版本
    @since 2025-07-28 - 基于Issue #1585的科学技术债务重构计划 *)

(** {1 模块化重构导入} *)

open Poetry_core.Poetry_types
(** 导入重构后的模块化组件 *)

(** {2 类型重导出 - 保持API兼容性} *)

type rhyme_data_entry = Rhyme_core_types.rhyme_data_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}
(** 重导出核心类型以保持现有代码兼容 *)

type rhyme_group_data = Rhyme_core_types.rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_data_entry list;
  example_poems : string list;
}

(** {3 构建函数重导出} *)

(** 重导出构建辅助函数以保持API兼容性 *)
let make_entry = Rhyme_data_builder.make_entry

let make_group_entries = Rhyme_data_builder.make_group_entries

(** {4 韵律数据重导出 - 保持API兼容性} *)

(** 重导出所有韵组数据以保持现有代码兼容 *)
let an_rhyme_data = Rhyme_data_builder.an_rhyme_data

let si_rhyme_data = Rhyme_data_builder.si_rhyme_data
let tian_rhyme_data = Rhyme_data_builder.tian_rhyme_data
let wang_rhyme_data = Rhyme_data_builder.wang_rhyme_data
let qu_rhyme_data = Rhyme_data_builder.qu_rhyme_data
let yu_rhyme_data = Rhyme_data_builder.yu_rhyme_data
let hua_rhyme_data = Rhyme_data_builder.hua_rhyme_data
let feng_rhyme_data = Rhyme_data_builder.feng_rhyme_data
let yue_rhyme_data = Rhyme_data_builder.yue_rhyme_data
let jiang_rhyme_data = Rhyme_data_builder.jiang_rhyme_data
let hui_rhyme_data = Rhyme_data_builder.hui_rhyme_data

(** {5 韵组集合重导出} *)

(** 重导出韵组集合以保持API兼容性 *)
let all_rhyme_groups = Rhyme_data_builder.all_rhyme_groups

(** {6 数据处理功能重导出} *)

(** 重导出数据处理功能以保持API兼容性 *)
let all_rhyme_entries = Rhyme_group_manager.all_rhyme_entries

(** {7 查询接口重导出} *)

(** 重导出查询接口以保持API兼容性 *)
let find_char_rhyme_info = Rhyme_query_engine.find_char_rhyme_info

let get_rhyme_group_data = Rhyme_group_manager.get_rhyme_group_data
let get_chars_by_category = Rhyme_group_manager.get_chars_by_category
let get_chars_by_group = Rhyme_group_manager.get_chars_by_group
let get_statistics = Rhyme_group_manager.get_statistics

(** {8 兼容性接口重导出} *)

(** 重导出兼容性接口以保持现有代码工作 *)
let get_legacy_rhyme_data = Rhyme_group_manager.get_legacy_rhyme_data

let lookup_character = Rhyme_query_engine.lookup_character
let lookup_group = Rhyme_query_engine.lookup_group
let get_all_groups = Rhyme_group_manager.get_all_groups
let get_all_entries = Rhyme_group_manager.get_all_entries
let get_all_rhyme_groups = Rhyme_group_manager.get_all_rhyme_groups
