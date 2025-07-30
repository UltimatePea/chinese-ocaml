(** 韵律数据构建器 - 模块化重构后的兼容接口

    此模块现在作为统一注册中心的兼容层，保持所有现有API完全不变。 实际数据现在分布在以下模块中：
    - rhyme_groups_1_5.ml: 安、思、天、王、曲韵组
    - rhyme_groups_6_10.ml: 鱼、花、风、月、江韵组
    - rhyme_groups_11.ml: 灰韵组
    - rhyme_data_registry.ml: 统一注册和查询接口

    重构收益:
    - 文件行数: 751行 → 4个<200行模块
    - 并行编译: 4个模块可并行编译
    - 维护性: 修改单个韵组只影响对应模块

    Author: Alpha, 主要工作代理
    @version 2.0 - 模块化重构版本
    @since 2025-07-28 - Fix #1588 韵律数据构建器模块化重构计划 *)

open Rhyme_core_types

(** {1 向后兼容的API接口} *)

(** 创建韵律数据条目的辅助函数 - 兼容性保留 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 - 兼容性保留 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** {2 韵组数据兼容接口} *)

(** 安韵组数据 - 兼容性引用 *)
let an_rhyme_data = Unified_rhyme_groups_data.an_rhyme_data

(** 思韵组数据 - 兼容性引用 *)
let si_rhyme_data = Unified_rhyme_groups_data.si_rhyme_data

(** 天韵组数据 - 兼容性引用 *)
let tian_rhyme_data = Unified_rhyme_groups_data.tian_rhyme_data

(** 望韵组数据 - 兼容性引用 *)
let wang_rhyme_data = Unified_rhyme_groups_data.wang_rhyme_data

(** 去韵组数据 - 兼容性引用 *)
let qu_rhyme_data = Unified_rhyme_groups_data.qu_rhyme_data

(** 鱼韵组数据 - 兼容性引用 *)
let yu_rhyme_data = Unified_rhyme_groups_data.yu_rhyme_data

(** 花韵组数据 - 兼容性引用 *)
let hua_rhyme_data = Unified_rhyme_groups_data.hua_rhyme_data

(** 风韵组数据 - 兼容性引用 *)
let feng_rhyme_data = Unified_rhyme_groups_data.feng_rhyme_data

(** 月韵组数据 - 兼容性引用 *)
let yue_rhyme_data = Unified_rhyme_groups_data.yue_rhyme_data

(** 江韵组数据 - 兼容性引用 *)
let jiang_rhyme_data = Unified_rhyme_groups_data.jiang_rhyme_data

(** 灰韵组数据 - 兼容性引用 *)
let hui_rhyme_data = Unified_rhyme_groups_data.hui_rhyme_data

(** {3 统一数据集合} *)

(** 所有韵组数据的统一集合 - 从注册中心获取 *)
let all_rhyme_groups =
  [
    an_rhyme_data;
    si_rhyme_data;
    tian_rhyme_data;
    wang_rhyme_data;
    qu_rhyme_data;
    yu_rhyme_data;
    hua_rhyme_data;
    feng_rhyme_data;
    yue_rhyme_data;
    jiang_rhyme_data;
    hui_rhyme_data;
  ]
