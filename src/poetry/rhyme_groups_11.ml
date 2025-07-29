(** 韵律数据模块 11 - 灰韵组及特殊处理

    此模块包含第11个韵组（灰韵组）的数据定义，从rhyme_data_builder.ml重构提取。 目标是减少单文件复杂度，提升模块化程度。

    Author: Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-28 - Fix #1588 韵律数据构建器模块化重构计划 *)

open Rhyme_core_types
open Rhyme_group_helpers

(** {2 灰韵组数据} *)

(** 灰韵组数据 - 整合自 hui_rhyme_data.ml 和相关文件 *)
let hui_rhyme_data =
  let ping_sheng_chars =
    [
      "灰";
      "回";
      "推";
      "胎";
      "台";
      "来";
      "开";
      "才";
      "材";
      "财";
      "裁";
      "哀";
      "崖";
      "涯";
      "牌";
      "排";
      "培";
      "陪";
      "赔";
      "杯";
      "悲";
      "北";
      "备";
      "被";
    ]
  in
  let ze_sheng_chars =
    [
      "改";
      "海";
      "害";
      "亥";
      "代";
      "带";
      "待";
      "黛";
      "呆";
      "袋";
      "贷";
      "逮";
      "态";
      "太";
      "泰";
      "汰";
      "肽";
      "钛";
      "苔";
      "抬";
      "胎";
      "台";
      "怠";
      "殆";
    ]
  in
  {
    group_name = HuiRhyme;
    group_description = "灰韵组 - 含灰、回、推等字，灰飞烟灭";
    entries =
      make_group_entries PingSheng HuiRhyme ping_sheng_chars
      @ make_group_entries ZeSheng HuiRhyme ze_sheng_chars;
    example_poems = [ "白日依山尽，黄河入海流"; "欲穷千里目，更上一层楼"; "莫愁前路无知己，天下谁人不识君" ];
  }
