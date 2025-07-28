(** 韵律类型兼容模块 - Poetry Phase 3 Wave 1: 类型统一化
    
    此模块现在作为Rhyme_core_types的兼容层，确保现有代码继续工作。
    所有类型定义统一迁移到Poetry_core.Rhyme_core_types模块。
    
    迁移策略：导入并重新导出核心类型，保持API兼容性。
    
    @author Alpha, Primary Worker Agent - Poetry Phase 3 Wave 1
    @version 3.0 (统一化兼容版)
    @since 2025-07-28
    @fix_issue #1546 - Poetry模块系统性重构 *)

(* 导入统一的核心类型定义 *)
open Poetry_core.Rhyme_core_types

(* 重新导出核心类型以保持兼容性 *)
type rhyme_category = Poetry_core.Rhyme_core_types.rhyme_category =
  | PingSheng  (** 平声韵 *)
  | ZeSheng  (** 仄声韵 *)
  | ShangSheng  (** 上声韵 *)
  | QuSheng  (** 去声韵 *)
  | RuSheng  (** 入声韵 *)

type rhyme_group = Poetry_core.Rhyme_core_types.rhyme_group =
  | AnRhyme  (** 安韵组 *)
  | SiRhyme  (** 思韵组 *)
  | TianRhyme  (** 天韵组 *)
  | WangRhyme  (** 望韵组 *)
  | QuRhyme  (** 去韵组 *)
  | YuRhyme  (** 鱼韵组 *)
  | HuaRhyme  (** 花韵组 *)
  | FengRhyme  (** 风韵组 *)
  | YueRhyme  (** 月韵组 *)
  | XueRhyme  (** 雪韵组 *)
  | JiangRhyme  (** 江韵组 *)
  | HuiRhyme  (** 灰韵组 *)
  | UnknownRhyme  (** 未知韵组 *)

(* 重新导出兼容性数据类型 *)
type rhyme_data_item = Poetry_core.Rhyme_core_types.rhyme_data_item = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_value : int option;
  frequency : float option;
  source : string;
}

type rhyme_group_data = Poetry_core.Rhyme_core_types.compat_rhyme_group_data = {
  group : rhyme_group;
  items : rhyme_data_item list;
  metadata : (string * string) list;
}

type rhyme_database = Poetry_core.Rhyme_core_types.rhyme_database = {
  groups : rhyme_group_data list;
  version : string;
  last_updated : string;
  sources : string list;
}

(* 重新导出所有兼容性工具函数 *)
let rhyme_category_to_string = rhyme_category_to_string
let string_to_rhyme_category = string_to_rhyme_category
let rhyme_group_to_string = rhyme_group_to_string
let string_to_rhyme_group = string_to_rhyme_group
let create_rhyme_item = create_rhyme_item
let create_enhanced_rhyme_item = create_enhanced_rhyme_item
let compare_rhyme_items = compare_rhyme_items
let create_empty_database = create_empty_database
let create_rhyme_group_data = create_rhyme_group_data
let get_characters_from_group = get_characters_from_group
let filter_by_category = filter_by_category
let filter_by_group = filter_by_group
let count_items_by_category = count_items_by_category
let count_items_by_group = count_items_by_group
let find_character_in_database = find_character_in_database
let validate_rhyme_data_item = validate_rhyme_data_item
let validate_rhyme_database = validate_rhyme_database
