(** 思韵组数据模块

    从 rhyme_core_data.ml 中提取的思韵组专用数据， 包含思韵组的平声和仄声字符数据。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构版本
    @since 2025-07-26 *)

open Rhyme_core_types

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 思韵组平声字符数据 *)
let ping_sheng_chars =
  [
    "诗";
    "时";
    "知";
    "思";
    "才";
    "材";
    "灾";
    "猜";
    "来";
    "开";
    "台";
    "载";
    "白";
    "百";
    "拍";
    "牌";
    "排";
    "怀";
    "坏";
    "海";
    "买";
    "卖";
    "带";
    "待";
    "爱";
    "外";
    "快";
    "块";
    "怪";
    "界";
    "解";
    "类";
    "内";
    "黑";
    "背";
    "配";
  ]

(** 思韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng SiRhyme ping_sheng_chars

(** 思韵组仄声字符数据 *)
let ze_sheng_chars =
  [
    "字";
    "自";
    "紫";
    "次";
    "此";
    "死";
    "史";
    "使";
    "起";
    "里";
    "理";
    "李";
    "子";
    "纸";
    "水";
    "美";
    "比";
    "以";
    "已";
    "似";
    "是";
    "喜";
    "意";
    "气";
    "地";
    "第";
    "体";
    "替";
    "题";
    "系";
    "西";
    "息";
    "席";
    "习";
    "吸";
    "及";
  ]

(** 思韵组仄声数据条目 *)
let ze_sheng_data = make_group_entries ZeSheng SiRhyme ze_sheng_chars

(** 思韵组所有数据 *)
let all_data = ping_sheng_data @ ze_sheng_data
